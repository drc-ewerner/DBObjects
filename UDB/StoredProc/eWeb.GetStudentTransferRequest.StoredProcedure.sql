USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentTransferRequest]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetStudentTransferRequest](
	@AdminIDs AS VARCHAR(MAX),
	@StudentTransferRequestId INT  = NULL,
	@Status varchar(50) = NULL
	)

WITH RECOMPILE
AS
BEGIN
	/* split CSV list into a temp table */
	DECLARE @ids TABLE(AdminID INT PRIMARY KEY CLUSTERED(AdminID))

	DECLARE @Delimiter CHAR(1); SET @Delimiter = ','
	DECLARE @RET TABLE(RESULT BIGINT)
    
	IF LTRIM(RTRIM(@AdminIDs))='' RETURN  

	DECLARE @START BIGINT
	DECLARE @LASTSTART BIGINT
	SET @LASTSTART=0
	SET @START=CHARINDEX(@Delimiter,@AdminIDs,0)

	IF @START=0
	INSERT INTO @RET VALUES(SUBSTRING(@AdminIDs,0,LEN(@AdminIDs)+1))

	WHILE(@START >0)
	BEGIN
		INSERT INTO @RET VALUES(SUBSTRING(@AdminIDs,@LASTSTART,@START-@LASTSTART))
		SET @LASTSTART=@START+1
		SET @START=CHARINDEX(@Delimiter,@AdminIDs,@START+1)
		IF(@START=0)
		INSERT INTO @RET VALUES(SUBSTRING(@AdminIDs,@LASTSTART,LEN(@AdminIDs)+1))
	END
    
	INSERT INTO @ids SELECT * FROM @RET

	SELECT  
		[StudentTransferRequestId]
		 ,ws.[AdminID]
           ,[FromDistrictCode]
		   ,d.SiteName AS FromDistrictName
           ,[FromSchoolCode]
		   ,s.SiteName AS FromSchoolName
           ,[ToDistrictCode]
		   ,d2.SiteName AS ToDistrictName
           ,[ToSchoolCode]
		   ,s2.SiteName AS ToSchoolName
           ,[FromCompletedContentArea1]
           ,[FromCompletedContentArea2]
           ,[FromCompletedContentArea3]
           ,[FromCompletedContentArea4]
           ,[FromTestingMode]
           ,[ToCompletedContentArea1]
           ,[ToCompletedContentArea2]
           ,[ToCompletedContentArea3]
           ,[ToCompletedContentArea4]
           ,[ToTestingMode]
           ,[FirstName]
           ,[LastName]
           ,[BirthDate]
           ,[StateStudentID]
           ,[Grade]
           ,ws.[Status]
           ,[SendersPhoneNumber]
		   ,[TimeOfRequest]
		   ,[SendersEmail]
		   ,[SendersFullName]
		   ,[SendersUserId]
	FROM [eWeb].[StudentTransferRequest] ws
	INNER JOIN @ids ids ON ids.AdminID = ws.AdminID
	LEFT OUTER JOIN Core.Site d 
		ON d.AdministrationID = ws.AdminID
			AND d.SiteCode = ws.FromDistrictCode
			AND d.SiteType = 'District'
	LEFT OUTER JOIN Core.Site s
		ON s.AdministrationID = ws.AdminID
			AND s.SuperSiteCode = ws.FromDistrictCode
			AND s.SiteCode = ws.FromSchoolCode
			AND s.SiteType = 'School'
	LEFT OUTER JOIN Core.Site d2 
		ON d2.AdministrationID = ws.AdminID
			AND d2.SiteCode = ws.ToDistrictCode
			AND d2.SiteType = 'District'
	LEFT OUTER JOIN Core.Site s2
		ON s2.AdministrationID = ws.AdminID
			AND s2.SuperSiteCode = ws.ToDistrictCode
			AND s2.SiteCode = ws.ToSchoolCode
			AND s2.SiteType = 'School'
	WHERE (ws.StudentTransferRequestId = @StudentTransferRequestId OR @StudentTransferRequestId IS NULL OR @StudentTransferRequestId = 0)
	AND (ws.Status = @Status OR @Status IS NULL OR @Status = '')
END

GO
