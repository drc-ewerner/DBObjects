USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetStudentProfile]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[GetStudentProfile]
  @AdministrationID int,
  @Username varchar(50),
  @Password varchar(20)

as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare
  @_AdministrationID int,
  @_Username varchar(50),
  @_Password varchar(20),
  @TestSessionID int,
  @StudentID int,
  @DistrictCode varchar(15),
  @SchoolCode varchar(15),
  @Test varchar(50),
  @Level varchar(20),
  @LastAdministrationID int,
  @LastTestEventID int,
  @Blackout int,
  @ContentArea varchar(50),
  @NotLock varchar(1000),
  @UsernameLevel varchar(1000),
  @FormPublishAdministrationID int,
  @LockOffset int,
  @ContMultModule varchar(5),
  @ModuleCount int,
  @ActiveTest varchar(50),
  @ActiveLevel varchar(20),
  @MasterAdmin int,
  @MultipleLinksActive varchar(1000),
  @ScoringOption varchar(50),
  @TestingSiteSource varchar(1000),
  @OptionalItems varchar(50),
  @UseMultipleTests varchar(5),
  @TestMonitoring varchar(100),
  @TestAccessControl varchar(100),
  @RequireSecureExtension varchar(100),
  @SiteTestMonitoring varchar(100),
  @SiteTestAccessControl varchar(100),
  @SiteRequireSecureExtension varchar(100),
  @AllowChat varchar(100),
  @AllowIntervention varchar(100),
  @AllowAlerts varchar(100),
  @SiteAllowChat varchar(100),
  @SiteAllowIntervention varchar(100),
  @SiteAllowAlerts varchar(100),
  @AlwaysOpen varchar(100)
;

declare @d table (
  AdministrationID int not null,
  DocumentID int not null,
  Status varchar(50) not null,
  Test varchar(50),
  Level varchar(20),
  Form varchar(20) null,
  PartName varchar(50) null,
  StartTime datetime null,
  UnlockTime datetime null,
  TicketOrder int null,
  TicketOrderString varchar(20),
  TempStatus varchar(2) null,
  rn int null,
  MasterTest varchar(50),
  MasterForm varchar(20) null,
  TestSessionID int null,
  ScoringOption varchar(50) null,
  StudentID int null  index idx_1 unique clustered(DocumentID, AdministrationID, StudentID), 
  index idx_2 (TicketOrder) 
);

declare @AccomTest table (
  Test varchar(50)
);    

declare @a table (Name varchar(50) not null,Value varchar(1000) not null,DisplayName varchar(300));

declare @r table (DocumentID int, rn int)

declare @AdminList varchar(max);
declare @CDTAdmins table (AdministrationID varchar(100) not null);

declare @AllTests table (AdministrationID int, Test varchar(50), Level varchar(20));
declare @AllUserTests table (AdministrationID int, Test varchar(50), Level varchar(20));

-- prevent parameter sniffing
set @_AdministrationID=@AdministrationID;
set @_Username=@Username;
set @_Password=@Password;

select @UsernameLevel=Value
from Config.Extensions
where AdministrationID=@_AdministrationID and Category='Insight' and Name='TicketUsernameLevel';

select @ContMultModule=case when Value='Y' or Value='SingleLinkActiveNonWIDA' then 'true' else 'false' end
from Config.Extensions
where AdministrationID=@_AdministrationID and Category='Insight' and Name='ContinuousMultiModule';

select @MultipleLinksActive=case when Insight.GetConfigExtensionValue(@_AdministrationID,'Insight','ContinuousMultiModule','N')='MultipleLinksActive' then 'Y' else 'N' end;

select @TestingSiteSource=case when Value='DocumentExtensions' then 'DocumentExtensions' else 'TestSession' end
from Config.Extensions
where AdministrationID=@_AdministrationID and Category='Insight' and Name='TestingSiteSource';

select @UseMultipleTests=case when Insight.GetConfigExtensionValue(@_AdministrationID,'Insight','UseMultipleTestLinks','N')='Y' then 'Yes' else 'No' end;

if (@MultipleLinksActive='Y') set @ContMultModule='true'

set @FormPublishAdministrationID=@_AdministrationID;

