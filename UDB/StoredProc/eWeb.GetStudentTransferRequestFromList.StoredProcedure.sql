USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentTransferRequestFromList]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[GetStudentTransferRequestFromList](
	@AdminID AS INT,
	@StudentTransferRequestIds VARCHAR(MAX)
)
WITH RECOMPILE
AS
BEGIN
	/* split CSV list into a temp table */
	DECLARE @ids TABLE(StudentTransferRequestId INT PRIMARY KEY CLUSTERED(StudentTransferRequestId))

	DECLARE @Delimiter CHAR(1); SET @Delimiter = ','
	DECLARE @RET TABLE(RESULT BIGINT)
    
	IF LTRIM(RTRIM(@StudentTransferRequestIds))='' RETURN  

	DECLARE @START BIGINT
	DECLARE @LASTSTART BIGINT
	SET @LASTSTART=0
	SET @START=CHARINDEX(@Delimiter,@StudentTransferRequestIds,0)

	IF @START=0
	INSERT INTO @RET VALUES(SUBSTRING(@StudentTransferRequestIds,0,LEN(@StudentTransferRequestIds)+1))

	WHILE(@START >0)
	BEGIN
		INSERT INTO @RET VALUES(SUBSTRING(@StudentTransferRequestIds,@LASTSTART,@START-@LASTSTART))
		SET @LASTSTART=@START+1
		SET @START=CHARINDEX(@Delimiter,@StudentTransferRequestIds,@START+1)
		IF(@START=0)
		INSERT INTO @RET VALUES(SUBSTRING(@StudentTransferRequestIds,@LASTSTART,LEN(@StudentTransferRequestIds)+1))
	END
    
	INSERT INTO @ids SELECT * FROM @RET

	SELECT  
		ws.[StudentTransferRequestId]
		,[AdminID]
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
	INNER JOIN @ids ids ON ids.StudentTransferRequestId = ws.StudentTransferRequestId
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
	WHERE ws.AdminID = @AdminID 

END

GO
