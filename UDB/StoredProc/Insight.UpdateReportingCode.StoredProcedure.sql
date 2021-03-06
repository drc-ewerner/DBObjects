USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[UpdateReportingCode]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Insight].[UpdateReportingCode]
      @AdministrationID  int,
      @DocumentId int,
	  @ReportingCode varchar(20) = null
as
update Document.TestTicket set reportingcode=@ReportingCode where AdministrationID = @AdministrationID and DocumentID = @DocumentId
GO