if (@UsernameLevel='Client') begin
  set @_AdministrationID=(select distinct AdministrationID from Document.TestTicket where UserName=@_Username and Password=@_Password);
  set @MasterAdmin=(select MasterAdministrationID from Core.Administration where AdministrationID = @_AdministrationID);
  if (@FormPublishAdministrationID != @MasterAdmin) begin
    set @_AdministrationID=NULL;
  end
end

select @NotLock=Value
from Config.Extensions
where AdministrationID=@_AdministrationID and Category='eWeb' and Name='Tickets.PreventLock' and Value='Y';

select @LockOffset=Insight.GetConfigExtensionValue(@_AdministrationID,'eWeb','Tickets.LockTimeOffset','0');

insert @d (AdministrationID,DocumentID,Status,Test,Level,Form,PartName,StartTime,UnlockTime,TicketOrder,TestSessionID,ScoringOption,StudentID)
select t.AdministrationID,t.DocumentID,Status,t.Test,t.Level,t.Form,PartName,t.StartTime,t.UnlockTime,ModuleOrder,k.TestSessionID,ScoringOption,k.StudentID
from Document.TestTicketViewEx t
inner join TestSession.Links k on k.AdministrationID=t.AdministrationID and k.DocumentID=t.DocumentID
inner join Core.TestSession s on s.AdministrationID=t.AdministrationID and s.TestSessionID=k.TestSessionID
where t.AdministrationID=@_AdministrationID and t.Username=@_Username and t.Password=@_Password;

select @ModuleCount=count(*) from @d;

if (@ModuleCount=0) begin Select null; return end

select @TestSessionID=k.TestSessionID,@StudentID=k.StudentID,@DistrictCode=ts.DistrictCode,@SchoolCode=ts.SchoolCode,
  @Test=ts.Test,@Level=ts.Level,@ContentArea=tests.ContentArea,@ScoringOption=ts.ScoringOption,@OptionalItems=ts.OptionalItems
from Document.TestTicketViewEx t
inner join TestSession.Links k on k.AdministrationID=t.AdministrationID and k.DocumentID=t.DocumentID
inner join Core.TestSession ts on ts.AdministrationID=t.AdministrationID and ts.TestSessionID=k.TestSessionID
inner join Scoring.Tests tests on tests.AdministrationID=t.AdministrationID and tests.Test=ts.Test
where t.AdministrationID=@_AdministrationID and t.DocumentID in (select DocumentID from @d);

select @AlwaysOpen='Y'
where exists(select * from Config.Extensions where AdministrationID=@_AdministrationID and Category='Insight' and Name='SampleSitesAlwaysOpen' and Value='Y')
and exists(select * from Core.Site where AdministrationID=@_AdministrationID and SuperSiteCode=@DistrictCode and SiteCode=@SchoolCode and SiteSubType='Sample');

if @TestingSiteSource='DocumentExtensions' begin
  select @DistrictCode=st.SuperSiteCode,@SchoolCode=e.value
  from @d t
  inner join TestSession.Links l on l.AdministrationID=t.AdministrationID and l.DocumentID=t.DocumentID
  inner join Core.Student s on s.AdministrationID=t.AdministrationID and s.StudentID=l.StudentID
  inner join Document.Extensions e on e.AdministrationID=t.AdministrationID and e.DocumentID=t.DocumentID and e.Name='TestCenterCode'
  inner join Core.Site st on st.AdministrationID=t.AdministrationID and st.SuperSiteCode like s.DistrictStudentID+'%' and st.SiteCode=e.Value and st.Status='Active'
  where t.AdministrationID=@_AdministrationID and (t.PartName='1' or t.PartName is null)
end;  
  
if @ContMultModule is not null begin
  update @d set TicketOrder=coalesce(t.TicketOrder,p.ModuleOrder,m.ModuleOrder),TempStatus=case when Status='Completed' then 'CP' else 'NS' end,MasterTest=coalesce(p.Test,m.Test,@Test),MasterForm=m.Form
  from @d t
  left join Scoring.TestSessionTicketParts p on t.AdministrationID=p.AdministrationID and t.Test=p.PartTest and t.Level=p.Level
  left join Scoring.MultiModuleTicketParts m on t.AdministrationID=m.AdministrationID and @Test=m.Test and @Level=m.Level and t.Test=m.PartTest and t.Level=m.PartLevel and t.Form=m.FormPart
  where t.AdministrationID=@_AdministrationID --and t.Username=@_Username and t.Password=@_Password;

  insert @r (DocumentID,rn)
  select DocumentID,ROW_NUMBER()over(PARTITION BY TempStatus ORDER BY TicketOrder)
  from @d

  if @MultipleLinksActive='N' begin
    update @d set Status='Unavailable',rn=r.rn
    from @d d
    inner join @r r on d.DocumentID=r.DocumentID
    where d.TempStatus='NS' and r.rn>1
  end;

  select @ActiveTest=Test,@ActiveLevel=Level from @d where TempStatus='NS' and rn is null;
