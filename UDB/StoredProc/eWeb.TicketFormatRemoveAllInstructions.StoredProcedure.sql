USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[TicketFormatRemoveAllInstructions]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[TicketFormatRemoveAllInstructions]
	@TicketFormatGuid UNIQUEIDENTIFIER
	WITH RECOMPILE
AS
	BEGIN
	    SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		DELETE
			eWeb.TicketFormatInstructionText
		FROM
			eWeb.TicketFormat AS tf
				JOIN
			eWeb.TicketFormatInstruction AS tfi
				ON tf.TicketFormatGuid = tfi.TicketFormatGuid
				JOIN
			eWeb.TicketFormatInstructionPart AS tfip
				ON tfi.TicketFormatInstructionGuid = tfip.TicketFormatInstructionGuid
				JOIN
			eWeb.TicketFormatInstructionText AS tfit 
				ON tfip.TicketFormatInstructionPartGuid = tfit.TicketFormatInstructionPartGuid
		WHERE
			tf.TicketFormatGuid = @TicketFormatGuid;

		DELETE
			eWeb.TicketFormatInstructionPart
		FROM
			eWeb.TicketFormat AS tf
				JOIN
			eWeb.TicketFormatInstruction AS tfi
				ON tf.TicketFormatGuid = tfi.TicketFormatGuid
				JOIN
			eWeb.TicketFormatInstructionPart AS tfip
				ON tfi.TicketFormatInstructionGuid = tfip.TicketFormatInstructionGuid
		WHERE
			tf.TicketFormatGuid = @TicketFormatGuid;

		DELETE
			eWeb.TicketFormatInstruction
		FROM
			eWeb.TicketFormat AS tf
				JOIN
			eWeb.TicketFormatInstruction AS tfi
				ON tf.TicketFormatGuid = tfi.TicketFormatGuid
		WHERE
			tf.TicketFormatGuid = @TicketFormatGuid;

	END;

GO
