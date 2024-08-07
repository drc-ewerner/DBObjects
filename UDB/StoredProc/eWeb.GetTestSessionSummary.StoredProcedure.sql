USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTestSessionSummary]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [eWeb].[GetTestSessionSummary]
	@AdministrationID int,
	@DistrictCode varchar(15)=null,
	@SchoolCode varchar(15)=null
	WITH RECOMPILE
as
/* 09/07/2010 - Version 1.0 */
with q as (
	select s.AdministrationID,s.TestSessionID,
	Status = case 
				when count(x.DocumentID) = sum(case when x.Status = 'Not Started' then 1 else 0 end) then 'Not Started'
				when count(x.DocumentID) = sum(case when x.Status = 'Submitted' then 1 else 0 end) then 'Submitted'
				when count(x.DocumentID) = sum(case when x.Status = 'Completed' then 1 else 0 end) then 'Completed'
					when count(x.DocumentID)  =sum(case when x.Status = 'Submitted' or x.Status = 'Completed' then 1 else 0 end)   then 'Submitted'
				else 'In Progress' 
			end
	from Core.TestSession s
	inner join Scoring.Tests AS tes ON s.AdministrationID = tes.AdministrationID and s.Test = tes.test
	inner join TestSession.Links k on k.AdministrationID=s.AdministrationID and k.TestSessionID=s.TestSessionID
	inner join Document.TestTicketView x on x.AdministrationID=s.AdministrationID and x.DocumentID=k.DocumentID
	inner join Scoring.TestLevels tl on x.AdministrationID = tl.AdministrationID and x.Test = tl.Test and x.Level = tl.level
	left join Config.Extensions ext on ext.AdministrationID=tl.AdministrationID and ext.Category='eWeb' and ext.Name=tl.Test + '.' + tl.Level + '.Hide'
	where s.AdministrationID=@AdministrationID
		and (DistrictCode =@DistrictCode or @DistrictCode = '')
		and (SchoolCode = @SchoolCode or @SchoolCode = '') and charindex('$',tes.ContentArea) =0  and charindex('$',isnull(tl.Description,tl.Level)) = 0
		and isnull(ext.Value, 'N') = 'N' and s.Mode in ('Online', 'Proctored')
	group by s.AdministrationID,s.TestSessionID
)
select Status,SessionCount=count(*)
from q
group by Status
GO
