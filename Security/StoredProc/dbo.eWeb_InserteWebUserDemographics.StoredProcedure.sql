USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_InserteWebUserDemographics]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eWeb_InserteWebUserDemographics]
    @UserId UNIQUEIDENTIFIER, 
    @NamePrefix VARCHAR(10) = NULL,
    @FirstName VARCHAR(30),
    @MiddleInitial VARCHAR(1) = NULL,
    @LastName VARCHAR(30),
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

	IF NOT EXISTS (SELECT UserId FROM dbo.eWebUserDemographic WHERE UserId = @UserId)
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

							INSERT INTO dbo.eWebUserDemographic (UserId, NamePrefix, FirstName, MiddleInitial, LastName, NameSuffix, AddrLine1, AddrLine2, City, [State], Zip5, Zip4, Phone, PhoneExtn) VALUES
							(@UserId, @NamePrefix, @FirstName, @MiddleInitial, @LastName, @NameSuffix, @AddrLine1, @AddrLine2, @City, @State, @Zip5, @Zip4, @Phone, @PhoneExtn);
						END
					ELSE
						BEGIN
							RAISERROR (N'UserId %s first and last names are required.', 16, 1, @UserIdStr);
						END
				END
			ELSE
				BEGIN
					RAISERROR (N'UserId %s does not have any non blank value to be inserted.', 16, 1, @UserIdStr);
				END
		END
	ELSE
		BEGIN
			RAISERROR (N'UserId %s already exists in eWebUserDemographic table so use update instead.', 16, 1, @UserIdStr);
		END;
END
GO
