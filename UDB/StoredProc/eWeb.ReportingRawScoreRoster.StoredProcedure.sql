USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportingRawScoreRoster]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [eWeb].[ReportingRawScoreRoster]
	@AdministrationID int,
    @ContentArea varchar(50),
    @Grade varchar(2),
	@District varchar(15),
    @School varchar(15)

	
as
BEGIN

DECLARE @localAdminID INT, @localContentArea VARCHAR(50), @localGrade VARCHAR(2), @localDistrict VARCHAR(15), @localSchool VARCHAR(15)
SET @localAdminID = @AdministrationID
SET @localContentArea = @ContentArea
SET @localGrade = @Grade
SET @localDistrict = @District
SET @localSchool = @School

set xact_abort on; set nocount on; set transaction isolation level read uncommitted;
 
declare @t table (Test varchar(50))
insert into @t
select Test from Scoring.Tests
where AdministrationID=@localAdminID and ContentArea=@localContentArea

declare @ns table (Test varchar(50), Level varchar(20), NumSessions int)
insert into @ns
select PartTest, Level, (select count(distinct PartName)) from Scoring.TestSessionTicketParts
where AdministrationID=@localAdminID and PartTest in (select Test from @t)
group by PartTest, Level

if (@@ROWCOUNT=0) begin
	insert into @ns
	select f.Test, f.Level, (select count(distinct isnull(PartName,'')))
	from Scoring.TestForms f
	left join Scoring.TestFormParts p on p.AdministrationID=f.AdministrationID and p.Test=f.Test and p.Level=f.Level and p.Form=f.Form
	/* the following was added because NE has ticket parts that don't contain any OP items, causing the results to not display */
	AND EXISTS(SELECT * FROM Scoring.TestFormItems tfi
				INNER JOIN Scoring.Items i
				ON i.AdministrationID = tfi.AdministrationID AND i.Test = tfi.test AND i.ItemID = tfi.ItemID
					AND i.ItemStatus = 'OP'
				WHERE tfi.AdministrationID = p.AdministrationID AND tfi.Test = p.test AND tfi.Form = p.FormPart)

	where f.AdministrationID=@localAdminID and f.Test in (select Test from @t) and 
		  f.OnlineData is not null 
	group by f.Test, f.Level;
		  
end;

with GetResponseData as (
select distinct ts.AdministrationID,ts.DistrictCode,ts.SchoolCode,tt.Test,tt.Level,l.DocumentID,l.StudentID,tt.BaseDocumentID,
	tr.ItemID,tr.Response,i.ItemStatus,id.CorrectResponse
from Core.TestSession ts
inner join TestSession.Links l on ts.AdministrationID=l.AdministrationID and ts.TestSessionID=l.TestSessionID
inner join Document.TestTicketView tt on ts.AdministrationID=tt.AdministrationID and l.DocumentID=tt.DocumentID
cross apply (select *, ROW_NUMBER() over (Partition by DocumentID order by CreateDate desc) as RowNum from
	Insight.OnlineTests t where ts.AdministrationID=t.AdministrationID and l.DocumentID=t.DocumentID) ot
inner join Insight.OnlineTestResponses tr on ts.AdministrationID=tr.AdministrationID and ot.OnlineTestID=tr.OnlineTestID
inner join Scoring.Items i on ts.AdministrationID=i.AdministrationID and tr.ItemID=i.ItemID
inner join Scoring.ItemDetails id on ts.AdministrationID=id.AdministrationID and tr.ItemID=id.ItemID
inner join @ns ns on tt.Test=ns.Test and tt.Level=ns.Level
where ts.AdministrationID=@localAdminID and ts.DistrictCode=@localDistrict and ts.SchoolCode=@localSchool and
	i.ItemType='MC' and i.ItemStatus='OP' 
	and ot.RowNum=1 and isnull(tt.NotTestedCode,'')='' and tt.Status='Completed'
)

select rd.AdministrationID,rd.DistrictCode,rd.SchoolCode,@localContentArea as ContentArea,s.Grade,rd.StudentID,
	s.FirstName,s.MiddleName,s.LastName,s.Birthdate,s.StateStudentID,
	count(*) as Questions,sum(case when rd.Response = rd.CorrectResponse then 1 else 0 end) as Correct,
	round((sum(case when rd.Response = rd.CorrectResponse then 1.0 else 0.0 end)/count(*))*100,0) as PercentCorrect,
	rd.Test,rd.Level
from GetResponseData rd
inner join Core.Student s on rd.AdministrationID=s.AdministrationID and rd.StudentID=s.StudentID
inner join @ns ns on rd.Test=ns.Test and rd.Level=ns.Level
where s.Grade = @localGrade or @localGrade = ''
group by rd.AdministrationID,rd.DistrictCode,rd.SchoolCode,s.Grade,rd.BaseDocumentID,rd.StudentID,
	s.FirstName,s.MiddleName,s.LastName,s.Birthdate,s.StateStudentID,ns.NumSessions,rd.Test,rd.Level
having count(distinct DocumentID) = ns.NumSessions
order by rd.StudentID
END
GO
