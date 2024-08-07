USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[TestEvent_ItemCounts]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**********************************************************************************************
***  Utility Views
**********************************************************************************************/

create view [Q].[TestEvent_ItemCounts] as
select
	te.AdministrationID,
	te.TestEventID,
	te.Test,
	te.Level,
	te.Form,
	tfs.Score,
	counts.ItemsExpected,
	counts.DetailsExpected,
	counts.ItemsReceived,
	counts.DetailsReceived,
	counts.DetailsRescored
from Core.TestEvent te (nolock)
inner join Scoring.TestFormScores tfs (nolock) on tfs.AdministrationID=te.AdministrationID and tfs.Test=te.Test and tfs.Level=te.Level and tfs.Form=te.Form 
cross apply (
	select
		ItemsExpected=count(distinct tfsi.ItemID),
		DetailsExpected=isnull(sum(case when isnull(teis.RescoreFlag,0)=0 then 1 else 0 end),0),
		ItemsReceieved=count(distinct teis.ItemID),
		DetailsReceieved=isnull(sum(case when teis.RescoreFlag=0 then 1 else 0 end),0),
		DetailsRescored=isnull(sum(case when teis.RescoreFlag=1 then 1 else 0 end),0) 
	from Scoring.TestFormScoreItems tfsi (nolock) 
	left join  TestEvent.ItemScores teis (nolock) on teis.AdministrationID=tfsi.AdministrationID and teis.Test=tfsi.Test and teis.ItemID=tfsi.ItemID and teis.DetailID=tfsi.DetailID 
	where tfsi.AdministrationID=te.AdministrationID and tfsi.Test=te.Test and tfsi.Level=te.Level and tfsi.Form=te.Form and tfsi.Score=tfs.Score
) counts(ItemsExpected,DetailsExpected,ItemsReceived,DetailsReceived,DetailsRescored)
;
GO
