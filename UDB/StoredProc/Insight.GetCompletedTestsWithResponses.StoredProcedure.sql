USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetCompletedTestsWithResponses]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Insight].[GetCompletedTestsWithResponses]
	@AdministrationID int, 
	@DistrictCode varchar(15) = '', 
	@SchoolCode varchar(15) = '', 
	@Grade varchar(2) = '', 
	@StudentID int = 0
as
;
with LatestTest 
as 
(
	select AdministrationID, DocumentID, max(OnlineTestID) as OnlineTestID
	from Insight.OnlineTests
	where AdministrationID = @AdministrationID
	group by AdministrationID, DocumentID
)

select d.AdministrationID, d.LastName, d.FirstName, d.StudentID, d.StateStudentID, d.DistrictStudentID, d.Grade, g.SiteName as DistrictName, g.SiteCode as DistrictCode, h.SiteName as SchoolName, h.SiteCode as SchoolCode, f.Name as TestSessionName, i.EndTime as TestCompletedDate, j.Position as QuestionNumber, j.ExtendedResponse as QuestionResponse, '' as QuestionText, k.Description as AssessmentName,b.DocumentID
from LatestTest b
cross apply (select * from Insight.OnlineTestResponses o where o.AdministrationID = b.AdministrationID and o.OnlineTestID = b.OnlineTestID and o.ExtendedResponse is not null) j
cross apply (select top 1 * from TestSession.Links k where k.AdministrationID = b.AdministrationID and k.DocumentID = b.DocumentID) e
cross apply (select top 1 * from Core.TestSession w where w.AdministrationID = e.AdministrationID and w.TestSessionID = e.TestSessionID) f
cross apply (select top 1 * from Core.Student s where s.AdministrationID = b.AdministrationID and s.StudentID = e.StudentID) d
outer apply (select top 1 * from Core.Site s where s.AdministrationID = b.AdministrationID and s.SiteCode = f.DistrictCode and s.SiteType = 'District') g
outer apply (select top 1 * from Core.Site s where s.AdministrationID = b.AdministrationID and s.SiteCode = f.SchoolCode and s.SiteType = 'School') h
cross apply (select top 1 * from Document.TestTicketView d where d.AdministrationID = b.AdministrationID and d.DocumentID = b.DocumentID) i
cross apply (select top 1 * from Scoring.TestLevels s where s.AdministrationID = i.AdministrationID and s.Test = i.Test and s.Level = i.Level) k
where b.administrationid = @AdministrationID
    and isnull(f.DistrictCode,'') = case when len(@DistrictCode) > 0 then @DistrictCode else isnull(f.DistrictCode,'') end 
    and isnull(f.SchoolCode,'') = case when len(@SchoolCode) > 0 then @SchoolCode else isnull(f.SchoolCode,'') end
    and isnull(d.Grade,'') = case when len(@Grade) > 0 then @Grade else isnull(d.Grade,'') end
	and d.StudentID = case when @StudentID <> 0 then @StudentID else d.StudentID end
	and j.ExtendedResponse is not null
order by i.EndTime desc, d.LastName, d.FirstName
GO
