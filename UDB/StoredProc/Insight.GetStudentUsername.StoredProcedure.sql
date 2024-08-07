USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Insight].[GetStudentUsername]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [Insight].[GetStudentUsername]
	@AdministrationID int,
	@StudentID int,
	@Username varchar(50) output

as set nocount on;

declare @retry int=5;
declare @UsernameMode varchar(1000),@ShortPasswords varchar(1000),@Password varchar(20),@UppercaseUsername varchar(1000),@LowercaseUsername varchar(1000);
declare @UsernameLevel varchar(1000);
declare @temppwd table(n int not null,Password varchar(20) not null);

while (@retry>0) begin try

	select @UsernameMode=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','TicketUsernameMode','')
	select @ShortPasswords=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','ShortPasswords','N')
	select @UppercaseUsername=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','TicketUsernameUppercase','N')
	select @LowercaseUsername=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','TicketUsernameLowercase','N')
	select @UsernameLevel=Insight.GetConfigExtensionValue(@AdministrationID,'Insight','TicketUsernameLevel','')

	if (@UsernameMode='StateStudentID') begin
		select @Username=left(StateStudentID,20) from Core.Student where AdministrationID=@AdministrationID and StudentID=@StudentID;
		end 
	else begin
		select @Username=Username from Student.InsightUsername where AdministrationID=@AdministrationID and StudentID=@StudentID;
	end;
	
	if (@Username is null) begin

		declare @stem varchar(44),@number int,@lastname nvarchar(100),@firstname nvarchar(100);
		declare @UsernameStemLength int;
		
		select @UsernameStemLength=isnull(try_parse(Insight.GetConfigExtensionValue(@AdministrationID,'Insight','UsernameStemLength','') as int),10);
		select @lastname=LastName,@firstname=FirstName from Core.Student where AdministrationID=@AdministrationID and StudentID=@StudentID;
		set @lastname = cast(@lastname as varchar) Collate SQL_Latin1_General_CP1253_CI_AI
		set @firstname = cast(@firstname as varchar) Collate SQL_Latin1_General_CP1253_CI_AI

		while PATINDEX('%[^a-z]%',@lastname) > 0
			begin
				set @lastname = STUFF(@lastname,PATINDEX('%[^a-z]%',@lastname),1,'')
			end;
		while PATINDEX('%[^a-z]%',@firstname) > 0
			begin
				set @firstname = STUFF(@firstname,PATINDEX('%[^a-z]%',@firstname),1,'')
			end;

		if (@UsernameMode='FirstNameLastInitial') begin
			select @stem=replace(left(@firstname,@UsernameStemLength)+left(@lastname,1),' ','')-- from Core.Student where AdministrationID=@AdministrationID and StudentID=@StudentID;
			end 
		else begin
			select @stem=replace(left(@firstname,1)+left(@lastname,@UsernameStemLength),' ','')-- from Core.Student where AdministrationID=@AdministrationID and StudentID=@StudentID;
		end;

		if (@UsernameLevel='Client') begin
			select @number=isnull(max(UsernameNumber),0)+1 from Student.InsightUsername where UsernameStem=@stem;
			end
		else begin
			select @number=isnull(max(UsernameNumber),0)+1 from Student.InsightUsername where AdministrationID=@AdministrationID and UsernameStem=@stem;
		end;

		insert into @temppwd
		select * from Insight.GeneratePassword(@AdministrationID,@Username,1)
		--exec Insight.GeneratePassword @AdministrationID,@Username,1

		select @Password=Password from @temppwd


		if (@UppercaseUsername='Y') begin
			set @stem=upper(@stem)
		end else if (@LowercaseUsername='Y') begin
			set @stem=lower(@stem)
		end;
		insert Student.InsightUsername (AdministrationID,StudentID,UsernameStem,UsernameNumber,Password)
		select @AdministrationID,@StudentID,@stem,@number,@Password;

		set @Username=@stem+cast(@number as varchar(6));

	end;

	set @retry=0;

end try begin catch

	set @retry-=1;	

	if (@retry=0) raiserror('Could not assign Username',16,0) else waitfor delay '00:00:00.5';

end catch;
GO