end;

if (@ContMultModule is null) begin
  set @ActiveTest=@Test
  set @ActiveLevel=@Level
  insert @AccomTest (Test)
  select Test from @d
  update @d set TicketOrder=p.ModuleOrder
  from @d d
  inner join Scoring.TestSessionTicketParts p on p.AdministrationID=@_AdministrationID and p.Test=@Test and p.Level=@Level and p.PartTest=d.Test and p.PartLevel=d.Level and p.PartName=d.PartName;
end else begin
  insert @AccomTest (Test)
  select distinct MasterTest from @d;
end;

update @d set TicketOrderString=right(REPLICATE('0',20)+cast(TicketOrder as varchar),20) where TicketOrder is not null;

insert @a (Name,Value)
select Name,Value
from Student.Extensions
where AdministrationID=@_AdministrationID and StudentID=@StudentID and Category in (select ContentArea from Scoring.Tests where AdministrationID=@_AdministrationID and Test in (select Test from @AccomTest)) and Value='Y'
union
select Name,Value
from Config.Extensions
where AdministrationID=@_AdministrationID and Category like 'Accommodation.Auto.%' and parsename(Category,1) in (select ContentArea from Scoring.Tests where AdministrationID=@_AdministrationID and Test in (select Test from @AccomTest)) and Value='Y'
union
select Name=replace(Name,'Accommodation.',''),Value
from Document.Extensions
where AdministrationID=@_AdministrationID and DocumentID in (select DocumentID from @d) and Name like 'Accommodation.%' and Value='Y'
;

insert @a (Name,Value)
select x.Name,a.Value
from @a a
inner join XRef.StudentExtensionNames x on x.AdministrationID=@_AdministrationID and x.Category in (select ContentArea from Scoring.Tests where AdministrationID=@_AdministrationID and Test in (select Test from @AccomTest)) and x.Name like left(a.Name,len(a.Name)-1)+'%'
where right(a.Name,1)='*' and x.Name!=a.Name;

update @a set DisplayName=x.DisplayName
from @a a
join XRef.StudentExtensionNames x on x.AdministrationID=@_AdministrationID and x.Name=a.Name;

select @AdminList = Value from Config.Extensions where AdministrationID = @_AdministrationID and Category ='Insight' and Name = 'CDT';

insert @CDTAdmins (AdministrationID)
select cast(value as int) from string_split(@AdminList, ',');

if @UseMultipleTests='Yes' begin
  insert @AllUserTests
  select AdministrationID,Test,Level
  from @d
  insert @AllTests
  select AdministrationID,Test,null
  from Scoring.Tests where AdministrationID=@_AdministrationID and ContentArea=@ContentArea
end 

create table #t (LastAdministrationID int, LastTestEventID int, LastDocument int, StartTime datetime, 
                Level varchar(20), Score varchar(50), Ability decimal(10,5), Value varchar(100), Form varchar(20), rn int,
                index idx_t_Score nonclustered (Score))
create table #j (LastAdministrationID int, LastTestEventID int, LastDocument int, StartTime datetime, 
                 Level varchar(20), Score varchar(50), Ability decimal(10,5), Value varchar(100), Form varchar(20), rn int,
                 index idx_j_Score nonclustered (Score))
create table #d (Score varchar(50), CategoryID varchar(100), DefaultAbility varchar(100), DefaultAbility2 varchar(100))

--find the abilities for the Diagnostic Category
--#t will be empty for clients/admins who have not opted in to this feature
if @UseMultipleTests='Yes' begin

