USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentUsername]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [eWeb].[GetStudentUsername]
	@AdministrationID int,
	@StudentID int,
	@Username varchar(20) output

as set nocount on;

declare @retry int=5;
declare @UsernameMode varchar(1000),@ShortPasswords varchar(1000),@Password varchar(20),@UppercaseUsername varchar(1000);
declare @UsernameLevel varchar(1000);

while (@retry>0) begin try

	select @UsernameMode=eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','TicketUsernameMode','')
	select @ShortPasswords=eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','ShortPasswords','N')
	select @UppercaseUsername=eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','TicketUsernameUppercase','N')
	select @UsernameLevel=eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','TicketUsernameLevel','')

	if (@UsernameMode='StateStudentID') begin
		select @Username=StateStudentID from Core.Student where AdministrationID=@AdministrationID and StudentID=@StudentID;
		end 
	else begin
		select @Username=Username from Student.InsightUsername where AdministrationID=@AdministrationID and StudentID=@StudentID;
	end;
	
	if (@Username is null) begin

		declare @stem varchar(14),@number int;

		if (@UsernameMode='FirstNameLastInitial') begin
			select @stem=replace(left(FirstName,10)+left(LastName,1),' ','') from Core.Student where AdministrationID=@AdministrationID and StudentID=@StudentID;
			end 
		else begin
			select @stem=replace(left(FirstName,1)+left(LastName,10),' ','') from Core.Student where AdministrationID=@AdministrationID and StudentID=@StudentID;
		end;

		if (@UsernameLevel='Client') begin
			select @number=isnull(max(UsernameNumber),0)+1 from Student.InsightUsername where UsernameStem=@stem;
			end
		else begin
			select @number=isnull(max(UsernameNumber),0)+1 from Student.InsightUsername where AdministrationID=@AdministrationID and UsernameStem=@stem;
		end;

		with q as (
			select Value 
			from Aux.PasswordSeeds 
			where Value!='TEST' 
			except 
			select left(Password,4)
			from Document.TestTicket t
			where t.AdministrationID=@AdministrationID and t.Username=@Username
		)
		select @Password=(select top(1) Value from q order by newid())
		if ((@ShortPasswords is null) or (@ShortPasswords!='Y')) begin
			select @Password=@Password+(select top(1) right('000'+s,4) from Aux.Numbers where s not like '%666%' order by newid());
		end;

		if (@UppercaseUsername='Y') begin
			set @stem=upper(@stem)
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
