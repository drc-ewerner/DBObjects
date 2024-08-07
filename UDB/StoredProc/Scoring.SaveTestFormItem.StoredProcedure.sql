USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Scoring].[SaveTestFormItem]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Scoring].[SaveTestFormItem]
	@AdministrationID int, 
	@Test varchar(50), 
	@Level varchar(20), 
	@Form varchar(20), 
	@ItemID varchar(50), 
	@Position int,
	@FormVersion datetime,
	@ItemVersion datetime,
	@SessionNumber int=NULL,
	@ItemStatus varchar(10)=NULL	
AS
BEGIN
	update Scoring.TestFormItems set
        Position = @Position,
		SessionNumber = ISNULL(@SessionNumber, SessionNumber),
		ItemStatus=ISNULL(@ItemStatus, ItemStatus)
    where AdministrationID = @AdministrationID and
        Test = @Test and
        Level = @Level and
        Form = @Form and
        ItemID = @ItemID
        
    if @@rowcount = 0 
    begin          
        insert into Scoring.TestFormItems 
            (AdministrationID, Test, Level, Form, ItemID,
            Position, SessionNumber, ItemStatus)
        values
            (@AdministrationID, @Test, @Level, @Form, @ItemID,
            @Position, @SessionNumber, @ItemStatus)
    end
    
	if @FormVersion is not null and 
		not exists(
		select AdministrationID
		from Scoring.TestFormItemVersions
		where 
			AdministrationID = @AdministrationID and
            Test = @Test and
            Level = @Level and
            Form = @Form and
            ItemID = @ItemID and
            FormVersion = @FormVersion)            
	begin
		insert into Scoring.TestFormItemVersions 
			(AdministrationID, Test, Level, Form, ItemID, FormVersion, ItemVersion)
		values
			(@AdministrationID, @Test, @Level, @Form, @ItemID, @FormVersion, @ItemVersion)
    end    
END
GO