insert #t
select * from 
( 
  select xt.AdministrationID LastAdministrationID, xte.TestEventID LastTestEventID, xte.DocumentID LastDocument, xt.StartTime, xt.Level, xts.score, xts.ability, xsx.value, xte.form,
    --ROW_NUMBER() over (partition by xt.test,xts.score order by xt.starttime desc) as rn
    ROW_NUMBER() over (partition by xts.score order by xt.starttime desc) as rn
  from Document.TestTicketViewEx xt
  inner join Core.TestEvent xte on xte.AdministrationID=xt.AdministrationID and xte.DocumentID=xt.DocumentID
  inner join Scoring.TestForms f on f.AdministrationID=xt.AdministrationID and f.Form=xte.Form
  inner join TestEvent.TestScores xts on xts.AdministrationID=xt.AdministrationID and xts.TestEventID=xte.TestEventID
  inner join Scoring.TestScoreExtensions xsx on xsx.AdministrationID=xt.AdministrationID and xsx.Test=xts.Test and xsx.Score=xts.score and xsx.Name='DiagnosticCategoryID'
  where xt.Username=@_Username and xts.Score<>'all' --and xt.Test=@Test 
    and xts.Test in (select Test from @AllTests)
    and f.Format='CAT' and xts.Ability is not null
    and xt.AdministrationID in (select AdministrationID from @CDTAdmins)  
    and not exists (select * from TestEvent.Extensions e where e.AdministrationID=xt.AdministrationID and e.TestEventID=xte.TestEventID and
      e.Test=xte.Test and e.Name='TestType' and e.Value='Composite')
) z
where rn=1;


--find the Overall Ability
--#j will be empty for clients/admins who have not opted in to this feature
insert #j
select * from 
( 
  select xt.AdministrationID LastAdministrationID, xte.TestEventID LastTestEventID, xte.DocumentID LastDocument, xt.StartTime, xt.Level, xts.score, xts.ability, xsx.value, xte.form,
    ROW_NUMBER() over (partition by xt.test,xt.level order by xt.starttime desc) as rn
  from Document.TestTicketViewEx xt
  inner join Core.TestEvent xte on xte.AdministrationID=xt.AdministrationID and xte.DocumentID=xt.DocumentID
  inner join TestEvent.TestScores xts on xts.AdministrationID=xt.AdministrationID and xts.TestEventID=xte.TestEventID
  inner join Scoring.TestScoreExtensions xsx on xsx.AdministrationID=xt.AdministrationID and xsx.Test=xts.Test and xsx.Score=xts.score and xsx.Name='DiagnosticCategoryID'
  where xt.Username=@_Username and xt.Test=@Test and xts.Score='all'
    and isnull(@UseMultipleTests,'No')='No'
    and xt.AdministrationID in (select AdministrationID from @CDTAdmins) 
) z
where rn=1;

insert #d
  select 
    st.Score,
    CategoryID=max(case when stx.Name='DiagnosticCategoryID' then Value end),
    DefaultAbility=max(case when stx.Name='DefaultAbility.'+at.Level then Value end),        -- uses one of the testlets' level, can be different levels in a session
    DefaultAbility2=max(case when stx.Name='DefaultAbility.'+at.Level+'.'+s.Grade then Value end)
  from Core.Student s
  inner join @AllUserTests at on at.AdministrationID=@_AdministrationID
  inner join Scoring.TestScores st on st.AdministrationID=@_AdministrationID and st.Test=at.Test      -- I think this needs to be all of the tests in the testsession, instead of randomly selecting one
  inner join Scoring.TestScoreExtensions stx on stx.AdministrationID=st.AdministrationID and stx.Test=st.Test and stx.Score=st.Score
  where s.AdministrationID=@_AdministrationID and s.StudentID=@StudentID
  group by st.Score
end

