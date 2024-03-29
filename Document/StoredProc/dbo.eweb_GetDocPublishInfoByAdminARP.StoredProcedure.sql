USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_GetDocPublishInfoByAdminARP]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eweb_GetDocPublishInfoByAdminARP]
(
@adminID INT, 
@environmentCode VARCHAR (20), 
@superType INT=1,
@reportType VARCHAR (50) 
) 
WITH RECOMPILE
AS
/*   *================================================================
    * Changes:		Add user group field to select list
    *
    * Date:         10/9/2009
    * Developer:    Ya Liu
    * Description:  User Group field is added to assign report to users
    *****************************************************************
    * 1/2/2011 (DRZ) - Added StateRptsViewableByLowerRoles to return 
    *				   for report metadata use.
    *****************************************************************
	*****************************************************************
    * 6/20/2014 (JC) - expanded @environmentCode from 4 to 20 chars
    *****************************************************************
	* 2/5/2016  (AR) - added flag IsAutomatedPublishEnabled
	*****************************************************************
	*****************************************************************
    * 11/06/2018 (BL) - included @reportType 
    *****************************************************************
    * 11/06/2022 (BL) - included recompile option
    * 01/05/2023 (RL) - set isolation level
    *****************************************************************
*/

BEGIN

    SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF (LEN(COALESCE(@reportType,'')) > 0)
	BEGIN 
		WITH tblDocGroup AS (
			SELECT dg.DocGroupID
				  ,dt.Descr AS DocTypeDescr
				  ,UPPER(dg.FileTypeExt) AS FileTypeExt
				  ,dg.UserGroupID
				  ,MAX(dgv.Version) AS Version
				  ,dg.title
				  ,dg.StateRptsViewableByLowerRoles
				  ,dg.IsAutomatedPublishEnabled
			FROM       DocGroup               dg
			INNER JOIN DocType                dt   ON  dg.DocTypeID       = dt.DocTypeID
			INNER JOIN DocGroupVersion        dgv  ON  dg.DocGroupID      = dgv.DocGroupID
			INNER JOIN DocGroupVersionPublish dgvp ON  dgv.DocGroupVerID  = dgvp.DocGroupVerID
			WHERE dt.DocSuperTypeID    = @superType
			  AND dg.AdministrationID  = @adminID
			  AND dgvp.EnvironmentCode = @environmentCode
			  AND dt.Descr = @reportType
			GROUP BY dg.DocGroupID
					,dt.Descr
					,dg.FileTypeExt
					,dg.UserGroupID
					,dg.title
					,dg.StateRptsViewableByLowerRoles
					,dg.IsAutomatedPublishEnabled
		), 
		tblDocGroupVerDoc AS (
			SELECT g.DocGroupID
				  ,dgvd.DocGroupVerID
				  ,CASE WHEN ISNULL(g.Title,'') = '' THEN MIN(d.LinkText) ELSE g.Title END AS LinkText
				  ,MIN(d.OriginalFileName) AS SampleFileName
			FROM       tblDocGroup        g
			INNER JOIN DocGroupVersion     dgv  ON  g.DocGroupID       = dgv.DocGroupID
												AND g.Version          = dgv.Version
			INNER JOIN DocGroupVersionDoc  dgvd ON  dgv.DocGroupVerID  = dgvd.DocGroupVerID
			INNER JOIN Doc                 d    ON  dgvd.DocID         = d.DocID
			GROUP BY g.DocGroupID
					,dgvd.DocGroupVerID
					,g.Title
		)
		SELECT g.DocGroupID           AS DocGroupID
			  ,dg.DocGroupVerID       AS DocGroupVerID
			  ,g.DocTypeDescr         AS DocTypeDescr
			  ,g.FileTypeExt          AS FileTypeExt
			  ,g.UserGroupId		  As UserGroupID
			  ,[dbo].[udf_GetViewerRoles](g.DocGroupID) AS ViewerRoles
			  ,dg.LinkText            AS LinkText
			  ,dg.SampleFileName      AS SampleFileName
			  ,dgvp.PublishBeginDate  AS PublishDate
			  ,dgvp.PublishEndDate    AS RemoveDate
			  ,g.StateRptsViewableByLowerRoles as StateRptsViewableByLowerRoles
			  ,g.IsAutomatedPublishEnabled
		FROM       tblDocGroup           g
		INNER JOIN tblDocGroupVerDoc     dg   ON  g.DocGroupID     = dg.DocGroupID
		INNER JOIN DocGroupVersionPublish dgvp ON  dg.DocGroupVerID = dgvp.DocGroupVerID
		WHERE dgvp.EnvironmentCode = @environmentCode
	END 
	ELSE
	BEGIN
		WITH tblDocGroup AS (
			SELECT dg.DocGroupID
				  ,dt.Descr AS DocTypeDescr
				  ,UPPER(dg.FileTypeExt) AS FileTypeExt
				  ,dg.UserGroupID
				  ,MAX(dgv.Version) AS Version
				  ,dg.title
				  ,dg.StateRptsViewableByLowerRoles
				  ,dg.IsAutomatedPublishEnabled
			FROM       DocGroup               dg
			INNER JOIN DocType                dt   ON  dg.DocTypeID       = dt.DocTypeID
			INNER JOIN DocGroupVersion        dgv  ON  dg.DocGroupID      = dgv.DocGroupID
			INNER JOIN DocGroupVersionPublish dgvp ON  dgv.DocGroupVerID  = dgvp.DocGroupVerID
			WHERE dt.DocSuperTypeID    = @superType
			  AND dg.AdministrationID  = @adminID
			  AND dgvp.EnvironmentCode = @environmentCode
			GROUP BY dg.DocGroupID
					,dt.Descr
					,dg.FileTypeExt
					,dg.UserGroupID
					,dg.title
					,dg.StateRptsViewableByLowerRoles
					,dg.IsAutomatedPublishEnabled
		), 
		tblDocGroupVerDoc AS (
			SELECT g.DocGroupID
				  ,dgvd.DocGroupVerID
				  ,CASE WHEN ISNULL(g.Title,'') = '' THEN MIN(d.LinkText) ELSE g.Title END AS LinkText
				  ,MIN(d.OriginalFileName) AS SampleFileName
			FROM       tblDocGroup        g
			INNER JOIN DocGroupVersion     dgv  ON  g.DocGroupID       = dgv.DocGroupID
												AND g.Version          = dgv.Version
			INNER JOIN DocGroupVersionDoc  dgvd ON  dgv.DocGroupVerID  = dgvd.DocGroupVerID
			INNER JOIN Doc                 d    ON  dgvd.DocID         = d.DocID
			GROUP BY g.DocGroupID
					,dgvd.DocGroupVerID
					,g.Title
		)
		SELECT g.DocGroupID           AS DocGroupID
			  ,dg.DocGroupVerID       AS DocGroupVerID
			  ,g.DocTypeDescr         AS DocTypeDescr
			  ,g.FileTypeExt          AS FileTypeExt
			  ,g.UserGroupId		  As UserGroupID
			  ,[dbo].[udf_GetViewerRoles](g.DocGroupID) AS ViewerRoles
			  ,dg.LinkText            AS LinkText
			  ,dg.SampleFileName      AS SampleFileName
			  ,dgvp.PublishBeginDate  AS PublishDate
			  ,dgvp.PublishEndDate    AS RemoveDate
			  ,g.StateRptsViewableByLowerRoles as StateRptsViewableByLowerRoles
			  ,g.IsAutomatedPublishEnabled
		FROM       tblDocGroup           g
		INNER JOIN tblDocGroupVerDoc     dg   ON  g.DocGroupID     = dg.DocGroupID
		INNER JOIN DocGroupVersionPublish dgvp ON  dg.DocGroupVerID = dgvp.DocGroupVerID
		WHERE dgvp.EnvironmentCode = @environmentCode
	END

	

END;




GO
