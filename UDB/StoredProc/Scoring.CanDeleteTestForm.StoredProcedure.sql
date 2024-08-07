USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[CanDeleteTestForm]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Scoring].[CanDeleteTestForm]
	@AdministrationID int, 
	@Test varchar(50), 
	@Level varchar(20),
	@Form varchar(20)
AS
BEGIN

DECLARE @TRUE AS Bit
DECLARE @FALSE AS Bit
SET @TRUE = 1
SET @FALSE = 0

-- If real test event data exists in any of these tables, then we cannot delete the test form
IF EXISTS(SELECT * FROM [Core].[TestEvent]
		  WHERE [AdministrationID] = @AdministrationID  
				AND [Test] = ISNULL(@Test, [Test])
				AND [Level] = ISNULL(@Level, [Level])
				AND [Form] = ISNULL(@Form, [Form]))
BEGIN
	SELECT @FALSE
	RETURN 
END

IF EXISTS(SELECT * FROM [Document].[TestTicket]
		  WHERE [AdministrationID] = @AdministrationID  
				AND [Test] = ISNULL(@Test, [Test])
				AND [Level] = ISNULL(@Level, [Level])
				AND [Form] = ISNULL(@Form, [Form]))
BEGIN
	SELECT @FALSE
	RETURN	
END

SELECT @TRUE
RETURN 

END
GO
