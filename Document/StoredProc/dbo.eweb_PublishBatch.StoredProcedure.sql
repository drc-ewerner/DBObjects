USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_PublishBatch]    Script Date: 1/12/2022 2:12:10 PM ******/
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
 --   * 6/20/2014 (JC) - expanded @environmentCode from 4 to 20 chars
 --   *****************************************************************
CREATE PROCEDURE [dbo].[eweb_PublishBatch] 
	@batchId int,
	@EnvironmentCode varchar(20),
	@ApprovedDate datetime,
	@ApprovedUser varchar(100),
	@PublishBeginDate datetime,
	@PublishEndDate datetime
AS
BEGIN
	
	if exists(
		select * from dbo.DocGroupVersionPublish dgvp 
			INNER JOIN DocBatch db ON dgvp.DocGroupVerId = db.DocGroupVerId 
		where	db.DocBatchId = @batchId
		and		dgvp.EnvironmentCode = @environmentCode
	)
	begin
		update	dgvp
		set		dgvp.ApprovedDate = @ApprovedDate,
				dgvp.ApprovedUser = @ApprovedUser,
				dgvp.PublishBeginDate = @PublishBeginDate,
				dgvp.PublishEndDate = @PublishEndDate
		from	DocGroupVersionPublish dgvp
			INNER JOIN DocBatch db ON dgvp.DocGroupVerId = db.DocGroupVerId 
		where	db.DocBatchId = @batchId
		and		dgvp.EnvironmentCode = @environmentCode
	end
	else
		Insert into DocGroupVersionPublish 
			(DocGroupVerID, EnvironmentCode, ApprovedDate, ApprovedUser, PublishBeginDate, PublishEndDate)
		select 	db.DocGroupVerID, @EnvironmentCode, @ApprovedDate, @ApprovedUser, @PublishBeginDate, @PublishEndDate
		from	DocBatch db
		where	db.DocBatchId = @batchId
END
GO