if @UseMultipleTests='No' begin
--find the abilities for the Diagnostic Category
--#t will be empty for clients/admins who have not opted in to this feature
insert #t
select * from 
( 
  select xt.AdministrationID LastAdministrationID, xte.TestEventID LastTestEventID, xte.DocumentID LastDocument, xt.StartTime, xt.Level, xts.score, xts.ability, xsx.value, xte.form,
    ROW_NUMBER() over (partition by xt.test,xts.score order by xt.starttime desc) as rn
  from Document.TestTicketViewEx xt
  inner join Core.TestEvent xte on xte.AdministrationID=xt.AdministrationID and xte.DocumentID=xt.DocumentID
  inner join TestEvent.TestScores xts on xts.AdministrationID=xt.AdministrationID and xts.TestEventID=xte.TestEventID
  inner join Scoring.TestScoreExtensions xsx on xsx.AdministrationID=xt.AdministrationID and xsx.Test=xts.Test and xsx.Score=xts.score and xsx.Name='DiagnosticCategoryID'
  where xt.Username=@_Username and xt.Test=@Test and xts.Score<>'all'
    and xt.AdministrationID in (select AdministrationID from @CDTAdmins)  
) z
where rn=1;

--find the Overall Ability
--#j will be empty for clients/admins who have not opted in to this feature
insert #j
select * from 
( 
  select xt.AdministrationID LastAdministrationID, xte.TestEventID LastTestEventID, xte.DocumentID LastDocument, xt.StartTime, xt.Level, xts.score, xts.ability, xsx.value, xte.form,
    ROW_NUMBER() over (partition by xt.test,xt.level order by xt.starttime desc) as rn
  from Document.TestTicketViewEx xt
  inner join Core.TestEvent xte on xte.AdministrationID=xt.AdministrationID and xte.DocumentID=xt.DocumentID
  inner join TestEvent.TestScores xts on xts.AdministrationID=xt.AdministrationID and xts.TestEventID=xte.TestEventID
  inner join Scoring.TestScoreExtensions xsx on xsx.AdministrationID=xt.AdministrationID and xsx.Test=xts.Test and xsx.Score=xts.score and xsx.Name='DiagnosticCategoryID'
  where xt.Username=@_Username and xt.Test=@Test and xts.Score='all'
    and xt.AdministrationID in (select AdministrationID from @CDTAdmins) 
) z
where rn=1;

insert #d
  select 
    st.Score,
    CategoryID=max(case when stx.Name='DiagnosticCategoryID' then Value end),
    DefaultAbility=max(case when stx.Name='DefaultAbility.'+@ActiveLevel then Value end),
    DefaultAbility2=max(case when stx.Name='DefaultAbility.'+@ActiveLevel+'.'+s.Grade then Value end)
  from Core.Student s
  inner join Scoring.TestScores st on st.AdministrationID=@_AdministrationID and st.Test=@ActiveTest
  inner join Scoring.TestScoreExtensions stx on stx.AdministrationID=st.AdministrationID and stx.Test=st.Test and stx.Score=st.Score
  where s.AdministrationID=@_AdministrationID and s.StudentID=@StudentID
  group by st.Score
end;

with blackout as (
  select x=case RuleType when 'weekday' then datepart(dw,getdate()) when 'hour' then datepart(hour,getdate()) end,w=case when Inclusion='In' then RuleWeight else -RuleWeight end,LowValue,HighValue
  from Config.Schedule 
  where AdministrationID=@_AdministrationID and Schedule='Insight' and DistrictCode is null
  union all
  select x=case RuleType when 'weekday' then datepart(dw,getdate()) when 'hour' then datepart(hour,getdate()) end,w=case when Inclusion='In' then RuleWeight else -RuleWeight end,LowValue,HighValue
  from Config.Schedule 
  where AdministrationID=@_AdministrationID and Schedule='Insight' and DistrictCode=@DistrictCode and SchoolCode is null
  union all
  select x=case RuleType when 'weekday' then datepart(dw,getdate()) when 'hour' then datepart(hour,getdate()) end,w=case when Inclusion='In' then RuleWeight else -RuleWeight end,LowValue,HighValue
  from Config.Schedule 
  where AdministrationID=@_AdministrationID and Schedule='Insight' and DistrictCode=@DistrictCode and SchoolCode=@SchoolCode
)
select @Blackout=max(w)+min(w)
from blackout
where x between LowValue and HighValue;

-- Test Monitoring and Access Control
select 
  @SiteTestMonitoring=case 
    when AdminTestMonitoring='Required' then 'Required' 
    when AdminTestMonitoring='Optional' then 'Optional' 
    when AdminTestMonitoring='None' then 'None' 
    end,
  @SiteTestAccessControl=case 
    when AdminTestAccessControl='True' then 'True' 
    when AdminTestAccessControl='False' then 'False' 
    end,
  @SiteRequireSecureExtension=SiteSecureConnection,
  @SiteAllowChat=SiteAllowChat,
  @SiteAllowIntervention=SiteAllowIntervention,
  @SiteAllowAlerts=SiteAllowAlerts
