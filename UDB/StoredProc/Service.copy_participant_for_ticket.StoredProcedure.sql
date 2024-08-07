USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Service].[copy_participant_for_ticket]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Service].[copy_participant_for_ticket]
@participantId varchar(100),
@administrationId int,
@masterAdministrationId int,
@studentId int output
as set xact_abort on;

declare @masterStudentId int,@updateDate datetime;

select @masterStudentId=studentId,@updateDate=updateDate
from core.student
where administrationId=@masterAdministrationId and participantId=@participantId;

if (@updateDate='1900-01-01') throw 50099,'concurrency error - partial master',0;

if (@masterStudentId is null) throw 50002,'invalid participant',0;

set @updateDate=getdate();
set @studentId=next value for core.student_seqEven;

insert core.student (administrationId,studentId,participantId,firstName,middleName,lastName,stateStudentId,districtStudentId,districtCode,schoolCode,grade,birthdate,gender,updateDate)
select @administrationId,@studentId,participantId=@participantId,firstName,middleName,lastName,stateStudentId,districtStudentId,districtCode,schoolCode,grade,birthdate,gender,'1900-01-01'
from core.student (updlock) s
where s.administrationId=@masterAdministrationId and s.studentId=@masterStudentId and not exists(select * from core.student (nolock) x where x.administrationId=@administrationId and x.participantId=@participantId);

if (@@rowcount=0) throw 50099,'concurrency error',0;

with i as (
  select distinct administrationId=@administrationId,studentId=@studentId,x.category,x.name,x.value
  from student.extensions x
  join xref.cedsmap m on m.category=x.category and m.name=x.name and m.value in (x.value,'<NO-LOOKUP>','<default>')
  where x.administrationId=@masterAdministrationId and x.studentId=@masterStudentId
  union all 
  select administrationId=@administrationId,studentId=@studentId,category='!DRC',name='BubbledOnlyStudent',value='N'
)
merge student.extensions t
using i on i.administrationId=t.administrationId and i.studentId=t.studentId and i.category=t.category and i.name=t.name
when matched then
update set value=i.value
when not matched then
  insert (administrationid,studentid,category,name,value)
  values (i.administrationid,i.studentid,i.category,i.name,i.value);

update core.student set updateDate=@updateDate,importDate=@updateDate where administrationId=@administrationId and studentId=@studentId;
GO
