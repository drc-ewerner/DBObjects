USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[TicketFormatInstructionInsertUpdate]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[TicketFormatInstructionInsertUpdate]
	@TicketFormatInstructionGuid UNIQUEIDENTIFIER,
	@TicketFormatGuid UNIQUEIDENTIFIER,
	@InstructionText VARCHAr(400),
	@InstructionTitle VARCHAR(2000),
	@IsInstructionTitleBold BIT = 0,
	@IsInstructionTItleUnderlined BIT = 0,
	@ShowChildrenAsList BIT = 0,
	@ID TINYINT = NULL
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
					InstructionText = @InstructionText,
					InstructionTitle = @InstructionTitle,
					IsInstructionTitleBold = @IsInstructionTitleBold,
					IsInstructionTitleUnderlined = @IsInstructionTItleUnderlined,
					ShowChildrenAsList = @ShowChildrenAsList,
					ID = @ID
				WHERE
					TicketFormatInstructionGuid = @TicketFormatInstructionGuid;
			END
		ELSE
			BEGIN
				INSERT INTO eWeb.TicketFormatInstruction
					(TicketFormatInstructionGuid,
					 TicketFormatGuid,
					 InstructionText,
					 InstructionTitle,
					 IsInstructionTitleBold,
					 IsInstructionTitleUnderlined,
					 ShowChildrenAsList,
					 ID)
				VALUES
					(@TicketFormatInstructionGuid,
					 @TicketFormatGuid,
					 @InstructionText,
					 @InstructionTitle,
					 @IsInstructionTitleBold,
					 @IsInstructionTItleUnderlined,
					 @ShowChildrenAsList,
					 @ID);
			END;
	END;

GO
