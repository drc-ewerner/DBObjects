USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebUserProfile_BadRecords_ECA_CascadeUpdate]    Script Date: 1/12/2022 1:43:31 PM ******/
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
