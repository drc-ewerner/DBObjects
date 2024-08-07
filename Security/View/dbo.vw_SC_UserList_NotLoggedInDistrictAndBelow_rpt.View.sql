USE [Alaska_security_dev]
GO
/****** Object:  View [dbo].[vw_SC_UserList_NotLoggedInDistrictAndBelow_rpt]    Script Date: 7/2/2024 9:45:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_SC_UserList_NotLoggedInDistrictAndBelow_rpt]
AS
SELECT     TOP (100) PERCENT CreateDate AS [Date Added], FirstName AS [First Name], LastName AS [Last Name], Email AS [Email Address], 
                      AddeByUser AS [Added By], LastPasswordChangedDate, AdminId
FROM         dbo.vw_SC_UserList_NotLoggedIn
WHERE     (userRole = 'District Admin') AND (DATEDIFF(d, GETDATE(), DATEADD(d, 5, LastPasswordChangedDate)) < 0)
ORDER BY [First Name], [Last Name]
GO
