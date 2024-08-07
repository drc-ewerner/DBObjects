USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAssessmentScheduleForSchoolByGrade]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetAssessmentScheduleForSchoolByGrade]
@AdministrationID INT,
@DistrictCode varchar(15),
@SchoolCode varchar(15),
@Grade varchar(2)
AS
Begin
    
    Declare @TestWindow varchar(20)
    Declare @AssignmentLevel varchar(10)

    Select @TestWindow=TestWindow
    From [Site].[TestWindows]
    Where AdministrationID = @AdministrationID
    And DistrictCode = @DistrictCode
    And SchoolCode = @SchoolCode 

    Select @AssignmentLevel = 'School'

    if @TestWindow is null 
    begin
        Select @TestWindow=TestWindow 
        From [Site].[TestWindows]
        Where AdministrationID = @AdministrationID
        And DistrictCode = @DistrictCode
        And SchoolCode = ''
        
        Select @AssignmentLevel = 'District'		

        if @TestWindow is null 
        begin
            Select @TestWindow= TestWindow 
            From [Admin].TestWindow
            Where AdministrationID = @AdministrationID
            And IsDefault = 1

            Select @AssignmentLevel = 'Default'		
        end
    end


    Select ts.TestWindow
    , ts.[Description]
    , ts.StartDate
    , ts.EndDate
    , cast(ts.IsDefault AS BIT) as IsDefault
    , cast(ts.AllowSessionDateEdits AS BIT) AS AllowSessionDateEdits
    , AssignmentLevel = @AssignmentLevel
    , a.Mode
    , t.ContentArea
    , a.Test
    , a.Level
    , AssessmentText=isnull(tl.[Description],tl.Level)
    , a.StartDate As AssessmentScheduleBeginDate
    , a.EndDate As AssessmentScheduleEndDate
    , CAST(a.AllowReactivates AS BIT) AS AllowReactivates
    , CAST(a.AllowEdits AS BIT) AS AllowEdits
	, tl.OptionalProcessing
    From [Admin].[TestWindow] ts
    Inner Join [Admin].AssessmentSchedule a On ts.AdministrationID = a.AdministrationID and ts.TestWindow = a.TestWindow
    Inner Join Scoring.Tests t ON a.AdministrationID = t.AdministrationID and a.Test = t.Test
    Inner Join Scoring.ContentAreas ca ON t.AdministrationID = ca.AdministrationID and t.ContentArea = ca.ContentArea
    inner join Scoring.TestLevels tl ON a.AdministrationID = tl.AdministrationID and a.Test = tl.Test and a.Level = tl.Level
    left join Config.Extensions ext on ext.AdministrationID=tl.AdministrationID and ext.Category='eWeb' and ext.Name=tl.Test + '.' + tl.Level + '.Hide'
    left join Config.Extensions ext2 on ext2.AdministrationID=tl.AdministrationID and ext2.Category='eWeb' and ext2.Name=t.ContentArea + '.Hide'
    join Scoring.TestLevelGrades tlg on a.Level = tlg.Level and t.test = tlg.test AND t.AdministrationID = tlg.AdministrationID
    Where t.AdministrationID = @AdministrationID 
    And ts.TestWindow = @TestWindow
    And isnull(ext.Value, 'N') = 'N' 
    And isnull(ext2.Value, 'N') = 'N' 
    And ca.IsForTestSessions = 1
    and tlg.Grade = @Grade
    Order By tl.DisplayOrder,tl.Description
End
GO
