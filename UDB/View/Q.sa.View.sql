USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[sa]    Script Date: 11/21/2023 8:54:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[sa] as
select s.participantid,s.administrationid,s.studentid,s.statestudentid,category,name,value
from core.student s
join student.extensions x on x.administrationid=s.administrationid and x.studentid=s.studentid
where x.category in (select category from xref.cedsmap m where m.cedsgroup='Accommodation' union all select contentarea from scoring.tests t where t.administrationid=s.administrationid) and x.value='Y';
GO
