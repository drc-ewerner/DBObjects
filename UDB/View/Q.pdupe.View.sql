USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[pdupe]    Script Date: 11/21/2023 8:54:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[pdupe] as 
select participantid,administrationid,n=count(*)
from core.student
where participantid is not null
group by participantid,administrationid
having count(*)>1
GO
