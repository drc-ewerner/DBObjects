USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ConfigExtensionValues_InsertOrUpdate]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[ConfigExtensionValues_InsertOrUpdate]
        @NamesID integer,
		@PossibleValue varchar(1500),
		@SortOrder Integer
AS
--Check parameter values
IF (LTRIM(@NamesID) = '' OR ISNULL(@SortOrder, '') = '')
BEGIN 
		RAISERROR ('Empty Parameter was supplied for [eWeb].[ConfigExtensionValues_InsertOrUpdate]', 1, 1);
		RETURN;
END

IF NOT EXISTS(Select * From [eWeb].[ConfigExtensionValues] Where NamesID = @NamesID And PossibleValue = @PossibleValue)
BEGIN
       INSERT INTO [eWeb].[ConfigExtensionValues] (NamesID, PossibleValue, SortOrder)
	   VALUES (@NamesID, @PossibleValue, @SortOrder)
END

GO
