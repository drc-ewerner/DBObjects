USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentsWithScores]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [eWeb].[GetStudentsWithScores]
	@AdministrationID as integer,
	@DistrictCode varchar(15),
	@SchoolCode varchar(15)
as

 select distinct stu.LastName, stu.FirstName, stu.StudentID, stu.StateStudentID
    from Core.TestEvent te
    inner join Core.Document doc on te.AdministrationID= doc.AdministrationID and te.DocumentID=doc.DocumentID
    inner join Core.Student stu on doc.AdministrationID=stu.AdministrationID and stu.StudentID=doc.StudentID
    inner join Scoring.TestMapScores ms on ms.AdministrationID=te.AdministrationID and ms.Test=te.Test
    inner join Scoring.TestScoreExtensions dc on dc.AdministrationID=ms.AdministrationID and dc.Test=ms.Test and dc.Score=ms.Score and dc.Name='DiagnosticCategoryID'
    inner join TestEvent.TestScores ts on ts.AdministrationID=te.AdministrationID and ts.TestEventID=te.TestEventID and ts.Test=te.Test and ts.Score=ms.Score
     Where stu.AdministrationID=@AdministrationID and
					stu.DistrictCode=@DistrictCode and stu.SchoolCode=@SchoolCode
GO
