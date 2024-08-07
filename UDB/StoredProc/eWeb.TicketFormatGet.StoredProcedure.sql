USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[TicketFormatGet]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[TicketFormatGet]
	@TicketFormatName VARCHAR(40)
	WITH RECOMPILE
AS
	BEGIN
	    SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		DECLARE @TicketFormatGuid UNIQUEIDENTIFIER;

		IF EXISTS (SELECT TicketFormatGuid FROM eWeb.TicketFormat WHERE TicketFormatName = @TicketFormatName)
			BEGIN
				SET @TicketFormatGuid = (SELECT TicketFormatGuid FROM eWeb.TicketFormat WHERE TicketFormatName = @TicketFormatName);
				
				SELECT
					TicketFormatGuid,
					TicketFormatName,
					IsAdministrationNameFixed,
					AdministrationNameText,
					InstructionHeader,
					Summary,
					Note,
					IsAccommodationRequired,
					IsSISCodeRequired,
					ISFormRequired,
					IsSignatureRequired,
					HasSignInSignOutColumn,
					Use2014Heaaders,
					IsStudentRosterDateOfBirth,
					IsDistrictStudentIDRequired,
					IsPartRequired
				FROM
					eWeb.TicketFormat
				WHERE
					TicketFormatGuid = @TicketFormatGuid;

				SELECT
					TicketFormatGuid,
					TicketFormatInstructionGuid,
					InstructionTitle,
					IsInstructionTitleBold,
					IsInstructionTitleUnderlined,
					ShowChildrenAsList,
					InstructionText,
					ID
				FROM
					eWeb.TicketFormatInstruction
				WHERE
					TicketFormatGuid = @TicketFormatGuid
				ORDER BY
					OrderId;

				SELECT
					tfip.TicketFormatInstructionGuid,
					tfip.TicketFormatInstructionPartGuid,
					tfip.Title,
					tfip.TitleBold,
					tfip.TitleUnderlined,
					tfip.TextOrdered
				FROM
					eWeb.TicketFormatInstruction AS tfi
						JOIN
					eWeb.TicketFormatInstructionPart AS tfip
						ON tfi.TicketFormatInstructionGuid = tfip.TicketFormatInstructionGuid
				WHERE
					tfi.TicketFormatGuid = @TicketFormatGuid
				ORDER BY
					tfi.OrderId,
					tfip.OrderId;

				SELECT
					tfit.TicketFormatInstructionPartGuid,
					tfit.InstructionText
				FROM
					eWeb.TicketFormatInstruction AS tfi
						JOIN
					eWeb.TicketFormatInstructionPart AS tfip
						ON tfi.TicketFormatInstructionGuid = tfip.TicketFormatInstructionGuid
						JOIN
					eWeb.TicketFormatInstructionText AS tfit
						ON tfip.TicketFormatInstructionPartGuid = tfit.TicketFormatInstructionPartGuid
				WHERE
					tfi.TicketFormatGuid = @TicketFormatGuid
				ORDER BY
					tfi.OrderId,
					tfip.OrderId,
					tfit.OrderId;

			END
		ELSE
			BEGIN
				RAISERROR (N'Ticket Format Name %s does not exist', 16, 1, @TicketFormatName);
			END;
    END;
GO
