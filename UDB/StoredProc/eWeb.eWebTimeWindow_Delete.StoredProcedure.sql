USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[eWebTimeWindow_Delete]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[eWebTimeWindow_Delete]
       @ID int
AS
--Check parameter values
IF @ID IS NULL OR @ID < 0
BEGIN 
		RAISERROR ('Invalid @ID specified for [eWebTimeWindow_Delete]', 1, 1);
		RETURN;
END

IF EXISTS(Select * From [eWeb].[TimeWindow] Where [TimeWindowId] = @ID)
BEGIN

	Delete From [eWeb].[TimeWindow]
	Where [TimeWindowId] = @ID

END
GO
