USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTestTicketLayout]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [eWeb].[GetTestTicketLayout]
	@AdministrationID  int
	AS
BEGIN
	/* 8/30/2010 - Version 1.0 */
	/* 4/08/2014 - Version 1.1 */
	select TicketLayoutName=eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','TicketLayout','') 
END
GO
