USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[TicketFormatInstructionTextInsertUpdate]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[TicketFormatInstructionTextInsertUpdate]
	@TicketFormatInstructionTextGuid UNIQUEIDENTIFIER,
	@TicketFormatInstructionPartGuid UNIQUEIDENTIFIER,
	@InstructionText VARCHAR(1000)
	WITH RECOMPILE
AS
	BEGIN
		SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		IF EXISTS (SELECT TicketFormatInstructionTextGuid FROM eWeb.TicketFormatInstructionText WHERE TicketFormatInstructionTextGuid = @TicketFormatInstructionTextGuid)
			BEGIN
				UPDATE
					eWeb.TicketFormatInstructionText
				SET
					InstructionText = @InstructionText
				WHERE
					TicketFormatInstructionTextGuid = @TicketFormatInstructionTextGuid;
			END
		ELSE
			BEGIN
				INSERT INTO eWeb.TicketFormatInstructionText
					(TicketFormatInstructionTextGuid,
					 TicketFormatInstructionPartGuid,
					 InstructionText)
				VALUES
					(@TicketFormatInstructionTextGuid,
					 @TicketFormatInstructionPartGuid,
					 @InstructionText);
			END;
	END;

GO
