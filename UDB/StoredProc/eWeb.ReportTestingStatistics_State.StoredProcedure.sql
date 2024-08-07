USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportTestingStatistics_State]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


		CREATE PROCEDURE [eWeb].[ReportTestingStatistics_State]
			 @administrationID integer
			,@reportDate       date
			,@cumulative       bit
	 
		AS

			SET NOCOUNT ON
	
			DECLARE @reportDatetime as datetime
	
			select @reportDatetime = DATEADD(HOUR, 23, CAST(@reportDate as datetime)) 
			select @reportDatetime = DATEADD(MINUTE, 59, @reportDatetime) 
			select @reportDatetime = DATEADD(SECOND, 59, @reportDatetime) 
	
			BEGIN TRY
				DROP TABLE #studentStatus
			END TRY
			BEGIN CATCH PRINT 'Create #studentStatus Table' END CATCH

			CREATE TABLE #studentStatus
			(
				AdministrationID int, 
				StudentID int, 
				DocumentID int,
				TestSessionID int,
				Test varchar(50), 
				EffectiveStatusTime datetime,
				StartedTests int,
				EndedTests int,
				TotalTests int,
				Grade varchar(2),
				DistrictCode varchar(15)
 			)

			-- Get the "Started" tests. The Max() ensures we get only the most recent status for a test ticket
			Insert into #studentStatus (AdministrationID,StudentID, DocumentID, TestSessionID, Test, EffectiveStatusTime, StartedTests, EndedTests, TotalTests,Grade,DistrictCode)
			Select a.AdministrationID, s.StudentID, d.documentID, cts.TestSessionID, cts.Test, max(StatusTime) EffectiveStatusTime, 1, 0, 1,s.Grade,cts.DistrictCode
			from [Core].[Student] s
			inner join [Core].Administration a on a.AdministrationID = s.AdministrationID
			inner join [TestSession].[Links]  tsl on tsl.StudentID = s.StudentID 
						and tsl.AdministrationID = a.AdministrationID 
						and tsl.StudentID = s.StudentID
			inner join [Core].[Document] d on d.DocumentID = tsl.DocumentID
						and d.AdministrationID = tsl.AdministrationID
			inner join [Core].TestSession cts on cts.TestSessionID = tsl.TestSessionID
						and cts.AdministrationID = tsl.AdministrationID
			inner join [Document].[TestTicketStatus] tts on tts.DocumentID = d.DocumentID 
						and tts.AdministrationID = a.AdministrationID
			where a.AdministrationID = @administrationID
					and ((StatusTime >= @reportDate and StatusTime <= @reportDatetime and @cumulative = 0)
						or (StatusTime <= @reportDatetime and @cumulative = 1))
					and (tts.Status = 'In Progress' or tts.Status = 'Unlocked')
					and cts.DistrictCode not in ('88888', '412345678')		
			group by  a.AdministrationID, s.StudentID, d.documentID, cts.TestSessionID, cts.Test,s.Grade,cts.DistrictCode
			UNION
			-- Get the "Ended" tests. The Max() ensures we get only the most recent status for a test ticket
			Select a.AdministrationID, s.StudentID, d.documentID, cts.TestSessionID, cts.Test, max(StatusTime) EffectiveStatusTime, 0, 1, 1,s.Grade,cts.DistrictCode
			from [Core].[Student] s
			inner join [Core].Administration a on a.AdministrationID = s.AdministrationID
			inner join [TestSession].[Links]  tsl on tsl.StudentID = s.StudentID 
						and tsl.AdministrationID = a.AdministrationID 
						and tsl.StudentID = s.StudentID
			inner join [Core].[Document] d on d.DocumentID = tsl.DocumentID
						and d.AdministrationID = tsl.AdministrationID
			inner join [Core].TestSession cts on cts.TestSessionID = tsl.TestSessionID
						and cts.AdministrationID = tsl.AdministrationID
			inner join [Document].[TestTicketStatus] tts on tts.DocumentID = d.DocumentID 
						and tts.AdministrationID = a.AdministrationID
			where a.AdministrationID = @administrationID
					and ((StatusTime >= @reportDate and StatusTime <= @reportDatetime and @cumulative = 0)
						or (StatusTime <= @reportDatetime and @cumulative = 1))
					and tts.Status IN ('Completed', 'Submitted')
					and cts.DistrictCode not in ('88888', '412345678')
			group by  a.AdministrationID, s.StudentID, d.documentID, cts.TestSessionID, cts.Test,s.Grade,cts.DistrictCode
			UNION
			-- Get the "Ended" tests. The Max() ensures we get only the most recent status for a test ticket
			Select a.AdministrationID, s.StudentID, d.documentID, cts.TestSessionID, cts.Test, max(StatusTime) EffectiveStatusTime, 0, 0, 1,s.Grade,cts.DistrictCode
			from [Core].[Student] s
			inner join [Core].Administration a on a.AdministrationID = s.AdministrationID
			inner join [TestSession].[Links]  tsl on tsl.StudentID = s.StudentID 
						and tsl.AdministrationID = a.AdministrationID 
						and tsl.StudentID = s.StudentID
			inner join [Core].[Document] d on d.DocumentID = tsl.DocumentID
						and d.AdministrationID = tsl.AdministrationID
			inner join [Core].TestSession cts on cts.TestSessionID = tsl.TestSessionID
						and cts.AdministrationID = tsl.AdministrationID
			inner join [Document].[TestTicketStatus] tts on tts.DocumentID = d.DocumentID 
						and tts.AdministrationID = a.AdministrationID
			where a.AdministrationID = @administrationID
					and tts.Status IN ('Not Started', 'Regenerated.Password')
					and cts.DistrictCode not in ('88888', '412345678')	
			group by  a.AdministrationID, s.StudentID, d.documentID, cts.TestSessionID, cts.Test,s.Grade,cts.DistrictCode

			/* Return the "All Tests" data */
			SELECT ISNULL(SUM(TotalTests), 0)   AS Total
				  ,ISNULL(SUM(StartedTests), 0) AS StartedTests
				  ,ISNULL(SUM(EndedTests), 0)   AS EndedTests
			FROM #studentStatus

			--/* Return the "By Subject" data */
			SELECT st.ContentArea    AS ContentArea
				  ,SUM(StartedTests) AS StartedTests
				  ,SUM(EndedTests)   AS EndedTests
			FROM #studentStatus ss
			INNER JOIN [Scoring].[Tests]  st  ON  st.AdministrationID  = ss.AdministrationID
											  AND st.Test              = ss.Test
			GROUP BY st.ContentArea
			ORDER BY st.ContentArea
	
			--/* Return the "By Grade" data */
			SELECT ss.Grade           AS Grade
				  ,SUM(StartedTests) AS StartedTests
				  ,SUM(EndedTests)   AS EndedTests
			FROM #studentStatus ss
			GROUP BY ss.Grade
			ORDER BY ss.Grade
	
			--/* Return the "By Subject and Grade" data */
			SELECT st.ContentArea    AS ContentArea
				  ,ss.Grade           AS Grade
				  ,SUM(StartedTests) AS StartedTests
				  ,SUM(EndedTests)   AS EndedTests
			FROM #studentStatus ss
			INNER JOIN [Scoring].[Tests]  st  ON  st.AdministrationID  = ss.AdministrationID
											  AND st.Test              = ss.Test
			GROUP BY st.ContentArea
					,ss.Grade
			ORDER BY st.ContentArea
					,ss.Grade
	
			--/* Return the "By District" data */
			SELECT ss.DistrictCode  AS DistrictCode
				  ,cs.SiteName       AS DistrictName
				  ,SUM(StartedTests) AS StartedTests
				  ,SUM(EndedTests)   AS EndedTests
			FROM #studentStatus ss
			INNER JOIN [Core].[Site]      cs  ON  cs.AdministrationID  = ss.AdministrationID
											  AND cs.SiteCode          = ss.DistrictCode
											  AND cs.SiteType          = 'District'
			GROUP BY ss.DistrictCode
					,cs.SiteName
			ORDER BY DistrictCode
	
			/* Return the "By Date" data */
			SELECT CONVERT(varchar(10), EffectiveStatusTime, 101)
									 AS [Date]
				  ,SUM(StartedTests) AS StartedTests
				  ,SUM(EndedTests)   AS EndedTests
			FROM #studentStatus
			GROUP BY CONVERT(varchar(10), EffectiveStatusTime, 101)
			ORDER BY [Date] DESC
			--drop table #studentStatus

	   
GO
