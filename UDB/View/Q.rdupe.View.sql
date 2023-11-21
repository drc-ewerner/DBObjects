USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[rdupe]    Script Date: 11/21/2023 8:54:52 AM ******/
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
