USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[TicketFormatInstructionInsertUpdate]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[TicketFormatInstructionInsertUpdate]
	@TicketFormatInstructionGuid UNIQUEIDENTIFIER,
	@TicketFormatGuid UNIQUEIDENTIFIER,
	@InstructionTitle VARCHAR(200),
	@IsInstructionTitleBold BIT = 0,
	@IsInstructionTItleUnderlined BIT = 0,
	@ShowChildrenAsList BIT = 0
	WITH RECOMPILE
AS
	BEGIN
		SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		IF EXISTS (SELECT TicketFormatInstructionGuid FROM eWeb.TicketFormatInstruction WHERE TicketFormatInstructionGuid = @TicketFormatInstructionGuid)
			BEGIN
				UPDATE
					eWeb.TicketFormatInstruction
				SET
					InstructionTitle = @InstructionTitle,
					IsInstructionTitleBold = @IsInstructionTitleBold,
					IsInstructionTitleUnderlined = @IsInstructionTItleUnderlined,
					ShowChildrenAsList = @ShowChildrenAsList
				WHERE
					TicketFormatInstructionGuid = @TicketFormatInstructionGuid;
			END
		ELSE
			BEGIN
				INSERT INTO eWeb.TicketFormatInstruction
					(TicketFormatInstructionGuid,
					 TicketFormatGuid,
					 InstructionTitle,
					 IsInstructionTitleBold,
					 IsInstructionTitleUnderlined,
					 ShowChildrenAsList)
				VALUES
					(@TicketFormatInstructionGuid,
					 @TicketFormatGuid,
					 @InstructionTitle,
					 @IsInstructionTitleBold,
					 @IsInstructionTItleUnderlined,
					 @ShowChildrenAsList);
			END;
	END;

GO
