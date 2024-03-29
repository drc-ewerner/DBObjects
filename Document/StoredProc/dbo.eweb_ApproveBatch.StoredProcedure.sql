USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_ApproveBatch]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Steve Campbell
-- Create date: 
-- Description:	
-- =============================================
   --*****************************************************************
   -- * 6/20/2014 (JC) - expanded @environmentCode from 4 to 20 chars
   -- *****************************************************************
CREATE PROCEDURE [dbo].[eweb_ApproveBatch]
	-- Add the parameters for the stored procedure here
	@batchId int,
	@environmentCode nvarchar(20), 
	@approveUser nvarchar(100), 
	@approveDate datetime
AS
BEGIN
	update	dgvp
	set		dgvp.ApprovedDate = @approveDate, 
			dgvp.ApprovedUser = @approveUser
	from	DocGroupVersionPublish dgvp
			INNER JOIN DocBatch db ON dgvp.DocGroupVerId = db.DocGroupVerId
	where	dgvp.EnvironmentCode = @environmentCode
	and		db.DocBatchId = @batchId
END
GO
