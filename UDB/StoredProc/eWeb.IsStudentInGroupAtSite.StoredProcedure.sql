USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[IsStudentInGroupAtSite]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[IsStudentInGroupAtSite]
@AdministrationID INT, 
@StudentID INT, 
@DistrictCode varchar(15), 
@SchoolCode varchar(15)
AS
BEGIN

/* 1/21/2011 - Version 1.0 
	Returns the count of groups that the student is in at the given site.
	> 0 is a "true" result to IsStudentInGroupAtSite question
*/

select count(*) AS GroupCountAtSite
FROM StudentGroup.Links lnk 
	INNER JOIN Core.StudentGroup sg ON lnk.GroupID = sg.GroupID and lnk.AdministrationID = sg.AdministrationID
WHERE lnk.StudentId = @StudentId
and lnk.AdministrationID = @AdministrationID
and sg.DistrictCode = @DistrictCode
and sg.SchoolCode = @SchoolCode


END
GO
