USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebUserDemographic_BadRecords_ECA_CascadeUpdate]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebUserDemographic_BadRecords_ECA_CascadeUpdate](
	[UserId] [uniqueidentifier] NOT NULL,
	[NamePrefix] [varchar](10) NULL,
	[FirstName] [varchar](30) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[LastName] [varchar](30) NULL,
	[NameSuffix] [varchar](10) NULL,
	[AddrLine1] [varchar](50) NULL,
	[AddrLine2] [varchar](50) NULL,
	[City] [varchar](30) NULL,
	[State] [varchar](2) NULL,
	[Zip5] [varchar](5) NULL,
	[Zip4] [varchar](4) NULL,
	[Phone] [varchar](12) NULL,
	[PhoneExtn] [varchar](10) NULL
) ON [PRIMARY]
GO
