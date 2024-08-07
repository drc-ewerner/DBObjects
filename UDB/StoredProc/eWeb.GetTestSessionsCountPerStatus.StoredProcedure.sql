USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTestSessionsCountPerStatus]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [eWeb].[GetTestSessionsCountPerStatus]
	@AdministrationID int,
	@Test varchar(50)=null,
	@TestLevel varchar(20)=null
as

with q as (
	select 
		s.AdministrationID, 
		s.TestSessionID,		
		MinStatus=min(tx.Status),
		MaxStatus=max(tx.Status),
		MinSubmitted=min(case when tx.Status='Completed' then 'Submitted' else tx.Status end)
	from Core.TestSession s
	inner join Scoring.Tests t on
	t.AdministrationID=s.AdministrationID and t.Test=s.Test
	inner join Scoring.TestLevels tl on tl.AdministrationID=s.AdministrationID and tl.Test=s.Test and tl.Level=s.Level
	inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and k.TestSessionID=s.TestSessionID
	inner join Document.TestTicketView tx on tx.AdministrationID=s.AdministrationID and tx.DocumentID=k.DocumentID
	inner join Core.Document doc on tx.AdministrationID=doc.AdministrationID and tx.DocumentID=doc.DocumentID
	where
		s.AdministrationID=@AdministrationID 
		and (s.Test=@Test )
		and (s.Level=@TestLevel) 
		and not exists(select * from Config.Extensions x where x.AdministrationID=s.AdministrationID and x.Category='eWeb' and x.Name=s.Test+'.'+s.Level+'.Hide')
		and t.ContentArea not like '$%' and
	tl.Description not like '$%'      
	group by s.AdministrationID,s.TestSessionID
)
select
   q.AdministrationID, Status, count(*) as 'Count'
from q
cross apply (select Status=case when MaxStatus in (MinStatus,MinSubmitted) and not (MinStatus='Completed' and MaxStatus='Not Started') then MaxStatus else 'In Progress' end) Status
Group By q.AdministrationID, Status
GO
