USE [Alaska_security_dev]
GO
/****** Object:  View [dbo].[ECATopNavSingleLinks]    Script Date: 7/2/2024 9:45:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ECATopNavSingleLinks] AS
WITH tn AS 
(
	SELECT Client, ECATopNav
	FROM (SELECT DISTINCT Client, ECATopNav, ECASubNav FROM ECATopSubNav) q
	GROUP BY Client, ECATopNav
	HAVING COUNT(*) = 1
)
SELECT v.*
FROM tn
INNER JOIN (SELECT sq.*, ROW_NUMBER() OVER (PARTITION BY sq.Client, sq.ECATopNav ORDER BY CASE WHEN sq.LegacySubNav = 'N/A' THEN 1 ELSE 0 END) AS rn FROM ECATopSubNav sq) v 
	ON v.Client = tn.Client AND v.ECATopNav = tn.ECATopNav AND v.ECASubNav = 'N/A' AND v.rn = 1
GO
