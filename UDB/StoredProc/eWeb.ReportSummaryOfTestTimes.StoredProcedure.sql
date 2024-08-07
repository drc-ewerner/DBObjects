USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ReportSummaryOfTestTimes]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [eWeb].[ReportSummaryOfTestTimes]
	@AdministrationID int,
	@StatusTime datetime,
	@DistrictCode varchar(15),
	@SchoolCode varchar(1000)
AS
BEGIN
	DECLARE @timeInterval VARCHAR(30)
	
	SET @timeInterval = eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','Documents.ReportSummary.TimeInterval','045')

	DECLARE @numTimes int

	SET @numTimes = COALESCE(TRY_CONVERT(int, @timeInterval),45)
	SET @numTimes = FLOOR(@numTimes/15) - 1  
	SET @numTimes = (CASE WHEN @numTimes < 1 THEN 1 ELSE @numTimes END)

	SET @timeInterval = '000-' + @timeInterval


	select
		cs.Grade,
		Subject=st.ContentArea,
		TimeSpan=case 
			when window=0 then @timeInterval 
			when window=20 then '300+' 
			else right('0'+ cast(window*15 as varchar),3)+'-'+right('0'+cast(window*15+15 as varchar),3) 
		end,
		Count=count(*)
	from Document.TestTicketView tt
	inner join Core.Document cd on cd.AdministrationID=tt.AdministrationID and cd.DocumentID=tt.DocumentID
	inner join Core.Student cs on cs.AdministrationID=cd.AdministrationID and cd.StudentID=cs.StudentID
	inner join Scoring.Tests st on st.AdministrationID=tt.AdministrationID and st.Test=tt.Test
	cross apply (select TestingTime=(tt.ElapsedTime/60000)/15) a
	cross apply (select Window=case when TestingTime<=@numTimes then 0 when TestingTime>=20 then 20 else TestingTime end) b
	where tt.AdministrationID=@AdministrationID 
			and (cs.DistrictCode = @DistrictCode or @DistrictCode = '')
			and (cs.SchoolCode in (select * from dbo.fn_SplitSchoolList(@SchoolCode, '|')) or @SchoolCode = '')
			and Status not in ('Not Started','In progress') 
			and (convert(varchar,StartTime,101)=convert(varchar,@StatusTime,101) or convert(varchar,EndTime,101)=convert(varchar,@StatusTime,101))
			and cs.DistrictCode not in ('88888', '412345678')	
	group by cs.Grade,st.ContentArea,Window
	order by cs.Grade,st.ContentArea,Window
	;
END


GO
