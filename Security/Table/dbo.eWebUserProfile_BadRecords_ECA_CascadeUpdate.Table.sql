USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebUserProfile_BadRecords_ECA_CascadeUpdate]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebUserProfile_BadRecords_ECA_CascadeUpdate](
	[ProfileId] [int] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[Role] [nvarchar](50) NULL,
	[AdminId] [int] NULL,
	[DistrictCode] [nvarchar](50) NULL,
	[SchoolCode] [nvarchar](50) NULL,
	[RoleID] [int] NULL
) ON [PRIMARY]
GO
