USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAllAssessments]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/********************************************************************
 * NOTES:
 *
 * @IncludeMode:
 * Pass in an empty string for @IncludeMode to ignore this variable.
 * Pass in 'Paper' to return only paper assessments.
 * Pass in 'Online' to return only online assessments.
 ********************************************************************/
CREATE PROCEDURE [eWeb].[GetAllAssessments]
@AdministrationID INT,
@IncludeMode VARCHAR(20)
AS
Begin

  Set @IncludeMode = ISNULL(@IncludeMode, '')

  Select 
	  s.[AdministrationID], 
	  s.[Test], 
	  s.[Level], 
	  s.[Mode], 
	  s.[TestWindow], 
	  s.[StartDate], 
	  s.[EndDate], 
	  s.[AllowReactivates], 
	  s.[AllowEdits]
  From [Admin].[AssessmentSchedule] s
  Where AdministrationID = @AdministrationID
  And (Case 
			When @IncludeMode = '' Then 1 --Include All Modes
			When UPPER(s.Mode) = UPPER(@IncludeMode) Then 1 --Include Only Modes Specified
			Else 0
		End) = 1
	
End
GO