from Core.TestSession w
outer apply (select AdminTestMonitoring=Value from Site.Extensions x where x.AdministrationID=w.AdministrationID and x.DistrictCode=w.DistrictCode and x.SchoolCode='' and x.Category='Insight' and Name='TestMonitoring') AdminTestMonitoring
outer apply (select AdminTestAccessControl=Value from Site.Extensions x where x.AdministrationID=w.AdministrationID and x.DistrictCode=w.DistrictCode and x.SchoolCode='' and x.Category='Insight' and Name='TestAccessControl') AdminTestAccessControl
outer apply (select SiteSecureConnection=Value from Site.Extensions x where x.AdministrationID=w.AdministrationID and x.DistrictCode=w.DistrictCode and x.SchoolCode='' and x.Category='Insight' and Name='RequireSecureExtension') SiteSecureConnection
outer apply (select SiteAllowChat=Value from Site.Extensions x where x.AdministrationID=w.AdministrationID and x.DistrictCode=w.DistrictCode and x.SchoolCode='' and x.Category='Insight' and Name='AllowChat') SiteAllowChat
outer apply (select SiteAllowIntervention=Value from Site.Extensions x where x.AdministrationID=w.AdministrationID and x.DistrictCode=w.DistrictCode and x.SchoolCode='' and x.Category='Insight' and Name='AllowIntervention') SiteAllowIntervention
outer apply (select SiteAllowAlerts=Value from Site.Extensions x where x.AdministrationID=w.AdministrationID and x.DistrictCode=w.DistrictCode and x.SchoolCode='' and x.Category='Insight' and Name='AllowAlerts') SiteAllowAlerts
where w.AdministrationID=@_AdministrationID and w.TestSessionID=@TestSessionID;

select 
  @TestMonitoring=case 
    when Test like 'P[_]%' then 'None'
    when AdminTestMonitoring='Required' or MonitoringRequired='MonitoringRequired' or TestMonitoring='Required' or @SiteTestMonitoring='Required' then 'Required' 
    when TestMonitoring='Optional' then 'Optional'
    when TestMonitoring='None' then 'None'
    when @SiteTestMonitoring is not null then @SiteTestMonitoring
    when AdminTestMonitoring='Optional' then 'Optional' 
    else 'None' 
    end,
  @TestAccessControl=case 
    when Test like 'P[_]%' then 'False'
    when AdminTestAccessControl='True' or MonitoringRequired='MonitoringRequired' or TestAccessControl='True' or @SiteTestAccessControl='True' then 'True' 
    else 'False' 
    end,
  @RequireSecureExtension=case
    when @SiteRequireSecureExtension is not null then @SiteRequireSecureExtension
    when SiteSecureConnection='True' then 'True'
    else 'False'
    end,
  @AllowChat=case
    when @SiteAllowChat is not null then @SiteAllowChat
    when AllowChat='True' then 'True'
    else 'False'
    end,
  @AllowIntervention=case
    when @SiteAllowIntervention is not null then @SiteAllowIntervention
    when AllowIntervention='True' then 'True'
    else 'False'
    end,
  @AllowAlerts=case
    when @SiteAllowAlerts is not null then @SiteAllowAlerts
    when AllowAlerts='True' then 'True'
    else 'False'
    end
from Core.TestSession w
outer apply (select AdminTestMonitoring=Value from Config.Extensions x where x.AdministrationID=w.AdministrationID and x.Category='Insight' and Name='TestMonitoring') AdminTestMonitoring
outer apply (select AdminTestAccessControl=Value from Config.Extensions x where x.AdministrationID=w.AdministrationID and x.Category='Insight' and Name='TestAccessControl') AdminTestAccessControl
outer apply (select SiteSecureConnection=Value from Config.Extensions x where x.AdministrationID=w.AdministrationID and x.Category='Insight' and Name='RequireSecureExtension') SiteSecureConnection
outer apply (select MonitoringRequired=OptionalProcessing from Scoring.TestLevels x where x.AdministrationID=w.AdministrationID and x.Test=w.Test and x.Level=w.Level) MonitoringRequired
outer apply (select AllowChat=Value from Config.Extensions x where x.AdministrationID=w.AdministrationID and x.Category='Insight' and Name='AllowChat') AllowChat
outer apply (select AllowIntervention=Value from Config.Extensions x where x.AdministrationID=w.AdministrationID and x.Category='Insight' and Name='AllowIntervention') AllowIntervention
outer apply (select AllowAlerts=Value from Config.Extensions x where x.AdministrationID=w.AdministrationID and x.Category='Insight' and Name='AllowAlerts') AllowAlerts
where w.AdministrationID=@_AdministrationID and w.TestSessionID=@TestSessionID;

