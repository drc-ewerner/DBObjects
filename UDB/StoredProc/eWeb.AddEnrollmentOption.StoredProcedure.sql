USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[AddEnrollmentOption]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create procedure [eWeb].[AddEnrollmentOption] 
	@AdminId int,
	@AppletCode varchar(10),
	@Dimension varchar(50),
	@DimensionOption varchar(50),  
	@Description varchar(50),
	@AttributeName varchar(25) /* maps to an EPIC Attribute used in rare cases to show/hide grid cells/rows/tables */
	
AS
BEGIN
	declare @dimensionId int
	declare @dimensionOptionID int
	declare @itemID int
	
	if exists(select * from [eWeb].[EnrollmentDimension] where adminid=@adminID and AppletCode=@appletCode and Name=@Dimension)
		select @dimensionID=DimensionID from [eWeb].[EnrollmentDimension] where adminid=@adminID and AppletCode=@appletCode and Name=@Dimension
	else
	begin
		insert [eWeb].[EnrollmentDimension] ([AdminID], [Name], [AppletCode])
		values (@adminID, @Dimension, @AppletCode)
		
		select @dimensionID=SCOPE_IDENTITY()
	end
	
	if exists(select * from [eWeb].[EnrollmentDimensionOption] where DimensionID=@DimensionID and Value=@DimensionOption)
		select @dimensionOptionID=DimensionOptionID from [eWeb].[EnrollmentDimensionOption] where DimensionID=@DimensionID and Value=@DimensionOption
	else
	begin
		insert [eWeb].[EnrollmentDimensionOption] ([DimensionID], [Value])
		values (@DimensionID, @DimensionOption)
		
		select @dimensionOptionID=SCOPE_IDENTITY()
	end
	
	if exists(select * from [eWeb].[EnrollmentItem] where AdminId=@adminID and Description=@Description and AppletCode=@appletCode)
		select @itemID=ItemId from [eWeb].[EnrollmentItem] where AdminId=@adminID and Description=@Description and AppletCode=@appletCode
	else
	begin
		insert [eWeb].[EnrollmentItem] (AdminId, Description, AttributeName, AppletCode)
		values (@adminID, @Description, @AttributeName, @appletCode)
		
		select @itemID=SCOPE_IDENTITY()
	end
	
	if not exists(select * from [eWeb].[EnrollmentItemDimensionOption] where ItemID=@itemID and DimensionOptionID=@dimensionOptionID)
		insert [eWeb].[EnrollmentItemDimensionOption] ([ItemID], [DimensionOptionID])
		values (@itemID, @dimensionOptionID)
END
GO
