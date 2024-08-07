USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTestWindows]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetTestWindows]
@AdministrationID INT
AS
Begin

	Select ts.AdministrationID
	, ts.TestWindow
	, ts.Description
	, ts.StartDate
	, ts.EndDate
	, CAST(ts.IsDefault AS BIT) AS IsDefault
	, CAST(ts.AllowSessionDateEdits AS BIT) AS AllowSessionDateEdits
	, HasAssociatedSessions = Cast( case when sum(case when s.AdministrationID is null then 0 else 1 end) >0 then 1 else 0 end as BIT)
	From [Admin].TestWindow ts
	left join Core.TestSession s on s.AdministrationID = ts.AdminiStrationID 
		And s.TestWindow = ts.TestWindow
	Where ts.AdministrationID = @AdministrationID 
	group by 
	  ts.AdministrationID	
	, ts.TestWindow
	, ts.Description
	, ts.StartDate
	, ts.EndDate
	, ts.IsDefault
	, ts.AllowSessionDateEdits
	
End
GO
