USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_DeleteDocsByDocGroupVerID]    Script Date: 1/12/2022 2:12:10 PM ******/
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
