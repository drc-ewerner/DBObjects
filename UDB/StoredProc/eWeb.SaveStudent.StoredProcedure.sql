USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[SaveStudent]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[SaveStudent]
	@AdministrationID int,
	@StudentID int,
	@LastName varchar(50),
	@FirstName varchar(50),
	@MiddleName varchar(50),
	@Gender varchar(1),
	@Grade varchar(2),
	@BirthDate datetime,
	@StateStudentID varchar(30),
	@DistrictStudentID varchar(30),
	@DistrictCode varchar(15),
	@SchoolCode varchar(15)
as begin

set nocount on;

declare @newID int
DECLARE @currentDate [datetime]
SET @currentDate = GetDate()

if (@studentID=0) begin
	
	insert Core.Student (AdministrationID,LastName,FirstName,MiddleName,Gender,Grade,BirthDate,StateStudentID,DistrictStudentID,DistrictCode,SchoolCode,CreateDate,UpdateDate) 
	select @AdministrationID,@LastName,@FirstName,@MiddleName,@Gender,@Grade,@BirthDate,@StateStudentID,@DistrictStudentID,@DistrictCode,@SchoolCode, @currentDate,@currentDate
		
	set @newID=scope_identity()

end else begin

	update Core.Student set 
		LastName=@LastName,FirstName=@FirstName,MiddleName=@MiddleName,Gender=@Gender,Grade=@Grade,
		BirthDate=@BirthDate,StateStudentID=@StateStudentID,DistrictStudentID=@DistrictStudentID,DistrictCode=@DistrictCode,SchoolCode=@SchoolCode,UpdateDate = @currentDate
	where AdministrationID=@AdministrationID and StudentID=@StudentID	
	
	set @newID=@StudentID	
end

select StudentID=@newID	

end

GO