select 
  @AllowIntervention=case
    when @TestMonitoring in ('None','Optional') then 'False'
    else @AllowIntervention
    end;


with StudentProfile as (
  select 
  AdminCode=AdministrationCode,
  AdminDescription=a.LongDescription,
  Token=newid(),
  StudentName=isnull(FirstName,'')+' '+ltrim(isnull(MiddleName,'')+' ')+isnull(LastName,''),
  FirstName=FirstName,
  LastName=LastName,
  StudentID=StudentID,
  StateStudentID=StateStudentID,
  DistrictStudentID=DistrictStudentID,
  BirthDate=CONVERT(varchar(30),BirthDate, 101),
  Gender=Gender,
  Grade=Grade,
  SiteName=isnull(SiteName,'UNKNOWN'),
  DistrictName=isnull(DistrictName,'UNKNOWN'),
  SchoolName=isnull(SiteName,'UNKNOWN'),
  DistrictCode=@DistrictCode,
  SchoolCode=@SchoolCode,
  ContinuousMultiModule=isnull(@ContMultModule,'false'),
  TestSessionID=@TestSessionID,
  TestSessionName,
  TestType=@Test,
  TestName=@Level,
  Label=Label,
  OptionalItems=@OptionalItems,
  TestSessionStatus,
  ClientConfiguration,
  Telemetry,
  TestMonitoring=@TestMonitoring,
  TestAccessControl=@TestAccessControl,
  RequireSecureExtension=@RequireSecureExtension,
  AllowChat=@AllowChat,
  AllowIntervention=@AllowIntervention,
  AllowAlerts=@AllowAlerts 
  from Core.Student s
  inner join Core.Administration a on a.AdministrationID=s.AdministrationID
  outer apply (select SiteName from Core.Site where AdministrationID=@_AdministrationID and SuperSiteCode=@DistrictCode and SiteCode=@SchoolCode) ds
  outer apply (select DistrictName=SiteName from Core.Site where AdministrationID=@_AdministrationID and SiteCode=@DistrictCode and LevelID=1) dd
  cross apply (select TestSessionName=Name,TestSessionStatus=case when @AlwaysOpen='Y' then 'Active' when getdate() between StartTime and dateadd(day,1,EndTime) then case when @Blackout>0 then 'Active' else 'OutsideBlackoutDateTime' end else 'OutsideWindow' end from Core.TestSession where AdministrationID=@_AdministrationID and TestSessionID=@TestSessionID) ts
  cross apply (select Label=Description from Scoring.TestLevels where AdministrationID=@_AdministrationID and Test=@Test and Level=@Level) tl
  outer apply (select ClientConfiguration=Value from Config.XmlOptions where AdministrationID=@_AdministrationID and Name='ClientConfiguration') cc
  outer apply (select Telemetry=cast(Value as xml) from Config.Extensions where AdministrationID=@_AdministrationID and Category='Telemetry' and Name=@Test+'.'+@Level) telemetry
  where s.AdministrationID=@_AdministrationID and s.StudentID=@StudentID
), 
f as (
  select top (@ModuleCount)
    Form=isnull(tp.Form,d.Form),case when tf.SpiralingOption='Placeholder' or d.ScoringOption='Transition' then 'Unavailable' else d.Status end Status,TestStartTime=StartTime,TicketID=d.DocumentID,TestModel=isnull(tf.Format,'Fixed'),
    TestVersion=left(TestVersion,13)+substring(TestVersion,15,2)+substring(TestVersion,18,2),
    tf.Description,Part=tp.PartName,TestUnlockTime=UnlockTime,FormSessionName=isnull(tf.FormSessionName,tf2.FormSessionName),
    PartOrder=isnull(d.TicketOrderString,tp.PartName),
    PartName=tp.PartName,
    LCID=isnull(tf.LCID,'en-US'),
    TestSession=d.TestSessionID,
    StudentID=d.StudentID
  from @d d
  left join Scoring.TestForms tf on tf.AdministrationID=@FormPublishAdministrationID and tf.Test=d.Test and tf.Level=d.Level and tf.Form=coalesce(d.Form,d.MasterForm)
  left join Scoring.TestFormParts tp on tp.AdministrationID=tf.AdministrationID and tp.Test=tf.Test and tp.Level=tf.Level and tp.FormPart=d.Form
  left join Scoring.TestForms tf2 on tf2.AdministrationID=@FormPublishAdministrationID and tf2.Test=d.Test and tf2.Level=d.Level and tf2.Form=tp.Form
  cross apply (select TestVersion=replace(replace(replace(convert(varchar,max(FormVersion),121),':','.'),'-','.'),' ','.') from Scoring.TestFormVersions tfv where tfv.AdministrationID=@FormPublishAdministrationID and tfv.Test=tf.Test and tfv.Level=tf.Level and tfv.Form=tf.Form) v
  order by d.TicketOrder
)

