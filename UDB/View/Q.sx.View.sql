USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[sx]    Script Date: 11/21/2023 8:54:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[sx] as
select s.participantid,s.administrationid,s.studentid,category,name,value
from core.student s
join student.extensions x on x.administrationid=s.administrationid and x.studentid=s.studentid
GO
