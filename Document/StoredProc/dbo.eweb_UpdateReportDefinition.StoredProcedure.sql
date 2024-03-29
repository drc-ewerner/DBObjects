USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_UpdateReportDefinition]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[eweb_UpdateReportDefinition]
    @docGroupID          int
   ,@environmentCode     varchar(20)
   ,@UserGroupID	[uniqueidentifier]
   ,@publishBeginDate    datetime
   ,@publishEndDate      datetime
   ,@linkText            varchar(100)
   ,@StateRptsViewableByLowerRoles BIT = 1
AS
/*  *****************************************************************
    * Description:  Update all existing data for a particular 
    *               report definition (DocGroup) including all
    *               version and document data.
    *================================================================
    * Created:      3/26/2009
    * Developer:    Chad Hirmer
    *================================================================
    * Changes:		Add user group field to update list
    *
    * Date:         10/9/2009
    * Developer:    Ya Liu
    * Description:  User Group field is added to assign report to users
    *****************************************************************
    * 1/2/2012 (DRZ) - Updated to allow for StateRprtsViewableByLowerRoles
    *				   to be updated.
    *****************************************************************
    * 1/9/2012 (CLH) - oldLinkText 
    *****************************************************************
    * 6/20/2014 (JC) - expanded @environmentCode from 4 to 20 chars
    *****************************************************************
*/

DECLARE @tranName varchar(30);
SELECT @tranName = 'UpdDocDef';

DECLARE @oldLinkText            varchar(100)
SET @oldLinkText = 
(SELECT Title FROM dbo.DocGroup
WHERE DocGroupID  = @docGroupID);
  
BEGIN TRY

  BEGIN TRANSACTION @tranName;

  UPDATE dbo.DocGroup
  SET  UserGroupID = @UserGroupID
	  ,Title = @linkText
	  ,StateRptsViewableByLowerRoles = @StateRptsViewableByLowerRoles
  WHERE DocGroupID  = @docGroupID;

  UPDATE dgvp
  SET PublishBeginDate = @publishBeginDate
     ,PublishEndDate   = @publishEndDate
  FROM DocGroupVersion         dgv
  JOIN DocGroupVersionPublish  dgvp  ON  dgv.DocGroupVerID = dgvp.DocGroupVerID
  WHERE dgv.DocGroupID       = @docGroupID
    AND dgvp.EnvironmentCode = @environmentCode;

  UPDATE d
  SET LinkText = @linkText
  FROM DocGroupVersion         dgv
  JOIN DocGroupVersionDoc      dgvd  ON  dgv.DocGroupVerID = dgvd.DocGroupVerID
  JOIN Doc                     d     ON  dgvd.DocID        = d.DocID
  WHERE dgv.DocGroupID = @docGroupID AND d.LinkText = @oldLinkText;

  COMMIT TRANSACTION @tranName;

END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK TRANSACTION @tranName;
  EXEC eweb_RethrowError;
END CATCH;
GO
