USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_UpdateeWebUserDemographics]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eWeb_UpdateeWebUserDemographics]
    @UserId UNIQUEIDENTIFIER, 
    @NamePrefix VARCHAR(10) = NULL,
    @FirstName VARCHAR(30) = NULL,
    @MiddleInitial VARCHAR(1) = NULL,
    @LastName VARCHAR(30) = NULL,
    @NameSuffix VARCHAR(10) = NULL,
    @AddrLine1 VARCHAR(50) = NULL,
    @AddrLine2 VARCHAR(50) = NULL,
    @City VARCHAR(30) = NULL,
    @State VARCHAR(2) = NULL,
    @Zip5 VARCHAR(5) = NULL,
    @Zip4 VARCHAR(4) = NULL,
    @Phone VARCHAR(12) = NULL,
    @PhoneExtn VARCHAR(10) = NULL
	WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @UserIdStr VARCHAR(36);
	SET @UserIdStr = CONVERT(VARCHAR(36), @UserId);

	IF EXISTS (SELECT UserId FROM dbo.eWebUserDemographic WHERE UserId = @UserId)
		BEGIN
			IF NOT (ISNULL(@NamePrefix, '') = '' AND
			        ISNULL(@FirstName, '') = '' AND
			        ISNULL(@MiddleInitial, '') = '' AND
			        ISNULL(@LastName, '') = '' AND
			        ISNULL(@NameSuffix, '') = '' AND
			        ISNULL(@AddrLine1, '') = '' AND
			        ISNULL(@AddrLine2, '') = '' AND
			        ISNULL(@City, '') = '' AND
			        ISNULL(@State, '') = '' AND
			        ISNULL(@Zip5, '') = '' AND
			        ISNULL(@Zip4, '') = '' AND
			        ISNULL(@Phone, '') = '' AND
			        ISNULL(@PhoneExtn, '') = '')
				BEGIN
					IF NOT (ISNULL(@FirstName, '') = '' OR ISNULL(@LastName, '') = '')
						BEGIN

							IF @MiddleInitial IS NOT NULL
								BEGIN
									IF LEN(@MiddleInitial) = 0
										BEGIN
											SET @MiddleInitial = NULL;
										END;
								END;

							UPDATE 
								dbo.eWebUserDemographic
							SET
								NamePrefix = @NamePrefix, 
								FirstName = @FirstName, 
								MiddleInitial = @MiddleInitial, 
								LastName = @LastName, 
								NameSuffix = @NameSuffix, 
								AddrLine1 = @AddrLine1, 
								AddrLine2 = @AddrLine2, 
								City = @City, 
								[State] = @State, 
								Zip5 = @Zip5, 
								Zip4 = @Zip4, 
								Phone = @Phone, 
								PhoneExtn = @PhoneExtn
							WHERE
								UserId = @UserId;
						END
					ELSE
						BEGIN
							RAISERROR (N'UserId %s first and last names are required.', 16, 1, @UserIdStr);
						END
				END
			ELSE
				BEGIN
					RAISERROR (N'UserId %s does not have any non blank value to be updated.', 16, 1, @UserIdStr);
				END
		END
	ELSE
		BEGIN
			RAISERROR (N'UserId %s does not exist in eWebUserDemographic table so use insert instead.', 16, 1, @UserIdStr);
		END;
END
GO
