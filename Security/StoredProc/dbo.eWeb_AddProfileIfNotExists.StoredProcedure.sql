USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_AddProfileIfNotExists]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eWeb_AddProfileIfNotExists]
	@UserName VARCHAR(256), 
	@AdminId INT,
	@Role VARCHAR(50) = NULL,
	@DistrictCode VARCHAR(50) =  NULL,
	@SchoolCode VARCHAR(50) = NULL
	WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @UserId UNIQUEIDENTIFIER;
	DECLARE @RoleId INT = NULL;

	SET @DistrictCode = ISNULL(@DistrictCode, '');
	SET @SchoolCode = ISNULL(@SchoolCode, '');
	SET @Role = ISNULL(@Role, '');

	IF EXISTS (SELECT UserId FROM dbo.aspnet_Users WHERE UserName = @UserName)
		BEGIN
			SET @UserId = (SELECT TOP 1 UserId FROM dbo.aspnet_Users WHERE UserName = @UserName);
			IF EXISTS (SELECT RoleId FROM dbo.eWebRole WHERE RoleName = @Role)
				BEGIN
					SET @RoleId = (SELECT TOP 1 RoleId FROM dbo.eWebRole WHERE RoleName = @Role);

					IF NOT EXISTS (SELECT 
										ProfileId 
									FROM 
										dbo.eWebUserProfile 
									WHERE 
										UserId = @UserId AND
										AdminId = @AdminId AND
										ISNULL([Role], '') = @Role AND
										ISNULL(DistrictCode, '') = @DistrictCode AND
										ISNULL(SchoolCode, '') = @SchoolCode)
						BEGIN
							INSERT INTO dbo.eWebUserProfile (UserId, AdminId, [Role], DistrictCode, SchoolCode, RoleID) VALUES
							(@UserId, @AdminId, @Role, @DistrictCode, @SchoolCode, @RoleId);
						END;
				END;
		END;
END;
GO
