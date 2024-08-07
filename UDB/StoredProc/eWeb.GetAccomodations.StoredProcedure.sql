USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAccomodations]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[GetAccomodations]
	@AdministrationID integer,
	@Grade varchar(2) = NULL  
AS
BEGIN
	-- We create temp table so can use results from one sproc in another
		DECLARE @Table TABLE(
		[ContentArea] varchar(50)	
		PRIMARY KEY CLUSTERED(ContentArea)
		)
	INSERT INTO @Table
	EXECUTE eweb.getcontentareas @AdministrationID

	SET NOCOUNT ON;
 SELECT substring(n.name,0,charindex('.',n.name))  AccomodationType,n.Category, n.Name, DisplayName,  ISNULL(GroupName, DisplayName) AS GroupName
  FROM [XRef].[StudentExtensionValues] val
      INNER JOIN [XRef].[StudentExtensionNames] n ON val.AdministrationID = n.AdministrationId and val.Category = n.Category and val.Name = n.Name
      INNER JOIN Scoring.Tests te on val.AdministrationID = te.AdministrationID and val.Category = te.ContentArea
	 

where charindex('.',n.name) <> 0 and n.AdministrationId = @AdministrationID 
	  AND n.Category in (Select ContentArea from @Table)
	  AND isnull(n.DisplayOrder,0) >= 0
	  AND NOT EXISTS (SELECT *
				FROM Config.Extensions chk
				WHERE chk.AdministrationID = @AdministrationID
					AND chk.Category = 'eWeb'
					AND chk.Name = 'Accommodation|' + n.Category + '|' + n.Name + '|' + @Grade
					AND chk.Value = 'Exclude') 
group by ISNULL(GroupName, DisplayName), DisplayName, n.Name,n.category,substring(n.name,0,charindex('.',n.name)), n.DisplayOrder  
order by n.DisplayOrder 
END
GO
