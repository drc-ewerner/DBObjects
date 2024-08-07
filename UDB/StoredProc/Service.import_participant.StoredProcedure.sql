USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Service].[import_participant]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Service].[import_participant] 
  @participantId varchar(100),
  @incoming nvarchar(max),
  @admins nvarchar(max)
as set xact_abort on;

declare @importTimestamp bigint=json_value(@incoming,'$.sentTimestamp');
declare @isWithdrawn bit=json_value(@incoming,'$.isWithdrawn');

merge audit.participantsync t
using (select participantId=@participantId,importTimestamp=@importTimestamp) u on u.participantId=t.participantId
when matched and u.importTimestamp>=t.importTimestamp then update set importTimestamp=u.importTimestamp
when not matched then insert (participantId,importTimestamp) values (u.participantId,u.importTimestamp);

if (@@rowcount=0) throw 55099,'outdated message',0;

declare @testingPrograms varchar(100),@bubbledOnlyStudent varchar(100),@updateDate datetime=getdate();

select @testingPrograms=testingProgramsExt,@bubbledOnlyStudent=bubbledOnlyStudent 
from openjson(@incoming) with (testingProgramsExt varchar(100),bubbledOnlyStudent varchar(100));

declare @keys table (administrationId int,studentId int,program varchar(1000),doCreate int);

insert @keys (administrationId,program,doCreate)
select administrationId,program,doCreate=max(doCreate)
from openjson(@admins)
with (administrationId int,program varchar(100),doCreate int)
group by administrationId,program;

update k set studentId=(select studentId from core.student s where s.administrationId=k.administrationId and s.participantId=@participantId) from @keys k;

if (@isWithdrawn=0) update @keys set studentId=next value for Core.Student_SeqEven
where studentId is null and doCreate=1;

delete @keys where studentId is null;

declare @ext table (administrationId int,studentId int,category varchar(50),name varchar(50),value varchar(1000),isDelete bit);

with m as (
  select category,name
  from xref.cedsmap
  union all
  select category,name
  from (values ('Demographic','testingPrograms')) z(category,name)
)
insert @ext
select x.administrationId,x.studentId,x.category,x.name,x.value,1
from student.extensions x
join @keys k on k.administrationId=x.administrationId and k.studentId=x.studentId
where exists(select * from m where m.category=x.category and m.name in (x.name,'*'));

with ext (category,name,value) as (
  select m.category,m.name,value=case when m.cedsValue=v.cedsValue then m.value else z.cedsValue end
  from openjson(@incoming,'$.ceds') with (cedsGroup varchar(100),cedsValue varchar(1000)) z
  cross apply (select cedsValue=isnull(cast(z.cedsValue as varchar(1000)),'<default>')) v
  join xref.cedsmap m on m.cedsGroup=z.cedsGroup and m.cedsValue in (v.cedsValue,'<NO-LOOKUP>')
  union all
  select category='Demographic',name='testingPrograms',value=@testingPrograms where @testingPrograms is not null
  union all
  select category='!DRC',name='BubbledOnlyStudent',value='N' where @bubbledOnlyStudent='N'
), a as (
  select a.administrationId,studentId,m.category,name=coalesce(x.name,y.name,z.name),m.value,m.cedsGroup,m.cedsValue
  from openjson(@incoming,'$.accommodations') with (administrationId int,name varchar(100),subject varchar(100)) z
  join xref.cedsmap m on m.cedsGroup='Accommodation' and m.cedsValue=z.subject
  outer apply (select name from xref.studentextensionnames x where x.administrationId=z.administrationId and x.category=m.category and x.name=z.name+'.*') x
  outer apply (select name from xref.cedsmap y where y.cedsGroup='Accommodation.'+z.name and y.cedsValue in (z.subject,'*')) y
  outer apply (select administrationId from @keys k where k.program=m.name) p
  cross apply (select administrationId=iif(z.administrationId=777777,isnull(p.administrationId,777777),z.administrationId)) a
  cross apply (select studentId from @keys k where k.administrationId=a.administrationId) studentId
), con as (
  select administrationId,category=parsename(name,2),name=parsename(name,1),type=parsename(value,2),style=parsename(value,1)
  from config.extensions where category='ParticipantManagement.Conversions'
), u as (
  select k.administrationId,k.studentId,x.category,x.name,value=coalesce(cdate.cvalue,x.value)
  from ext x
  cross join @keys k
  outer apply (select parentAdmin=masterAdministrationId from core.administration a where a.administrationId=k.administrationId) p
  outer apply (select top(1) type,style from con c where c.administrationId in (0,k.administrationId,parentAdmin) and c.category=x.category and c.name=x.name order by case c.administrationId when k.administrationId then 1 when parentAdmin then 2 else 3 end) c 
  outer apply (select cvalue=iif(type='date',convert(varchar,try_parse(x.value as date),try_parse(style as int)),null)) cdate
  union
  select administrationId,studentId,category,name,value
  from a
)
merge @ext t
using u on u.administrationId=t.administrationId and u.studentId=t.studentId and u.category=t.category and u.name=t.name
when matched and u.value=t.value then delete
when matched then update set value=u.value,isDelete=0
when not matched then insert (administrationid,studentid,category,name,value) values (u.administrationid,u.studentid,u.category,u.name,u.value)
;

