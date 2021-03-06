USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[UpdateStudentTransferForm]    Script Date: 1/12/2022 1:30:39 PM ******/
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
