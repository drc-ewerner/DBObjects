USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[DeleteTestingWindow]    Script Date: 11/21/2023 8:56:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[DeleteTestingWindow]
@AdministrationID INT,
@TestWindow varchar(20)
AS
Begin

DELETE FROM [Admin].TestWindow
WHERE AdministrationID=@AdministrationID  And TestWindow=@TestWindow

End
GO
