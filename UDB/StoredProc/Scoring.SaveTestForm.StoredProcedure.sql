USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[SaveTestForm]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Scoring].[SaveTestForm] 
	@AdministrationID int, 
	@Test varchar(50), 
	@Level varchar(20), 
	@Form varchar(20), 
	@DocumentCode varchar(20), 
	@Description varchar(1000), 
	@Format varchar(50),
	@OnlineData XML,
	@FormName varchar(50),
	@FormSet varchar(20), 
	@Status varchar(20), 
	@FormVersion datetime,
	@VisualIndicator varchar(2)=null,
	@SpiralingOption varchar(20)=null,
	@FormSessionName varchar(100)=null,
	@LCID varchar(20)=null
AS
BEGIN
	update Scoring.TestForms set
		DocumentCode = case when len(@DocumentCode) > 0 then @DocumentCode else DocumentCode end,
		Description = @Description,
		Format = @Format,
		OnlineData = isnull(@OnlineData, OnlineData),
		FormName = @FormName,
		FormSet = @FormSet,
		Status = @Status,
		VisualIndicator = @VisualIndicator,
		SpiralingOption = @SpiralingOption,
		FormSessionName = @FormSessionName,
		LCID = @LCID
	where AdministrationID = @AdministrationID and
		Test = @Test and
		Level = @Level and
		Form = @Form
		
	if @@rowcount = 0          
	begin          
		insert into Scoring.TestForms 
			(AdministrationID, Test, Level, Form,
			DocumentCode, Description, Format, OnlineData, FormName, FormSet, Status, VisualIndicator,
			SpiralingOption,FormSessionName,LCID)
		values
			(@AdministrationID, @Test, @Level, @Form,
			@DocumentCode, @Description, @Format, @OnlineData, @FormName, @FormSet, @Status, @VisualIndicator,
			@SpiralingOption,@FormSessionName,@LCID)
	end
		
	if @FormVersion is not null and not exists(
		select AdministrationID
		from Scoring.TestFormVersions 
		where 
			AdministrationID = @AdministrationID and
            Test = @Test and
            Level = @Level and
            Form = @Form and
            FormVersion = @FormVersion)
            
	begin
		insert into Scoring.TestFormVersions 
			(AdministrationID, Test, Level, Form, FormVersion,
			OnlineData)
		values
			(@AdministrationID, @Test, @Level, @Form, @FormVersion,
			@OnlineData)
    end    
END
GO
