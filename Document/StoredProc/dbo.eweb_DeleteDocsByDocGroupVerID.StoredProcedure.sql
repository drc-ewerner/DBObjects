USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_DeleteDocsByDocGroupVerID]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eweb_DeleteDocsByDocGroupVerID]
@DocGroupVerID BIGINT
AS
BEGIN	
	Declare @docGroupId int

	--First get DocGroupID
	Select @docGroupId = DocGroupID from dbo.DocGroupVersion where DocGroupVerID = @DocGroupVerID

	exec eweb_DeleteDocGroup @docGroupId
END
GO
