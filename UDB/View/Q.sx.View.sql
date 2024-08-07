USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[sx]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[sx] as
select s.participantid,s.administrationid,s.studentid,category,name,value
from core.student s
join student.extensions x on x.administrationid=s.administrationid and x.studentid=s.studentid
GO