declare @out table(administrationId int,studentId int,participantId varchar(100),action varchar(10));

with i (administrationId,studentId,participantId,firstName,middleName,lastName,stateStudentId,districtStudentId,districtCode,schoolCode,grade,birthdate,gender) as (
  select administrationId,studentId,@participantId,firstName,middleName,lastName,stateStudentId,districtStudentId,districtCode,schoolCode,grade=isnull(cedsGrade,grade),birthdate,gender=isnull(cedsGender,gender)
  from @keys
  cross apply openjson(@incoming,'$') with (firstName nvarchar(100),lastName nvarchar(100),middleName nvarchar(100),stateStudentId varchar(30),districtStudentId varchar(30),districtCode varchar(15),schoolCode varchar(15),grade varchar(2),birthdate datetime,gender varchar(1)) p
  outer apply (select cedsGender=value from xref.cedsmap x where x.category='CoreStudent' and x.name='Gender' and x.cedsvalue=isnull(cast(p.gender as varchar(100)),'<default>')) cedsGender
  outer apply (select cedsGrade=value from xref.cedsmap x where x.category='CoreStudent' and x.name='Grade' and x.cedsvalue=isnull(cast(p.grade as varchar(100)),'<default>')) cedsGrade
)
merge core.student t
using i on i.administrationId=t.administrationId and i.studentId=t.studentId
when matched then
update set firstName=i.firstName,middleName=i.middleName,lastName=i.lastName,stateStudentId=i.stateStudentId,districtStudentId=i.districtStudentId,districtCode=i.districtCode,schoolCode=i.schoolCode,grade=i.grade,birthdate=i.birthdate,gender=i.gender,updateDate='1900-01-01',withdrawDate=iif(@isWithdrawn=1,@updateDate,null)
when not matched then
insert (administrationid,studentid,participantId,firstName,middleName,lastName,stateStudentId,districtStudentId,districtCode,schoolCode,grade,birthdate,gender,createDate,updateDate)
values (i.administrationid,i.studentid,i.participantId,i.firstName,i.middleName,i.lastName,i.stateStudentId,i.districtStudentId,i.districtCode,i.schoolCode,i.grade,i.birthdate,i.gender,@updateDate,'1900-01-01')
output inserted.administrationId,inserted.studentId,inserted.participantId,lower($action) into @out;

merge student.extensions t
using @ext i on i.administrationId=t.administrationId and i.studentId=t.studentId and i.category=t.category and i.name=t.name
when matched and isDelete=1 then delete
when matched then update set value=i.value
when not matched then insert (administrationid,studentid,category,name,value) values (i.administrationid,i.studentid,i.category,i.name,i.value);

update s set updateDate=@updateDate,importDate=@updateDate
from core.student s
join @keys k on k.administrationId=s.administrationId and k.studentId=s.studentId;

select *
from @out o
outer apply (select inputId,entryDate=convert(varchar,@updateDate,127) from config.transactionalsources x where x.administrationId=o.administrationId and x.source='PSM' and x.status='Active') inputId
order by administrationId,studentId;
GO
