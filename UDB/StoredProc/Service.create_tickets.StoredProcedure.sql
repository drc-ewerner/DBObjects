USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Service].[create_tickets]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Service].[create_tickets]
@registrationId varchar(100),
@participantId varchar(100),
@administrationId int,
@testSessionId int,
@studentId int,
@incoming varchar(max)
as set xact_abort on;

declare @alternate bit,@prespiraled bit,@jobId varchar(100),@test varchar(50),@level varchar(20),@externalFormId varchar(100),@assessmentId varchar(100),@documentTestingCodes bit;

create table #d (documentId int);

select @alternate=alternate,@prespiraled=prespiraled,@jobId=jobId,@test=test,@level=level,@externalFormId=form,@assessmentId=assessmentId,@documentTestingCodes=documentTestingCodes
from openjson(@incoming) with (alternate bit,prespiraled bit,jobId varchar(100),test varchar(50) '$.session.test',level varchar(20) '$.session.level',form varchar(100) '$.session.form',assessmentId varchar(100) '$.session.assessmentId',documentTestingCodes bit '$.cfg.documentTestingCodes');

begin tran;

if (@alternate=1 or @prespiraled=1) begin

  declare @t table(documentId int,test varchar(50),level varchar(20),form varchar(20),username varchar(50),password varchar(20));

  if (@alternate=1) begin

    declare @altform varchar(20);
    select @altform=form
    from scoring.testforms f
    where administrationId=@administrationId and test=@test and level=@level and not exists(select * from scoring.testforms x where x.administrationId=f.administrationId and x.test=f.test and x.level=f.level and x.form!=f.form);

    if (@altform is null) throw 50051,'number of matching forms is not exactly 1',0;

    insert @t
    select documentId=next value for core.document_seqEven,@test,@level,@altform,@testSessionId,'';

  end else begin
  
    insert @t
    select documentId=next value for core.document_seqEven,test,level,form,username,password
    from openjson(@incoming,'$.forms') with (test varchar(50),level varchar(20),form varchar(20),username varchar(50),password varchar(20));
  
  end;

  insert core.document (administrationId,documentId,studentId,lithocode)
  select @administrationId,documentId,@studentId,'99'+right('0000000000'+cast((documentId) as varchar),10)
  from @t;

  insert document.testticket (administrationId,documentId,test,level,form,username,password,registrationId,assessmentId,externalFormId)
  select @administrationId,documentId,test,level,form,username,password,@registrationId,@assessmentId,@externalFormId
  from @t;

  insert testsession.links (administrationId,testSessionId,studentId,documentId)
  select @administrationId,@testSessionId,@studentId,documentId
  from @t;

  insert #d select documentId from @t;

  declare @respiralSql varchar(max);
  select @respiralSql=string_agg('exec insight.testTicketRespiral '+cast(@administrationId as varchar)+','+cast(documentId as varchar)+';','')
  from @t t
  join scoring.testForms f on f.administrationId=@administrationId and f.test=t.test and f.level=t.level and f.form=t.form
  where f.spiralingOption='placeholder';

  if (@respiralSql is not null) exec(@respiralSql);

end else begin

  declare @subTests table(test varchar(50),level varchar(20),assessmentId varchar(100));
  insert @subTests (test,level,assessmentId)
  select test,level,assessmentId
  from openjson(@incoming,'$.session.subTests') with (test varchar(50),level varchar(20),assessmentId varchar(100));

  if (@@rowcount>0) begin

    declare @username varchar(50),@password varchar(20);
    exec insight.getStudentUsername @administrationId,@studentId,@username output;
    set @password=(select password from insight.generatepassword(@administrationId,@username,1));

    declare @createSql varchar(max);
    select @createSql=string_agg('insert #d exec insight.testTicketCreate_fromRegistration '
      +cast(@administrationId as varchar)+','
      +cast(@testSessionId as varchar)+','
      +cast(@studentId as varchar)+','
      +'null,'
      +''''+test+''','
      +''''+level+''','
      +''''+@password+''','
      +''''+@registrationId+''','
      +''''+assessmentId+''';',''
    ) from @subTests t;
    exec(@createSql);

  end else begin

    insert #d 
    exec insight.testTicketCreate_fromRegistration @administrationId=@administrationId,@testSessionId=@testSessionId,@studentId=@studentId,@test=@test,@level=@level,@registrationId=@registrationId,@assessmentId=@assessmentId;

  end;

end;

insert document.extensions (administrationId,documentId,name,value)
select administrationId=@administrationId,documentId,name,value
from #d
cross join (
  select *,participantId=@participantId,standardFormatted=cast(standard+'.'+apl as varchar(100)),[!drc.dbversion]=cast(change_tracking_current_version() as varchar(100)),jobId=@jobId
  from openjson(@incoming,'$.session') with (teacherFirstName varchar(100),teacherMiddleName varchar(100),teacherLastName varchar(100),teacherId varchar(100),teacherEmail varchar(100),teacherUsername varchar(100),standard varchar(100),apl varchar(100),visibility varchar(100),registrationDate varchar(100)) i
) j
unpivot (value for name in (participantId,[!drc.dbversion],jobId,teacherFirstName,teacherMiddleName,teacherLastName,teacherId,teacherEmail,teacherUsername,standard,standardFormatted,visibility,registrationDate)) u
where value is not null
union all
select administrationId=@administrationId,documentId,'assessmentId',assessmentId
from #d d
cross apply (select assessmentId from document.testticket t where t.administrationId=@administrationId and t.documentId=d.documentId) t;

commit tran;

if (@documentTestingCodes=1) begin

  insert document.extensions (administrationId,documentId,name,value)
  select administrationId=@administrationId,documentId,test+'_'+name,value
  from #d d
  cross join openjson(@incoming,'$.testingCodes') with (test varchar(50),name varchar(50),value varchar(1000));

end;


select ticketsJson=(
  select linkDocumentId,documentId,inputId,entryDate
  from #d d
  cross apply (select linkDocumentId from document.testticket t where t.administrationId=@administrationId and t.documentId=d.documentId) t
  outer apply (select inputId,entryDate=convert(varchar,getdate(),127) from config.transactionalsources x where x.administrationId=@administrationId and x.source='psm-registration' and x.status='Active') x
  for json path
);
GO
