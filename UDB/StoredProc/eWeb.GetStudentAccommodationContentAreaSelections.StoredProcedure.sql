USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentAccommodationContentAreaSelections]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [eWeb].[GetStudentAccommodationContentAreaSelections]
@AdministrationID integer,
@studentId as integer = 0, 
@Grade varchar(MAX) = NULL
as
BEGIN

		
		-- We create temp table so can use results from one sproc in another
		DECLARE @Table TABLE(
		[ContentArea] varchar(50)	
		PRIMARY KEY CLUSTERED(ContentArea)
		)
		INSERT INTO @Table
		EXECUTE eWeb.GetAccommodationContentAreas @AdministrationID, @Grade   

		DECLARE @ExclusionNames TABLE([Name] VARCHAR(200))
		/* split grade string by comma and remove grade from extension name */
		INSERT INTO @ExclusionNames
		SELECT DISTINCT LEFT(ce.Name, LEN(ce.Name) - LEN(g.v) - 1)
		FROM Aux.SplitStrings(@Grade) g
		INNER JOIN Config.Extensions ce
			ON ce.AdministrationID = @AdministrationID
				AND ce.Category = 'eWeb'
				AND ce.Name LIKE 'Accommodation|%|%|%' + g.v
				AND ce.Value = 'Exclude'
		WHERE @Grade IS NOT NULL AND LEN(@Grade) > 0

		SELECT val.Name, 
			DisplayName,
			SUBSTRING(n.Name, 0, CHARINDEX('.', n.Name)) AS AccomodationType, n.Category as ContentArea, 
			case when st.StudentID is null then 0 else 1 end Selected 
			, ExclusivityGroup 
		FROM         XRef.StudentExtensionValues AS val INNER JOIN
							  XRef.StudentExtensionNames AS n ON val.AdministrationID = n.AdministrationID AND val.Category = n.Category AND val.Name = n.Name 
							  INNER JOIN Scoring.ContentAreas  ca  ON n.AdministrationID = ca.AdministrationID AND n.Category = ca.ContentArea
							  LEFT OUTER JOIN  (Select * from Student.Extensions where StudentID =@studentId and AdministrationID = @AdministrationID and Value = 'Y')st  
								ON val.AdministrationID = st.AdministrationID AND val.Category = st.Category AND val.Name = st.Name 
							  
		WHERE     CHARINDEX('.', n.Name) <> 0
		AND		n.AdministrationID = @AdministrationID
		AND		val.Value = 'Y'
		AND		n.Category in (Select ContentArea from @Table)
		AND		ca.IsForAccommodations = 1
		and		isnull(n.DisplayOrder,0) >= 0
		AND NOT EXISTS (SELECT *
						FROM @ExclusionNames en
						WHERE en.Name = 'Accommodation|' + n.Category + '|' + val.Name) 
		order by n.DisplayOrder, AccomodationType, DisplayName
END
GO
