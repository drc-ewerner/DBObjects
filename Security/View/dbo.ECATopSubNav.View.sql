USE [Alaska_security_dev]
GO
/****** Object:  View [dbo].[ECATopSubNav]    Script Date: 1/12/2022 2:05:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ECATopSubNav] AS
SELECT n.*,  t.ECATopNavPermission, t.LegacyQueryStringAppValue
FROM ECATopNav t
INNER JOIN ECANav n
	ON n.Client = t.Client AND n.ECATopNav = t.ECATopNav
GO
