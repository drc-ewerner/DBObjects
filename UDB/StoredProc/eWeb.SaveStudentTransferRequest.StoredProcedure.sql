USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[SaveStudentTransferRequest]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [eWeb].[SaveStudentTransferRequest]
	@StudentTransferRequestId int,
	@AdminID int,
	@FromDistrictCode varchar(15),
	@FromSchoolCode varchar(15),
	@ToDistrictCode varchar(15),
	@ToSchoolCode varchar(15),
	@FromCompletedContentArea1 bit,
	@FromCompletedContentArea2 bit,
	@FromCompletedContentArea3 bit,
	@FromCompletedContentArea4 bit,
	@FromTestingMode varchar(50),
	@ToCompletedContentArea1 bit,
	@ToCompletedContentArea2 bit,
	@ToCompletedContentArea3 bit,
	@ToCompletedContentArea4 bit,
	@ToTestingMode varchar(50),
	@FirstName varchar(100),
	@LastName varchar(100),
	@BirthDate varchar(20),
	@StateStudentID varchar(30),
	@Grade varchar(2),
	@Status varchar(50),
	@SendersPhoneNumber varchar(10),
	@TimeOfRequest DateTime,
	@SendersEmail VARCHAR(256),
	@SendersFullName VARCHAR(60),
	@SendersUserId UNIQUEIDENTIFIER
as begin

set nocount on;

declare @newID int

if (@StudentTransferRequestId=0) begin
	
	insert [eWeb].[StudentTransferRequest] (
			AdminID
           ,FromDistrictCode
           ,FromSchoolCode
           ,ToDistrictCode
           ,ToSchoolCode
           ,FromCompletedContentArea1
           ,FromCompletedContentArea2
           ,FromCompletedContentArea3
           ,FromCompletedContentArea4
           ,FromTestingMode
           ,ToCompletedContentArea1
           ,ToCompletedContentArea2
           ,ToCompletedContentArea3
           ,ToCompletedContentArea4
           ,ToTestingMode
           ,FirstName
           ,LastName
           ,BirthDate
           ,StateStudentID
           ,Grade
           ,Status
           ,SendersPhoneNumber
		   ,TimeOfRequest
		   ,SendersEmail
		   ,SendersFullName
		   ,SendersUserId
		   ) 
	select @AdminID
           ,@FromDistrictCode
           ,@FromSchoolCode
           ,@ToDistrictCode
           ,@ToSchoolCode
           ,@FromCompletedContentArea1
           ,@FromCompletedContentArea2
           ,@FromCompletedContentArea3
           ,@FromCompletedContentArea4
           ,@FromTestingMode
           ,@ToCompletedContentArea1
           ,@ToCompletedContentArea2
           ,@ToCompletedContentArea3
           ,@ToCompletedContentArea4
           ,@ToTestingMode
           ,@FirstName
           ,@LastName
           ,@BirthDate
           ,@StateStudentID
           ,@Grade
           ,@Status
           ,@SendersPhoneNumber
		   ,@TimeOfRequest
		   ,@SendersEmail
		   ,@SendersFullName
		   ,@SendersUserId
	set @newID=scope_identity()

end else begin

	update [eWeb].[StudentTransferRequest] 
	set 
			AdminID=@AdminID
           ,FromDistrictCode=@FromDistrictCode
           ,FromSchoolCode=@FromSchoolCode
           ,ToDistrictCode=@ToDistrictCode
           ,ToSchoolCode=@ToSchoolCode
           ,FromCompletedContentArea1=@FromCompletedContentArea1
           ,FromCompletedContentArea2=@FromCompletedContentArea2
           ,FromCompletedContentArea3=@FromCompletedContentArea3
           ,FromCompletedContentArea4=@FromCompletedContentArea4
           ,FromTestingMode=@FromTestingMode
           ,ToCompletedContentArea1=@ToCompletedContentArea1
           ,ToCompletedContentArea2=@ToCompletedContentArea2
           ,ToCompletedContentArea3=@ToCompletedContentArea3
           ,ToCompletedContentArea4=@ToCompletedContentArea4
           ,ToTestingMode=@ToTestingMode
           ,FirstName=@FirstName
           ,LastName=@LastName
           ,BirthDate=@BirthDate
           ,StateStudentID=@StateStudentID
           ,Grade=@Grade
           ,Status=@Status
           ,SendersPhoneNumber=@SendersPhoneNumber
		   ,TimeOfRequest=@TimeOfRequest
		   ,SendersEmail=@SendersEmail
		   ,SendersFullName=@SendersFullName
		   ,SendersUserId=@SendersUserId
	where AdminID=@AdminID and StudentTransferRequestId=@StudentTransferRequestId	
	
	set @newID=@StudentTransferRequestId	
end

select @StudentTransferRequestId=@newID	

end
GO
