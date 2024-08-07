USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAssessmentByContentArea]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetAssessmentByContentArea]
@AdministrationID INT, @ContentArea VARCHAR (100)
AS
BEGIN

	IF @ContentArea = 'Mathematics'
	BEGIN
		SELECT 'Algebra 1' As Assessment
		UNION
		SELECT 'Algebra 2' As Assessment
		UNION
		SELECT 'Algebra 3' As Assessment
		UNION
		SELECT 'Algebra 4' As Assessment
		UNION
		SELECT 'Algebra 5' As Assessment		 
	END
	ELSE IF @ContentArea = 'Science' 
	BEGIN
		SELECT 'Science 1' As Assessment
		UNION
		SELECT 'Science 2' As Assessment
		UNION
		SELECT 'Science 3' As Assessment
		UNION
		SELECT 'Science 4' As Assessment
		UNION
		SELECT 'Science 5' As Assessment		 
	END
	ELSE IF @ContentArea = 'Reading'
	BEGIN
		SELECT 'Reading 1' As Assessment
		UNION
		SELECT 'Reading 2' As Assessment
		UNION
		SELECT 'Reading 3' As Assessment
		UNION
		SELECT 'Reading 4' As Assessment
		UNION
		SELECT 'Reading 5' As Assessment		 
	END
	
END
GO
