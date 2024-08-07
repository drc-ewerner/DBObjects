USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[TicketFormatInsertUpdate]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[TicketFormatInsertUpdate]
	@TicketFormatGuid UNIQUEIDENTIFIER,
	@TicketFormatName VARCHAR(40),
	@IsAdministrationNameFixed BIT = 0,
	@AdministrationNameText VARCHAR(200),
	@InstructionHeader VARCHAR(200),
	@Summary VARCHAR(400),
	@Note VARCHAR(400),
	@IsAccommodationRequired BIT = 0,
	@IsSISCodeRequired BIT = 0,
	@IsFormRequired BIT = 0,
	@IsSignatureRequired BIT = 0,
	@HasSignInSignOutColumn BIT = 0,
	@Use2014Heaaders BIT = 0,
	@IsStudentRosterDateOfBirth BIT = 0,
	@IsDistrictStudentIDRequired BIT = 0,
	@IsPartRequired BIT = 0
	WITH RECOMPILE
AS
	BEGIN
		SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		IF EXISTS (SELECT TicketFormatGuid FROM eWeb.TicketFormat WHERE TicketFormatGuid = @TicketFormatGuid)
			BEGIN
				UPDATE
					eWeb.TicketFormat
				SET
					TicketFormatName = @TicketFormatName,
					IsAdministrationNameFixed = @IsAdministrationNameFixed,
					AdministrationNameText = @AdministrationNameText,
					InstructionHeader = @InstructionHeader,
					Summary = @Summary,
					Note = @Note,
					IsAccommodationRequired = @IsAccommodationRequired,
					IsSISCodeRequired = @IsSISCodeRequired,
					IsFormRequired = @IsFormRequired,
					IsSignatureRequired = @IsSignatureRequired,
					HasSignInSignOutColumn = @HasSignInSignOutColumn,
					Use2014Heaaders = @Use2014Heaaders,
					IsStudentRosterDateOfBirth = @IsStudentRosterDateOfBirth,
					IsDistrictStudentIDRequired = @IsDistrictStudentIDRequired,
					IsPartRequired = @IsPartRequired
				WHERE
					TicketFormatGuid = @TicketFormatGuid;
			END
		ELSE
			BEGIN
				INSERT INTO eWeb.TicketFormat
					   (TicketFormatGuid
					   ,TicketFormatName
					   ,IsAdministrationNameFixed
					   ,AdministrationNameText
					   ,InstructionHeader
					   ,Summary
					   ,Note
					   ,IsAccommodationRequired
					   ,IsSISCodeRequired
					   ,IsFormRequired
					   ,IsSignatureRequired
					   ,HasSignInSignOutColumn
					   ,Use2014Heaaders
					   ,IsStudentRosterDateOfBirth
					   ,IsDistrictStudentIDRequired
					   ,IsPartRequired)
				 VALUES
					   (@TicketFormatGuid,
					    @TicketFormatName, 
					    @IsAdministrationNameFixed,
					    @AdministrationNameText,
					    @InstructionHeader,
					    @Summary,
					    @Note,
					    @IsAccommodationRequired,
					    @IsSISCodeRequired,
					    @IsFormRequired,
					    @IsSignatureRequired,
					    @HasSignInSignOutColumn,
					    @Use2014Heaaders,
					    @IsStudentRosterDateOfBirth,
					    @IsDistrictStudentIDRequired,
						@IsPartRequired)
			END;
	END;

GO
