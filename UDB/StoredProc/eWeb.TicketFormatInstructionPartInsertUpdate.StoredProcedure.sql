USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[TicketFormatInstructionPartInsertUpdate]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[TicketFormatInstructionPartInsertUpdate]
	@TicketFormatInstructionPartGuid UNIQUEIDENTIFIER,
	@TicketFormatInstructionGuid UNIQUEIDENTIFIER,
	@Title VARCHAR(400),
	@TitleBold BIT = 0,
	@TitleUnderlined BIT = 0,
	@TextOrdered BIT = 0
	WITH RECOMPILE
AS
	BEGIN
	    SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		IF EXISTS (SELECT TicketFormatInstructionPartGuid FROM eWeb.TicketFormatInstructionPart WHERE TicketFormatInstructionPartGuid = @TicketFormatInstructionPartGuid)
			BEGIN
				UPDATE
					eWeb.TicketFormatInstructionPart
				SET
					Title = @Title,
					TitleBold = @TitleBold,
					TitleUnderlined = @TitleUnderlined,
					TextOrdered = @TextOrdered
				WHERE
					TicketFormatInstructionPartGuid = @TicketFormatInstructionPartGuid;
			END
		ELSE
			BEGIN
				INSERT INTO eWeb.TicketFormatInstructionPart
					(TicketFormatInstructionPartGuid,
					 TicketFormatInstructionGuid,
					 Title,
					 TitleBold,
					 TitleUnderlined,
					 TextOrdered)
				VALUES
					(@TicketFormatInstructionPartGuid,
					 @TicketFormatInstructionGuid,
					 @Title,
					 @TitleBold,
					 @TitleUnderlined,
					 @TextOrdered);
			END;
	END;

GO
