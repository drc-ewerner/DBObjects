USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_ModifyUserPermFromService]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eWeb_ModifyUserPermFromService]
	@userId UNIQUEIDENTIFIER,
	@administrationCode VARCHAR(10),
	@districtCode VARCHAR(50) = NULL,
	@schoolCode VARCHAR(50) = NULL,
	@screenCode VARCHAR(100),
	@addRemove VARCHAR(6),
	@role VARCHAR(50)
	
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @AdministrationID INT;
	DECLARE @UserIdStr VARCHAR(36) = CONVERT(VARCHAR(36), @userId)
	DECLARE @CurrentDate DATETIME = GETDATE();
	DECLARE @RoleID INT;
	DECLARE @ProfileId INT;
	DECLARE @PermissionID INT;
	DECLARE @UpdaterUserId UNIQUEIDENTIFIER 
	DECLARE @AuditId INT
	DECLARE @addValue VARCHAR(10) = 'add';

	IF EXISTS (SELECT AdministrationID FROM dbo.eWebAdministration WHERE AdministrationCode = @administrationCode AND ((EndDate >= @CurrentDate) OR EndDate IS NULL))
		BEGIN
			SET @AdministrationID = (SELECT TOP 1 AdministrationID FROM dbo.eWebAdministration WHERE AdministrationCode = @administrationCode);

			IF EXISTS (SELECT UserID FROM dbo.aspnet_Users WHERE UserID = @userId)
				BEGIN
					
					--------------------------------------------------------------------------
					-- Check if role exists
					--------------------------------------------------------------------------
					IF EXISTS (SELECT RoleId FROM dbo.eWebRole WHERE RoleName = @role)
						SET @RoleID = (SELECT TOP 1 RoleId FROM dbo.eWebRole WHERE RoleName = @role)
					ELSE
						RAISERROR (N'Role ''%s'' is not valid', 16, 0, @role);

					--------------------------------------------------------------------------
					-- Create or update user profile.
					-- Profile is unique by user, admin, role, district and school
					--------------------------------------------------------------------------
					SET @districtCode = ISNULL(@districtCode, '');
					SET @schoolCode = ISNULL(@schoolCode, '');
					IF LOWER(@addRemove) = @addValue
						BEGIN
							IF NOT EXISTS (SELECT ProfileId FROM dbo.eWebUserProfile WHERE UserId = @userId AND AdminId = @AdministrationID AND [Role] = @Role AND
																						   ISNULL(DistrictCode, '') = @districtCode AND ISNULL(SchoolCode, '') = @schoolCode)
								INSERT INTO dbo.eWebUserProfile (UserId, [Role], AdminId, DistrictCode, SchoolCode, RoleID) VALUES (@userId, @role, @AdministrationID, @districtCode, @schoolCode, @RoleID);

						END;

					SET @ProfileId = (SELECT TOP 1 ProfileId FROM dbo.eWebUserProfile WHERE UserId = @userId AND AdminId = @AdministrationID AND [Role] = @Role AND
																							ISNULL(DistrictCode, '') = @districtCode AND ISNULL(SchoolCode, '') = @schoolCode);

					--------------------------------------------------------------------------
					-- Update user permission
					--------------------------------------------------------------------------
					IF EXISTS (SELECT s.PermissionID FROM dbo.eWebScreen AS s WHERE s.ScreenCode = @screenCode AND
                       EXISTS (SELECT PermissionTopNavECA FROM dbo.eWebMapPermToECA AS e WHERE e.ScreenCode = @screenCode))
						BEGIN
							SET @PermissionID = (SELECT TOP 1 s.PermissionID FROM dbo.eWebScreen AS s WHERE s.ScreenCode = @screenCode);

							SET @UpdaterUserId = (SELECT TOP 1 UserId FROM dbo.aspnet_Users
							                      WHERE LoweredUserName LIKE 'eis-superuser%' OR LoweredUserName LIKE 'legacy-edirect-superuser%' OR LoweredUserName = 'superuser')
							SET @UpdaterUserId = ISNULL(@UpdaterUserId, '00000000-0000-0000-0000-000000000000');

							IF LOWER(@addRemove) = @addValue
								BEGIN
									IF NOT EXISTS (SELECT ScreenAccessId FROM dbo.eWebScreenAccess WHERE ProfileId = @ProfileId AND PermissionID = @PermissionID)
										BEGIN
											INSERT INTO dbo.eWebScreenAccess (ProfileId, PermissionID) VALUES (@ProfileId, @PermissionID)

											INSERT INTO ewebUserAudit (UserId,  ChangedBy) VALUES (@UserId, @UpdaterUserId)
											SET @AuditId = SCOPE_IDENTITY()
											INSERT INTO eWebUserPermissionAudit (UserAuditID, AdminID, [Role], PermissionID, [Action]) VALUES (@AuditId, @AdministrationID, @role, @PermissionID, 'Add');

										END;
								END
							ELSE
								BEGIN
									IF EXISTS (SELECT ScreenAccessId FROM dbo.eWebScreenAccess WHERE ProfileId = @ProfileId AND PermissionID = @PermissionID)
										BEGIN
											DELETE FROM dbo.eWebScreenAccess WHERE ProfileId = @ProfileId AND PermissionID = @PermissionID

											INSERT INTO ewebUserAudit (UserId,  ChangedBy) VALUES (@UserId, @UpdaterUserId)
											SET @AuditId = SCOPE_IDENTITY()
											INSERT INTO eWebUserPermissionAudit (UserAuditID, AdminID, [Role], PermissionID, [Action]) VALUES (@AuditId, @AdministrationID, @role, @PermissionID, 'Remove');

										END;

									-- If the user no long has any permissions for the profile then remove the profile.
									IF NOT EXISTS (SELECT ScreenAccessId FROM dbo.eWebScreenAccess WHERE ProfileId = @ProfileId)
										BEGIN
											DELETE FROM dbo.eWebUserProfile WHERE ProfileId = @ProfileId;
										END;
								END;
						END
					ELSE
						RAISERROR (N'Screen Code ''%s'' is not valid', 16, 0, @screenCode);

				END
			ELSE
				RAISERROR (N'User ''%s'' does not exist', 16, 0, @UserIdStr);
		END
	ELSE
		RAISERROR (N'Administration %s is not valid', 16, 0, @administrationCode);
END;
GO
