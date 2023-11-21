USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[rk]    Script Date: 11/21/2023 8:54:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[rk] as 
select registrationid,k.*
from core.testsession w
join testsession.links k on k.administrationid=w.administrationid and k.testsessionid=w.testsessionid
where registrationid is not null
GO
