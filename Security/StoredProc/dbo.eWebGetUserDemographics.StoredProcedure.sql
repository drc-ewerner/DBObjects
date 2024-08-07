USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWebGetUserDemographics]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eWebGetUserDemographics]
	@UserId UNIQUEIDENTIFIER
	WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		UserId,
		NamePrefix,
		FirstName,
		MiddleInitial,
		LastName,
		NameSuffix,
		AddrLine1,
		AddrLine2,
		City,
		[State],
		Zip5,
		Zip4,
		Phone,
		PhoneExtn
	FROM
		dbo.eWebUserDemographic
	WHERE
		UserId = @UserId;

END;

GO
