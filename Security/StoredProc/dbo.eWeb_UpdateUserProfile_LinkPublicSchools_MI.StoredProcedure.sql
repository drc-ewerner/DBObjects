USE [Alaska_security_dev]
GO
/****** Object:  StoredProcedure [dbo].[eWeb_UpdateUserProfile_LinkPublicSchools_MI]    Script Date: 7/2/2024 9:47:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





/******************************************************************
 * Run for Admins 523577(larger volume) and 523575(smaller volume).
 * Run this script on the MI Securities DB (staging then prod).
 ******************************************************************/
CREATE PROCEDURE [dbo].[eWeb_UpdateUserProfile_LinkPublicSchools_MI]
    @AdminId integer
   ,@Role varchar(20)
AS


/*Create a list of all district and school code combinations.*/
SELECT DISTINCT
	 Dist.AdministrationID
	,Dist.SiteCode as DistrictCode
	,Schl.SiteCode as SchoolCode 
INTO #CODES
From [Michigan_udb_prod].[Core].[Site] Dist
Inner Join [Michigan_udb_prod].[Core].[Site] Schl
	on Dist.AdministrationID = Schl.AdministrationID
	and Schl.SuperSiteCode = Dist.SiteCode
	and Dist.LevelID = 1
	and Schl.LevelID = 2
Where Dist.AdministrationID = @AdminId
	and ISNULL(Dist.SiteSubType,'') = ''
	and ISNULL(Schl.SiteSubType,'') = ''
Order By Dist.AdministrationID, Dist.SiteCode, Schl.SiteCode
--FYI: Private Schools have SiteSubType = '34 - Private'




/*Join that list onto the existing user profiles. Ignore the records for schools that already exist.*/
SELECT
	 up.UserId
	,up.[Role]
	,up.AdminId
	,c.DistrictCode
	,c.SchoolCode
INTO #TEMP
FROM [dbo].[eWebUserProfile] up
left outer join #CODES c
	on up.AdminId = c.AdministrationID
	and up.DistrictCode = c.DistrictCode
WHERE up.AdminId = @AdminId
	AND up.[Role] = @Role
	AND ISNULL(up.DistrictCode, '') <> ''
	AND up.SchoolCode <> c.SchoolCode




/*Remove any combinations that already exist. Don't insert Dups.*/
Select Distinct
	 a.UserId
	,a.[Role]
	,a.AdminId
	,a.DistrictCode
	,a.SchoolCode
INTO #INSERTME_USERPROFILE
From #TEMP a
left outer join [dbo].[eWebUserProfile] b
on a.AdminId = b.AdminId
and a.[Role] = b.[Role]
and a.DistrictCode = b.DistrictCode
and a.SchoolCode = b.SchoolCode
and a.UserId = b.UserId
where a.AdminId = @AdminId
and a.[Role] = @Role
and b.UserId Is Null





/*Insert the resulting set into the user profile table*/
Insert Into [dbo].[eWebUserProfile] ([UserId], [Role], [AdminId], [DistrictCode], [SchoolCode])
Select [UserId], [Role], [AdminId], [DistrictCode], [SchoolCode] From #INSERTME_USERPROFILE



/*Copy permissions*/
--get all profileid's from eWebUserProfile now that they are created
SELECT 
	 up.ProfileId
	,up.UserId
	,up.[Role]
	,up.AdminId
	,up.DistrictCode
	,up.SchoolCode
INTO #PROFILES
FROM [dbo].[eWebUserProfile] up
WHERE AdminId = @AdminId
	AND [Role] = @Role
	AND ISNULL(up.DistrictCode, '') <> ''


--get one profile id for each user
SELECT
	MIN(p.ProfileId) as BaseProfileId
	,p.UserId
	,p.DistrictCode
INTO #PROFILEIDS
FROM #PROFILES p
Group By p.UserId, p.DistrictCode


--all permissions associated with distinct profile ids per userid that was inserted
SELECT p.ProfileId, sa.PermissionID
INTO #SCREENACCESS
FROM #PROFILES p
inner join #PROFILEIDS pid
	on p.UserId = pid.UserId
	and p.DistrictCode = pid.DistrictCode
inner join dbo.eWebScreenAccess sa
	on pid.BaseProfileId = sa.ProfileId
 


--Insert these records if they do not exist. Do not insert dups.
SELECT DISTINCT sa.ProfileId, sa.PermissionID
INTO #INSERTME_SCREENACCESS
FROM #SCREENACCESS sa 
left outer join dbo.eWebScreenAccess esa
	on sa.ProfileId = esa.ProfileId
	and sa.PermissionID = esa.PermissionID
where esa.PermissionID is null



/*insert eWebScreenAccess records to give permissions to the new profiles.*/
Insert Into [dbo].[eWebScreenAccess] ([ProfileId], [PermissionID])
Select [ProfileId], [PermissionID] From #INSERTME_SCREENACCESS




/*Clean up the mess*/
DROP TABLE #CODES
DROP TABLE #TEMP
DROP TABLE #INSERTME_USERPROFILE
DROP TABLE #PROFILES
DROP TABLE #PROFILEIDS
DROP TABLE #SCREENACCESS
DROP TABLE #INSERTME_SCREENACCESS
GO
