USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[rdupe1]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[rdupe1] as 
select r.registrationid,n=count(distinct k.testsessionid)
from q.rdupe r
join core.testsession w on w.registrationid=r.registrationid
join testsession.links k on k.administrationid=w.administrationid and k.testsessionid=w.testsessionid
group by r.registrationid
having count(distinct k.testsessionid)>1
GO
