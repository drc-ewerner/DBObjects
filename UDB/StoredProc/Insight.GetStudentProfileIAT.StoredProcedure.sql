USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetStudentProfileIAT]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Insight].[GetStudentProfileIAT]
	@AdministrationID int,
	@Username varchar(50),
    @Password varchar(20)

as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

declare @StudentID int,
	@Test varchar(20),
	@Level varchar(20);

select  @StudentID = StudentID 
from student.InsightUsername
where AdministrationID = @AdministrationID and Username = @Username and Password = @Password;

declare @d table (
	DocumentID int not null,
	Status varchar(50) not null,
	TestSessionId int not null,
	TestSessionName varchar(100),
	Test varchar(20),
	Level varchar(20),
	Form varchar(20) null,
	StartTime datetime null,
	UnlockTime datetime null,
	Label varchar(1000) null,
	SiteName varchar(50) null
);	

insert @d (DocumentID,Status,TestSessionId,TestSessionName,Test,Level,Form,StartTime,UnlockTime,Label,SiteName)
select t.DocumentID,t.Status,ts.TestSessionID,ts.name,t.Test,t.Level,t.Form,t.StartTime,t.UnlockTime,Label=Description,SiteName 
from Document.TestTicketViewEx t
inner join TestSession.links k on t. documentid = k.DocumentID and t.AdministrationID = k.AdministrationID
inner join core.student cs on cs.AdministrationID = k.AdministrationID and cs.StudentID = k.StudentID
inner join core.site si on si.AdministrationID = cs.AdministrationID and si.SuperSiteCode = cs.DistrictCode and si.SiteCode = cs.SchoolCode
inner join core.testsession ts on ts.TestSessionID = k.TestSessionID and ts.AdministrationID = k.AdministrationID
inner join scoring.TestLevels st on st.AdministrationID = ts.AdministrationID and st.test = ts.test and st.level = ts.level
where t.AdministrationID=@AdministrationID and k.studentid = @StudentID
and getdate() between ts.StartTime and dateadd(day,1,ts.EndTime)
and t.Status <> 'Completed';

--Accommodations support
declare @AccomTest table (
	Test varchar(50)
);

declare @a table (Name varchar(50) not null,Value varchar(100) not null);

insert @AccomTest (Test)
select Test from @d;

insert @a (Name,Value)
select Name,Value
from Student.Extensions
where AdministrationID=@AdministrationID and StudentID=@StudentID and Category in (select ContentArea from Scoring.Tests where AdministrationID=@AdministrationID and Test in (select Test from @AccomTest)) and Value='Y'
union
select Name,Value
from Config.Extensions
where AdministrationID=@AdministrationID and Category like 'Accommodation.Auto.%' and parsename(Category,1) in (select ContentArea from Scoring.Tests where AdministrationID=@AdministrationID and Test in (select Test from @AccomTest)) and Value='Y'
;
--end Accommodations support

select @StudentID=k.StudentID,@Test=ts.Test,@Level=ts.Level
from Document.TestTicketViewEx t
inner join TestSession.Links k on k.AdministrationID=t.AdministrationID and k.DocumentID=t.DocumentID
inner join Core.TestSession ts on ts.AdministrationID=t.AdministrationID and ts.TestSessionID=k.TestSessionID
where t.AdministrationID=@AdministrationID and t.DocumentID in (select DocumentID from @d);

with StudentProfile as (
    select 
        AdminCode=AdministrationCode,
        Token=newid(),
        StudentName=isnull(FirstName,'')+' '+ltrim(isnull(MiddleName,'')+' ')+isnull(LastName,''),
        StudentID=StudentID,
        StateStudentID=StateStudentID,
		DistrictStudentID=DistrictStudentID,
        BirthDate=BirthDate,
        Gender=Gender,
        Grade=Grade,
		ClientConfiguration,
		Telemetry
	from Core.Student s
	inner join Core.Administration a on a.AdministrationID=s.AdministrationID
	outer apply (select ClientConfiguration=Value from Config.XmlOptions where AdministrationID=@AdministrationID and Name='ClientConfiguration') cc
	outer apply (select Telemetry=cast(Value as xml) from Config.Extensions where AdministrationID=@AdministrationID and Category='Telemetry' and Name=@Test+'.'+@Level) telemetry
	where s.AdministrationID=@AdministrationID and s.StudentID=@StudentID
),f as (
	select 
		d.DocumentID as TicketID,d.Test,TestModel=isnull(tf.Format,'FixedIAT'),d.Level,d.Form,d.StartTime as TestStartTime,d.Status,d.TestSessionID,d.TestSessionName,d.Label,d.SiteName,
		TestVersion=left(TestVersion,13)+substring(TestVersion,15,2)+substring(TestVersion,18,2)
	from @d d
	left join Scoring.TestForms tf on tf.AdministrationID=@AdministrationID and tf.Test=@Test and tf.Level=@Level and tf.Form=d.Form
	cross apply (select TestVersion=replace(replace(replace(convert(varchar,max(FormVersion),121),':','.'),'-','.'),' ','.') from Scoring.TestFormVersions tfv where tfv.AdministrationID=tf.AdministrationID and tfv.Test=tf.Test and tfv.Level=tf.Level and tfv.Form=tf.Form) v
)
select 
	AdminCode,Token,StudentName,StudentID,StateStudentID,DistrictStudentID,BirthDate,Gender,Grade,
    (	--adding support for Accommodations
		select Name,Value 
		from (select distinct Name,Value='Y' from @a) Accommodation
		for xml auto,type,root('Accommodations')
	),(
        select
			TicketID
			,Test
			,TestModel
			,TestVersion
			,Level
			,Form
			,TestStartTime
			,Status
			,TestSessionID
			,TestSessionName
			,Label
			,SiteName
        from (select * from f) Part
		order by TicketID
        for xml auto,type, root('Parts')
    )		
from StudentProfile
for xml auto,elements,type;
;
GO
