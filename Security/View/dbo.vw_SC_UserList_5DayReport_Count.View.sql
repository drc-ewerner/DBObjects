USE [Alaska_security_dev]
GO
/****** Object:  View [dbo].[vw_SC_UserList_5DayReport_Count]    Script Date: 7/2/2024 9:45:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_SC_UserList_5DayReport_Count]
AS
SELECT     COUNT(*) AS UserCount, AdminId
FROM         dbo.vw_SC_UserList_NotLoggedInDistrictAndBelow_rpt
GROUP BY AdminId
GO
