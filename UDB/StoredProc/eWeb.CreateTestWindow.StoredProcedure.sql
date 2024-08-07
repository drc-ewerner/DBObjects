USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[CreateTestWindow]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*********************************************************************
 * This is the latest version as of 01/26/2015.
 * We are updating all UDB's to have this version so we are consistant
 * accross clients. 
 *********************************************************************/
CREATE PROCEDURE [eWeb].[CreateTestWindow]
@AdministrationID INT,
@Description varchar(100),
@StartDate DateTime,
@EndDate DateTime,
@IsDefault bit,
@AllowSessionDateEdits bit, 
@TestWindow varchar(20) OUTPUT
AS
Begin

declare @currentMaxInt INT

select @currentMaxInt = MAX(CAST( SUBSTRING( TestWindow,12,LEN( TestWindow) - 11) as INT)) 
from [Admin].TestWindow
where TestWindow like 'Test Window %'

if @currentMaxInt IS NULL
	set @TestWindow='Test Window 0'
else
	set @TestWindow = 'Test Window ' + cast((@currentMaxInt+1) as varchar(8))

INSERT INTO [Admin].TestWindow
           ([AdministrationID]
           ,[TestWindow]
           ,[Description]
           ,[StartDate]
           ,[EndDate]
           ,[IsDefault]
           ,[AllowSessionDateEdits])
     VALUES
           (@AdministrationID
           ,@TestWindow
           ,@Description
           ,@StartDate
           ,@EndDate
           ,@IsDefault
           ,@AllowSessionDateEdits)

End
GO
