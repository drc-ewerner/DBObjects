USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_GetWIDADocGroupId]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eweb_GetWIDADocGroupId]
	  @DocType NVARCHAR (50)
	, @DocSuperTypeId INT
	, @AdminId INT
	, @FileTypeExt NVARCHAR (50)
	, @Description NVARCHAR (255)
	, @UserGroupId [uniqueidentifier]
	, @IsPublic BIT
	, @Title NVARCHAR (100)
	, @StateRptsViewableByLowerRoles BIT = 1
	, @AudienceId INT = null
AS
BEGIN
	--get doctypeid
	DECLARE @DocTypeId INT

	SELECT @DocTypeId = dt.DocTypeId
	FROM	DocType dt
	WHERE	dt.Descr = @DocType AND dt.DocSuperTypeID = @DocSuperTypeId

	IF @DocTypeId IS NULL 
	BEGIN
		INSERT DocType(DocSuperTypeId, Descr) VALUES (@DocSuperTypeId, @DocType)
	
		SELECT @DocTypeId = SCOPE_IDENTITY()
	END

	--get docgroupid
	DECLARE @DocGroupId INT
	
	SELECT @DocGroupId = DocGroupId
	FROM	DocGroup
	WHERE	DocTypeId = @DocTypeId
	AND		AdministrationId = @AdminId
	AND		FileTypeExt = @FileTypeExt
	AND		(Title = @Title)

	IF @DocGroupId IS NULL
	BEGIN
		INSERT DocGroup(DocTypeId, Descr, AdministrationId, FileTypeExt, UserGroupId, IsPublic, Title, StateRptsViewableByLowerRoles, AudienceID)
		VALUES (@DocTypeId, @Description, @AdminId, @FileTypeExt, @UserGroupId, @IsPublic, @Title, @StateRptsViewableByLowerRoles, @AudienceId)

		SELECT @DocGroupId = SCOPE_IDENTITY()
	END
	ELSE
		UPDATE	DocGroup
		SET		Descr = @Description
			   ,StateRptsViewableByLowerRoles = @StateRptsViewableByLowerRoles
			   ,IsPublic = @IsPublic
			   ,UserGroupId = @UserGroupId
			   ,AudienceId = @AudienceId 
		WHERE	DocGroupId = @DocGroupId

	RETURN @DocGroupId
END;
GO
