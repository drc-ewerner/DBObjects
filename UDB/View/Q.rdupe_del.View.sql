USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[rdupe_del]    Script Date: 11/21/2023 8:54:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[rdupe_del] as 
select r.registrationid,w.administrationid,w.testsessionid
from q.rdupe r
join core.testsession w on w.registrationid=r.registrationid
where not exists(select * from testsession.links k where k.administrationid=w.administrationid and k.testsessionid=w.testsessionid)
GO
