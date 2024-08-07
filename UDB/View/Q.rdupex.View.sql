USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[rdupex]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[rdupex] as 
select q.registrationid,w.administrationid,w.testsessionid,m,c,a
from q.rdupe q
join core.testsession w on w.registrationid=q.registrationid
cross apply (select m=max(testsessionid) from core.testsession x where x.registrationid=w.registrationid) m
cross apply (select c=count(*) from testsession.links x where x.administrationid=w.administrationid and x.testsessionid=w.testsessionid) k
cross apply (select a=case when w.testsessionid<m and c=0 then 'change' else '' end) a
GO
