USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateStudentTransferForm]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[UpdateStudentTransferForm]
@StudentTransferRequestId AS INT,
@AdminID AS INT,
@Status varchar(50)
AS
Begin

Update [eWeb].[StudentTransferRequest] 
Set Status= 'Completed'
From [eWeb].[StudentTransferRequest] ws
where ws.AdminID=@AdminID
And ws.StudentTransferRequestId = @StudentTransferRequestId
And ws.Status = 'In Progress'
end
GO
