USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[SubTestLevels_InsertOrUpdate]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	  		CREATE PROC [eWeb].[SubTestLevels_InsertOrUpdate]
			    @AdminID INT
			  , @TestSessionID INT
			  , @SubTestLevel XML
		AS
		BEGIN
			DECLARE @testCount INT
			DECLARE @inserts TABLE
			(
				SubTest VARCHAR(50)
				, SubLevel VARCHAR(20)
			)

			INSERT INTO @inserts
			SELECT 
				  Tbl.Col.value('SubTest[1]', 'VARCHAR(50)')
				, Tbl.Col.value('SubLevel[1]', 'VARCHAR(20)')
			FROM @SubTestLevel.nodes('//ArrayOfSubTestLevel/SubTestLevel') Tbl(Col)

			
			SELECT @testCount = COUNT(*) FROM Core.TestSession WHERE TestSessionId = @TestSessionID AND ScoringOption != 'EducatorScored'

			IF (@testCount > 0)
			BEGIN
				--Add FTSubTest and FTSubLevel in the items to be inserted
				INSERT INTO @inserts
				SELECT FTSubtest, FTSubLevel
				  FROM Scoring.TestSessionSubTestLevels stl
					   INNER JOIN @inserts i ON stl.SubLevel = i.SubLevel AND stl.SubTest = i.SubTest
				 WHERE FTSubTest IS NOT NULL AND FTSubLevel IS NOT NULL
			END

			INSERT INTO TestSession.SubTestLevels
			SELECT @AdminID, @TestSessionID, SubTest, SubLevel
			FROM @inserts
			WHERE NOT EXISTS(SELECT * FROM TestSession.SubTestLevels stl
								INNER JOIN @inserts i ON i.SubTest = stl.SubTest AND i.SubLevel = stl.SubLevel
								WHERE stl.AdministrationID = @AdminID AND stl.TestSessionID = @TestSessionID)
		END
	
GO
