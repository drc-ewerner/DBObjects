USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[TicketFormatCopyAdmin]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[TicketFormatCopyAdmin]
	@TicketFormatNameFrom VARCHAR(40),
	@TicketFormatNameTo VARCHAR(40),
	@AdministrationNameText VARCHAR(200)
	WITH RECOMPILE
AS
	BEGIN
		SET NOCOUNT ON;
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		DECLARE @TicketFormatGuidFrom UNIQUEIDENTIFIER;
		DECLARE @TicketFormatGuidTo UNIQUEIDENTIFIER;
		DECLARE @TicketFormatInstructionGuidFrom UNIQUEIDENTIFIER;
		DECLARE @TicketFormatInstructionGuidTo UNIQUEIDENTIFIER;
		DECLARE @TicketFormatInstructionPartGuidFrom UNIQUEIDENTIFIER;
		DECLARE @TicketFormatInstructionPartGuidTo UNIQUEIDENTIFIER;
		DECLARE @TicketFormatInstructionTextGuidFrom UNIQUEIDENTIFIER;
		DECLARE @TicketFormatInstructionTextGuidTo UNIQUEIDENTIFIER;

		IF EXISTS (SELECT TicketFormatGuid FROM eWeb.TicketFormat WHERE TicketFormatName = @TicketFormatNameFrom)
			BEGIN
				IF NOT EXISTS (SELECT TicketFormatGuid FROM eWeb.TicketFormat WHERE TicketFormatName = @TicketFormatNameTo)
					BEGIN
						SET @TicketFormatGuidFrom = (SELECT TOP 1 TicketFormatGuid FROM eWeb.TicketFormat WHERE TicketFormatName = @TicketFormatNameFrom);
						SET @TicketFormatGuidTo = NEWID();

						INSERT INTO eWeb.TicketFormat 
							(TicketFormatGuid, 
							TicketFormatName, 
							[IsAdministrationNameFixed],
							[AdministrationNameText],
							[InstructionHeader],
							[Summary],
							[Note],
							[IsAccommodationRequired],
							[IsSISCodeRequired],
							[IsFormRequired],
							[HasSignInSignOutColumn],
							[Use2014Heaaders],
							[IsStudentRosterDateOfBirth],
							[IsDistrictStudentIDRequired],
							IsPartRequired)
						SELECT
							@TicketFormatGuidTo,
							@TicketFormatNameTo, 
							[IsAdministrationNameFixed],
							@AdministrationNameText,
							[InstructionHeader],
							[Summary],
							[Note],
							[IsAccommodationRequired],
							[IsSISCodeRequired],
							[IsFormRequired],
							[HasSignInSignOutColumn],
							[Use2014Heaaders],
							[IsStudentRosterDateOfBirth],
							[IsDistrictStudentIDRequired],
							IsPartRequired
						FROM
							eWeb.TicketFormat
						WHERE
							TicketFormatGuid = @TicketFormatGuidFrom;

						DECLARE curInstruction CURSOR FAST_FORWARD FOR SELECT [TicketFormatInstructionGuid] FROM [eWeb].[TicketFormatInstruction] WHERE [TicketFormatGuid] = @TicketFormatGuidFrom;
						OPEN curInstruction
						FETCH NEXT FROM curInstruction INTO @TicketFormatInstructionGuidFrom;
						WHILE @@FETCH_STATUS = 0
							BEGIN
							    SET @TicketFormatInstructionGuidTo = NEWID();

								INSERT INTO eWeb.TicketFormatInstruction
									([TicketFormatInstructionGuid],
									 TicketFormatGuid,
									 InstructionText,
									 InstructionTitle,
									 IsInstructionTitleBold,
									 IsInstructionTitleUnderlined,
									 ShowChildrenAsList,
									 ID)
								SELECT
									@TicketFormatInstructionGuidTo,
									@TicketFormatGuidTo,
									InstructionText,
									InstructionTitle,
									IsInstructionTitleBold,
									IsInstructionTitleUnderlined,
									ShowChildrenAsList,
									ID
								FROM
									eWeb.TicketFormatInstruction
								WHERE
									TicketFormatInstructionGuid = @TicketFormatInstructionGuidFrom AND
									TicketFormatGuid = @TicketFormatGuidFrom
								ORDER BY
									OrderId;

								DECLARE curInstructionPart CURSOR FAST_FORWARD FOR SELECT [TicketFormatInstructionPartGuid] FROM [eWeb].[TicketFormatInstructionPart] WHERE [TicketFormatInstructionGuid] = @TicketFormatInstructionGuidFrom;
								OPEN curInstructionPart;
								FETCH NEXT FROM curInstructionPart INTO @TicketFormatInstructionPartGuidFrom;
								WHILE @@FETCH_STATUS = 0
									BEGIN

										SET @TicketFormatInstructionPartGuidTo = NEWID();

										INSERT INTO eWeb.TicketFormatInstructionPart
											(TicketFormatInstructionPartGuid,
											 TicketFormatInstructionGuid,
											 Title,
											 TitleBold,
											 TitleUnderlined,
											 TextOrdered)
										SELECT
											 @TicketFormatInstructionPartGuidTo,
											 @TicketFormatInstructionGuidTo,
											 Title,
											 TitleBold,
											 TitleUnderlined,
											 TextOrdered
										FROM
											eWeb.TicketFormatInstructionPart
										WHERE
											TicketFormatInstructionPartGuid = @TicketFormatInstructionPartGuidFrom AND
											TicketFormatInstructionGuid = @TicketFormatInstructionGuidFrom
										ORDER BY
											OrderId;

										DECLARE curInstructionText CURSOR FAST_FORWARD FOR SELECT TicketFormatInstructionTextGuid FROM eWeb.TicketFormatInstructionText WHERE TicketFormatInstructionPartGuid = @TicketFormatInstructionPartGuidFrom;
										OPEN curInstructionText;
										FETCH NEXT FROM curInstructionText INTO @TicketFormatInstructionTextGuidFrom;
										WHILE @@FETCH_STATUS = 0
											BEGIN
												SET @TicketFormatInstructionTextGuidTo = NEWID();

												INSERT INTO eWeb.TicketFormatInstructionText
													(TicketFormatInstructionTextGuid,
													 TicketFormatInstructionPartGuid,
													 InstructionText)
												SELECT
													@TicketFormatInstructionTextGuidTo,
													@TicketFormatInstructionPartGuidTo,
													InstructionText
												FROM
													eWeb.TicketFormatInstructionText
												WHERE
													TicketFormatInstructionTextGuid = @TicketFormatInstructionTextGuidFrom AND
													TicketFormatInstructionPartGuid = @TicketFormatInstructionPartGuidFrom
												ORDER BY
													OrderId;

												FETCH NEXT FROM curInstructionText INTO @TicketFormatInstructionTextGuidFrom;

											END;
										CLOSE curInstructionText;
										DEALLOCATE curInstructionText;

										FETCH NEXT FROM curInstructionPart INTO @TicketFormatInstructionPartGuidFrom;

									END;
								CLOSE curInstructionPart;
								DEALLOCATE curInstructionPart;

								FETCH NEXT FROM curInstruction INTO @TicketFormatInstructionGuidFrom;

							END;
						CLOSE curInstruction;
						DEALLOCATE curInstruction;
					END
				ELSE
					BEGIN
						RAISERROR(N'TicketFormat %s already exists', 16, 1, @TicketFormatNameTo);
					END
		    END
		ELSE
			BEGIN
				RAISERROR(N'TicketFormat %s does not exist', 16, 1, @TicketFormatNameFrom);
			END;
	END;

GO
