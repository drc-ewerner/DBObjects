USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_ModifyUserFromService]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[eWeb_ModifyUserFromService] 
	  @userID UNIQUEIDENTIFIER
	, @lastName VARCHAR(30)
	, @firstName VARCHAR(30)
	, @middleInitial VARCHAR(1)
	, @emailAddress NVARCHAR(256)
	, @isDeleted BIT
AS
BEGIN
	DECLARE @trimMI VARCHAR(1)
	SET @trimMI = LTRIM(RTRIM(@middleInitial))

	--Get current isDeleted user status
	DECLARE @isApproved BIT
	DECLARE @isDeleted_Current BIT

	SELECT @isDeleted_Current=IsDeleted, @isApproved=IsApproved from dbo.aspnet_Membership 
							WHERE @emailAddress IS NOT NULL AND UserId = @userID

	SET @isApproved = iif(@isDeleted_Current = @isDeleted,@isApproved, iif(@isDeleted = 0,1,0))


	UPDATE dbo.aspnet_Membership 
	SET Email = @emailAddress, LoweredEmail = LOWER(@emailAddress), IsDeleted = @isDeleted, IsApproved = @isApproved
	WHERE @emailAddress IS NOT NULL AND UserId = @userID

	UPDATE dbo.aspnet_Users 
	SET UserName = @emailAddress, LoweredUserName = LOWER(@emailAddress)
	WHERE @emailAddress IS NOT NULL AND UserId = @userID

	UPDATE d
	SET FirstName = CASE WHEN d.FirstName <> @firstName THEN @firstName ELSE d.FirstName END
		, LastName = CASE WHEN d.LastName <> @LastName THEN @LastName ELSE d.LastName END
		, MiddleInitial = CASE 
							WHEN d.MiddleInitial = @trimMI THEN d.MiddleInitial
							WHEN LEN(@trimMI) = 0 OR @trimMI IS NULL THEN NULL
							ELSE @trimMI
						  END
	FROM dbo.eWebUserDemographic d
	WHERE d.UserId = @userID
END
GO
