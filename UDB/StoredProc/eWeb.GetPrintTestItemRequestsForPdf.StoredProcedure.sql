USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetPrintTestItemRequestsForPdf]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [eWeb].[GetPrintTestItemRequestsForPdf]
	@AdminID int,
	@SessionID integer,
	@RequestIDs varchar(500)
AS

declare @RequestIDTable table (n int, RequestID int, RequestType varchar(100))
insert into @RequestIDTable (n, RequestID)
select * from Aux.SplitInts(@RequestIDs)



/*Return all data for this session*/
Select 
	pod.AdministrationID, 
	pod.RequestID, 
	pod.RequestType, 
	pod.Form, 
	pod.PassageID, 
	pod.PassageIndicator, 
	pod.ItemID, 
	pod.Position, 
	pod.StudentID, 
	pod.TestSessionID, 
	pod.ViewCount, 
	pod.CreateDate,
	cs.FirstName,
	cs.LastName,
	cs.DistrictCode,
	cs.SchoolCode
From [insight].[PrintOnDemandRequest] pod
inner join [Core].[Student] cs
	on pod.AdministrationID = cs.AdministrationID
	and pod.StudentID = cs.StudentID
inner join @RequestIDTable r
	on r.RequestID = pod.RequestID
Where pod.AdministrationID = @AdminID
	and pod.TestSessionID = @SessionID
GO
