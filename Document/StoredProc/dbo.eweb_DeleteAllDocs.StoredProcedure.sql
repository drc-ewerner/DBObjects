USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_DeleteAllDocs]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Patrick Glanville
-- Create date: 1/26/2009
-- Description:	Delete all documents in the database
-- =============================================
CREATE PROCEDURE [dbo].[eweb_DeleteAllDocs]

AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @DocGroupID int
	Declare @DocTypeID int

	Declare docGroupCursor CURSOR  for
	Select dg.DocGroupID From dbo.DocGroup dg inner join 
	dbo.DocType dt on dg.DocTypeID = dt.DocTypeID
	Where DocSuperTypeID = 1 --Delete report types

	Open docGroupCursor
	
	FETCH NEXT FROM docGroupCursor into @DocGroupID

	While @@FETCH_STATUS = 0
	Begin
		Execute dbo.eweb_DeleteDocsByDocGroupID @DocGroupID
		FETCH NEXT FROM docGroupCursor into @DocGroupID
	End 

	close docGroupCursor
	deallocate docGroupCursor

END
GO
