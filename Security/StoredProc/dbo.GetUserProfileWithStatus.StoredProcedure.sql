USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[GetUserProfileWithStatus]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE  [dbo].[GetUserProfileWithStatus] 
	@AdministrationID int, 
	@DistrictCode varchar(15) = '', 
	@SchoolCode varchar(15) = '', 
	@UserRole varchar(50) = '', 
	@FirstName nvarchar(100) = '',
	@LastName nvarchar(100) = '',  
	@Email nvarchar(256) = '',
	@LoginWindow int,
	@Status varchar(50),
	@HideInActive bit = 0
AS

With q as 
(
SELECT DISTINCT 
	[m].[UserId],
	[p].[ProfileId],
	[d].[FirstName],
	[p].[DistrictCode] AS District,
	[p].[SchoolCode] AS School,
	[d].[LastName],
	[m].[Email],
	[m].[IsLockedOut],
	[m].[IsApproved],
	[p].[Role] AS userRole,
	CONVERT(BIT, CASE
				WHEN [l].[HasLoggedIn] IS NULL THEN 0
				ELSE 1
				END) AS HasUserLoggedIn,
	[m].[CreateDate],
	[p].[AdminId],
	[m].[LastLoginDate], 
	[m].[LastLockoutDate],
	[m].[LastPasswordChangedDate],
	Case When [m].[IsApproved] = 0 Then 'Not_Active'
	     When DATEDIFF(day, [m].[LastPasswordChangedDate], getdate()) >= @LoginWindow 
		      And  [l].[HasLoggedIn] IS NULL Then 'Password_Expired'
	     When [l].[HasLoggedIn] IS NULL THEN 'Not_Logged_In_Yet'  
         When [m].[IsLockedOut] = 1 Then 'Locked'  
		 Else 'Active'
		 End as Status
FROM
	[dbo].[aspnet_Membership] AS [m]
	INNER JOIN [dbo].[eWebUserDemographic] AS d ON [m].[UserId] = [d].[UserId]
	LEFT JOIN [dbo].[eWebUserProfile] AS [p] ON [m].[UserId] = [p].[UserId]
	LEFT JOIN [dbo].[vw_SC_UserList_HasLoggedIn] AS [l] ON [m].[UserId] = [l].[UserId]
	Join [dbo].[eWebAdministration] a on a.[AdministrationID] = p.AdminId
	Where (@DistrictCode = '' OR (p.DistrictCode = @DistrictCode))
	And  (@SchoolCode = ''  OR (p.SchoolCode = @SchoolCode))
	And  (@UserRole = ''  OR (p.Role = @UserRole))  
	And  (@LastName = ''  OR (d.LastName like @LastName + '%'))
	And (@FirstName = ''  OR (d.FirstName like @FirstName + '%'))
	And p.AdminId = @AdministrationID or @AdministrationID = -1
	And ((a.StartDate is null or a.StartDate < = getdate()) 
		  And
		  (a.EndDate is null or a.EndDate >= getdate()))
    
)

Select [UserId],
	[ProfileId],
	[FirstName],
	[District],
	[School],
	[LastName],
	[Email],
	[userRole],
	[CreateDate],
	[AdminId],
	[Status],
	[IsLockedOut],
	[IsApproved],
	[HasUserLoggedIn],
	[CreateDate],
	[LastLoginDate], 
	[LastLockoutDate],
	[LastPasswordChangedDate]
FROM Q
WHERE (Status = @Status OR @Status = 'NoStatus')
And (@HideInActive = 0 OR Status <> 'Not_Active')
And (@Email = ''  OR  (Email like '%' +  @Email + '%'))
 
GO
