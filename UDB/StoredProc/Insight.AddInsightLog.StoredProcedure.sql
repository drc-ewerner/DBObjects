USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[AddInsightLog]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [Insight].[AddInsightLog]
	@AdministrationID int,
	@LogCode varchar(10),
	@Duration int
as
set xact_abort on; set nocount on; set transaction isolation level read uncommitted;

insert Insight.InsightLog (AdministrationID,LogCode,Duration) select @AdministrationID,@LogCode,@Duration;
GO
