USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetEducScoringCertsByAdminIDs]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [eWeb].[GetEducScoringCertsByAdminIDs](@CSVInput VARCHAR(MAX))
AS
BEGIN

	DECLARE @ret TABLE(AdminID INT)
	
    
	IF LTRIM(RTRIM(@CSVInput)) != '' 
	BEGIN
		DECLARE @start BIGINT
		DECLARE @laststart BIGINT
		SET @laststart=0
		SET @start=CHARINDEX(',', @CSVInput, 0)

		IF @start=0
		INSERT INTO @ret VALUES(SUBSTRING(@CSVInput, 0, LEN(@CSVInput)+1))

		WHILE(@start > 0)
		BEGIN
			INSERT INTO @ret VALUES(SUBSTRING(@CSVInput, @laststart, @start - @laststart))
			SET @laststart=@start+1
			SET @start=CHARINDEX(',', @CSVInput, @start+1)
			IF(@start=0)
				INSERT INTO @ret VALUES(SUBSTRING(@CSVInput, @laststart, LEN(@CSVInput)+1))
		END
	END
	

	;with crt AS
	(
		SELECT ce.AdministrationID
			, CASE 
				WHEN MAX(CASE WHEN ce.Value = 'Y' AND ce.Name = 'EducatorScoring.RequireCertifyContentAreas' THEN 1 ELSE 0 END) +
					MAX(CASE WHEN ce.Value = 'Y' AND ce.Name = 'EducatorScoring.Enable' THEN 1 ELSE 0 END) = 2
					THEN 1
				ELSE 0
				END AS ReqCertify
		FROM Config.Extensions ce
		WHERE ce.Name IN ('EducatorScoring.RequireCertifyContentAreas', 'EducatorScoring.Enable')
		GROUP BY ce.AdministrationID
	), req AS
	(
		SELECT 
			r.AdminID, CAST(ISNULL(crt.ReqCertify, 0) AS BIT) AS ReqCertify
		FROM @ret r
		LEFT OUTER JOIN crt ON crt.AdministrationID = r.AdminID
	)
	SELECT 
		r.AdminID
		, r.ReqCertify
		, ISNULL(ca.Value, '') AS ApplicableContentAreas
	FROM req r
	LEFT OUTER JOIN Config.Extensions ca
		ON ca.AdministrationID = r.AdminID 
			AND ca.Category = 'eWeb'
			AND ca.Name = 'EducatorScoring.ApplicableContentAreas'
END
GO
