USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[UpdateReportingCode]    Script Date: 11/21/2023 8:56:09 AM ******/
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
