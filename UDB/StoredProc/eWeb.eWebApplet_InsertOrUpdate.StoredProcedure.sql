USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[eWebApplet_InsertOrUpdate]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[eWebApplet_InsertOrUpdate]
       @AppletCode varchar(10),
       @Descr varchar(100),
	   @MenuKey varchar(100) = null 
AS
--Check parameter values
IF LTRIM(@AppletCode) = '' OR LTRIM(@Descr) = '' 
BEGIN 
		RAISERROR ('Empty Parameter in AppletCode or Descr for [eWebApplet_InsertOrUpdate]', 1, 1);
		RETURN;
END



IF EXISTS(Select * From [eWeb].[Applet] Where [AppletCode] = @AppletCode)
BEGIN
       Update [eWeb].[Applet]
       Set [Descr] = @Descr, [MenuKey] = @MenuKey
       Where [AppletCode] = @AppletCode
END
ELSE
BEGIN
       Insert Into [eWeb].[Applet] ([AppletCode], [Descr],[MenuKey])
       Values (@AppletCode, @Descr, @MenuKey)
END
GO