select 
  AdminCode,AdminDescription,Token,StudentName,FirstName,LastName,StudentID,StateStudentID,DistrictStudentID,BirthDate,Gender,Grade,SiteName,DistrictName,SchoolName,DistrictCode,SchoolCode,
  ContinuousMultiModule,TestSessionID,TestSessionName,TestSessionStatus,TestType,TestName,Label,OptionalItems,TestMonitoring,TestAccessControl,RequireSecureExtension,
  AllowChat,AllowIntervention,AllowAlerts,
  (
    select Name=case when Name like '%:%' then left(Name,len(Name)-2) else Name end,Value,DisplayName
    from (select distinct Name,Value='Y',DisplayName from @a) Accommodation
    where Name not like '%:%' or right(Name,1) in (select PartName from f)
    for xml auto,type,root('Accommodations')
  ),(
    select Name,Value
    from Student.Extensions Demographic
    where AdministrationID=@_AdministrationID and StudentID=@StudentID and Category='Demographic'
    for xml auto,type,root('Demographics')
  ),(
    select ClientConfiguration
  ),(
    select
      OverallAbility=coalesce(ts.Ability,InitialAbilities.DefaultAbility2,InitialAbilities.DefaultAbility),
      (
        select * 
        from (select Ability=coalesce(ts.Ability,d.DefaultAbility2,d.DefaultAbility),DiagnosticCategory=d.CategoryID from #d d 
        left join #t ts on  ts.Score=d.Score 
        where (d.CategoryID!='0' and (d.DefaultAbility is not null or d.DefaultAbility2 is not null))) InitialAbility
        where Ability is not null
        order by cast(DiagnosticCategory as int)            
        for xml auto,type
      )
    from #d InitialAbilities
    left join #j ts on ts.Level=@Level and ts.Score=InitialAbilities.Score
    where InitialAbilities.Score='ALL'
    for xml auto,type
    ),(
      select SiteLevel=case when SchoolCode='' then 'District' else 'School' end,Name,Value
      from Site.Extensions SiteExtension
      where AdministrationID=@_AdministrationID and DistrictCode=@DistrictCode and (SchoolCode=@SchoolCode or SchoolCode='')
      for xml auto,type,root('SiteExtensions')
    ),(
      select
        TicketID,Form,Part,TestModel,TestVersion,
        TestStartTime,
        Status=case when @NotLock is null then case when Status='In Progress' and 
          isnull(TestUnlockTime,TestStartTime)<dateadd(hh,@LockOffset,Convert(DateTime, DATEDIFF(DAY, 0, getdate()))) 
          and getdate()>dateadd(hh,@LockOffset,Convert(DateTime, DATEDIFF(DAY, 0, getdate())))  
          then 'Locked' else Status end else Status end,
        Telemetry,FormSessionName,
        LCID
      from (select * from f) Part
      order by StudentID,TestSession,PartOrder,PartName
      for xml auto,type, root('Parts')
    )    
from StudentProfile
for xml auto,elements,type;
;
GO
