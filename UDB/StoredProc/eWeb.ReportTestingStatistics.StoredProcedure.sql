USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportTestingStatistics]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Joe Calderon
-- Create date: 12/19/2011
-- Updated:		3/1/2012
-- Description:	Returns the "Testing Statistics" in the most granular form needed
-- =============================================
CREATE PROCEDURE [eWeb].[ReportTestingStatistics]
	@administrationID integer,
	@reportDate date,
	@cumulative bit
AS

	SET FMTONLY OFF;

	DECLARE @reportDatetime as datetime
	
	select @reportDatetime = DATEADD(HOUR, 23, CAST(@reportDate as datetime)) 
	select @reportDatetime = DATEADD(MINUTE, 59, @reportDatetime) 
	select @reportDatetime = DATEADD(SECOND, 59, @reportDatetime) 
	

	CREATE TABLE #studentStatus
	(
		AdministrationID int, 
		StudentID int, 
		DocumentID int,
		TestSessionID int,
		Test varchar(50), 
		EffectiveStatusTime datetime,
		StartedTests int,
		EndedTests int
 	)

	-- Get the "Started" tests. The Max() ensures we get only the most recent status for a test ticket
	Insert into #studentStatus (AdministrationID,StudentID, DocumentID, TestSessionID, Test, EffectiveStatusTime, StartedTests, EndedTests)
	Select a.AdministrationID, s.StudentID, d.documentID, cts.TestSessionID, cts.Test, max(StatusTime) EffectiveStatusTime, 1, 0
	from [Core].[Student] s
	inner join [Core].Administration a on a.AdministrationID = s.AdministrationID
	inner join [TestSession].[Links]  tsl on tsl.StudentID = s.StudentID 
				and tsl.AdministrationID = a.AdministrationID 
				and tsl.StudentID = s.StudentID
	inner join [Core].[Document] d on d.DocumentID = tsl.DocumentID
	inner join [Core].TestSession cts on cts.TestSessionID = tsl.TestSessionID
	inner join [Document].[TestTicketStatus] tts on tts.DocumentID = d.DocumentID 
				and tts.AdministrationID = a.AdministrationID
	where a.AdministrationID = @administrationID
			and ((StatusTime >= @reportDate and StatusTime <= @reportDatetime and @cumulative = 0)
				or (StatusTime <= @reportDatetime and @cumulative = 1))
			and (tts.Status = 'In Progress' or tts.Status = 'Unlocked')
			and cts.DistrictCode not in ('88888', '412345678')		
	group by  a.AdministrationID, s.StudentID, d.documentID, cts.TestSessionID, cts.Test
	UNION
	-- Get the "Ended" tests. The Max() ensures we get only the most recent status for a test ticket
	Select a.AdministrationID, s.StudentID, d.documentID, cts.TestSessionID, cts.Test, max(StatusTime) EffectiveStatusTime, 0, 1
	from [Core].[Student] s
	inner join [Core].Administration a on a.AdministrationID = s.AdministrationID
	inner join [TestSession].[Links]  tsl on tsl.StudentID = s.StudentID 
				and tsl.AdministrationID = a.AdministrationID 
				and tsl.StudentID = s.StudentID
	inner join [Core].[Document] d on d.DocumentID = tsl.DocumentID
	inner join [Core].TestSession cts on cts.TestSessionID = tsl.TestSessionID
	inner join [Document].[TestTicketStatus] tts on tts.DocumentID = d.DocumentID 
				and tts.AdministrationID = a.AdministrationID
	where a.AdministrationID = @administrationID
			and ((StatusTime >= @reportDate and StatusTime <= @reportDatetime and @cumulative = 0)
				or (StatusTime <= @reportDatetime and @cumulative = 1))
			and tts.Status = 'Completed'
			and cts.DistrictCode not in ('88888', '412345678')	
	group by  a.AdministrationID, s.StudentID, d.documentID, cts.TestSessionID, cts.Test

	-- Return the report data
	SELECT 
	 st.ContentArea as ContentArea, 
	 cts.DistrictCode as DistrictCode, 
	 cs.SiteName as DistrictName,
	 s.Grade as Grade, 
	 EffectiveStatusTime as EffectiveStatusTime, 
	 SUM(StartedTests) as StartedTests,
	 SUM(EndedTests) as EndedTests
	 from #studentStatus ss
	inner join [Core].TestSession cts on cts.AdministrationID = ss.AdministrationID 
										and cts.TestSessionID = ss.TestSessionID
	inner join [Scoring].[Tests] st on st.AdministrationID = ss.AdministrationID
										and st.Test = cts.Test
	inner join [Core].[Student] s on s.StudentID = ss.StudentID
	inner join [Core].[Site] cs on cs.AdministrationID = ss.AdministrationID
									and cs.SiteCode = cts.DistrictCode
									and cs.SiteType = 'District'
	group by st.ContentArea, cts.DistrictCode, cs.SiteName, s.Grade, EffectiveStatusTime
	order by st.ContentArea, cts.DistrictCode, cs.SiteName, s.Grade, EffectiveStatusTime
GO
