USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[rdupe]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[rdupe] as 
select registrationid,n=count(*)
from core.testsession
where registrationid is not null
group by registrationid
having count(*)>1
GO
