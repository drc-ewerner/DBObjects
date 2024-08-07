USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[rdupe2]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[rdupe2] as
select q.registrationid,k.administrationid,k.testsessionid,change=nullif(max(testsessionid) over (partition by q.registrationid),k.testsessionid) from q.rdupe1 q
join q.rk k on k.registrationid=q.registrationid
group by q.registrationid,k.administrationid,k.testsessionid
GO
