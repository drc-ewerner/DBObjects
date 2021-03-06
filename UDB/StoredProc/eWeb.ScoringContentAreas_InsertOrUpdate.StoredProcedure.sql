USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[ScoringContentAreas_InsertOrUpdate]    Script Date: 1/12/2022 1:30:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[ScoringContentAreas_InsertOrUpdate]
       @AdministrationID int, 
	   @ContentArea varchar(50),
	   @IsForAccommodations bit,
	   @IsForTestSessions bit,
	   @DisplayDescription varchar(50) = null,
	   @DisplayOrder int = null
AS
--Check parameter values
IF LTRIM(@ContentArea) = '' 
BEGIN 
		RAISERROR ('Empty Parameter in ContentArea for [ScoringContentAreas_InsertOrUpdate]', 1, 1);
		RETURN;
END



IF EXISTS(Select * From [Scoring].[ContentAreas] Where [AdministrationID] = @AdministrationID and ContentArea = @ContentArea)
BEGIN
       Update [Scoring].[ContentAreas]
       Set  IsForAccommodations = @IsForAccommodations, 
			IsForTestSessions = @IsForTestSessions,
			DisplayDescription = @DisplayDescription,
			DisplayOrder = @DisplayOrder
       Where  [AdministrationID] = @AdministrationID and ContentArea = @ContentArea
END
ELSE
BEGIN
       Insert Into [Scoring].[ContentAreas] (AdministrationID,ContentArea,IsForAccommodations,IsForTestSessions,DisplayDescription,DisplayOrder)
       Values (@AdministrationID,@ContentArea,@IsForAccommodations,@IsForTestSessions,@DisplayDescription,@DisplayOrder)
END
GO
