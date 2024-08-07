USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Service].[pre_create_tickets]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Service].[pre_create_tickets]
@registrationId varchar(100),
@participantId varchar(100),
@administrationId int,
@testSessionId int,
@masterAdministrationId int,
@incoming varchar(max)
as set xact_abort on;

declare @documentTestingCodes bit;
declare @studentId int,@test varchar(50),@level varchar(20),@assessmentId varchar(100),@session varchar(max)=json_query(@incoming,'$.session');

select @studentId=studentId from core.student where administrationId=@administrationId and participantId=@participantId;

if (@studentId is null) exec service.copy_participant_for_ticket @participantId=@participantId,@administrationId=@administrationId,@masterAdministrationId=@masterAdministrationId,@studentId=@studentId output;

select @test=test,@level=level,@assessmentId=assessmentId
from openjson(@incoming,'$.session') with (test varchar(50),level varchar(20),assessmentId varchar(100));

select @documentTestingCodes=isnull(documentTestingCodes,0)
from openjson(@incoming) with (documentTestingCodes bit '$.cfg.documentTestingCodes');

exec service.update_accommodations_for_ticket @administrationId=@administrationId,@studentId=@studentId,@test=@test,@incoming=@incoming;

if (@documentTestingCodes=0) begin

  declare @ext table (administrationId int,studentId int,name varchar(50),value varchar(1000),isDelete bit);

  insert @ext (name,value,isDelete)
  select name,value,1
  from student.extensions
  where administrationId=@administrationId and studentId=@studentId and category='TestingCodes' and name like @level+'_'+@test+'_%';

  with u as (
    select name=level+'_'+test+'_'+name,value
    from openjson(@incoming,'$.testingCodes') with (test varchar(50),level varchar(20),name varchar(50),value varchar(1000))
  )
  merge @ext t
  using u on u.name=t.name
  when matched and u.value=t.value then delete
  when matched then update set value=u.value,isDelete=0
  when not matched then insert (name,value) values (u.name,u.value);

  with u as (
    select administrationId=@administrationId,studentId=@studentId,category='TestingCodes',name,value,isDelete
    from @ext
  )
  merge student.extensions t
  using u on u.administrationId=t.administrationId and u.studentId=t.studentId and 'TestingCodes'=t.category and u.name=t.name
  when matched and isDelete=1 then delete
  when matched then update set value=u.value
  when not matched then insert (administrationid,studentid,category,name,value) values (u.administrationid,u.studentid,u.category,u.name,u.value);

end;

declare @d table (documentId int);

update t set republishDate=getdate()
output inserted.documentId into @d
from testsession.links k
join document.testticket t on t.administrationId=k.administrationId and t.documentId=k.documentId
where k.administrationId=@administrationId and k.testSessionId=@testSessionId and k.studentId=@studentId and t.assessmentId=@assessmentId;

select action=iif(@@rowcount>0,'republish','create'),studentId=@studentId,ticketsJson=(
  select linkDocumentId,documentId
  from @d d
  cross apply (select linkDocumentId from document.testticket t where t.administrationId=@administrationId and t.documentId=d.documentId) t
  for json path
);
GO
