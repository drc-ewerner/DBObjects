USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebScreenAccessInactive]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebScreenAccessInactive](
	[UserId] [uniqueidentifier] NOT NULL,
	[ScreenAccessId] [int] NOT NULL,
	[ProfileId] [int] NOT NULL,
	[PermissionId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[ScreenAccessId] ASC,
	[ProfileId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
