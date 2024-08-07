USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAdministrationsByCopyWindow]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*  *****************************************************************
    * Description:  This proc returns a list of administration by copy window
    *================================================================
    * Created:      9/9/2014
    * Developer:    Julie Cheah
    *================================================================
    * Changes:
    *
    * Date:         
    * Developer:    
    * Description:  Added comment block
    *****************************************************************
*/




CREATE procedure [eWeb].[GetAdministrationsByCopyWindow]
	
as
begin
	select a.AdministrationID from Core.Administration a
	inner join eWeb.TimeWindow w on w.AdministrationID = a.AdministrationID
	where w.AppletCode = 'SDEC'
	and w.EndDate > getdate()
end
GO
