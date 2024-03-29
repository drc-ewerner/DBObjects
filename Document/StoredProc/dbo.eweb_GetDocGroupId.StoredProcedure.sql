USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_GetDocGroupId]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[eweb_GetDocGroupId]
	  @DocType NVARCHAR (50)
	, @DocSuperTypeId INT
	, @AdminId INT
	, @FileTypeExt NVARCHAR (50)
	, @Description NVARCHAR (255)
	, @UserGroupId [uniqueidentifier]
	, @IsPublic BIT
	, @Title NVARCHAR (100)
	, @StateRptsViewableByLowerRoles BIT = 1
AS
BEGIN
	--get doctypeid
	declare @DocTypeId int

	select @DocTypeId = dt.DocTypeId
	from	DocType dt
	where	dt.Descr = @DocType and dt.DocSuperTypeID = @DocSuperTypeId

	if @DocTypeId IS NULL 
	begin
		insert DocType(DocSuperTypeId, Descr) values (@DocSuperTypeId, @DocType)
	
		select @DocTypeId = SCOPE_IDENTITY()
	end

	--get docgroupid
	declare @DocGroupId int

	select @DocGroupId = DocGroupId
	from	DocGroup
	where	DocTypeId = @DocTypeId
	and		AdministrationId = @AdminId
	and		FileTypeExt = @FileTypeExt
	and		(Title = @Title)

	if @DocGroupId IS NULL
	begin
		Insert DocGroup(DocTypeId, Descr, AdministrationId, FileTypeExt, UserGroupId, IsPublic, Title, StateRptsViewableByLowerRoles)
		values (@DocTypeId, @Description, @AdminId, @FileTypeExt, @UserGroupId, @IsPublic, @Title, @StateRptsViewableByLowerRoles)

		select @DocGroupId = SCOPE_IDENTITY()
	end
	else
		update	DocGroup
		set		Descr = @Description
			   ,StateRptsViewableByLowerRoles = @StateRptsViewableByLowerRoles
			   ,IsPublic = @IsPublic
			   ,UserGroupId = @UserGroupId 
		WHERE	DocGroupId = @DocGroupId

	RETURN @DocGroupId
END;
GO
