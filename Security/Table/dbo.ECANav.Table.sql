USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[ECANav]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ECANav](
	[Client] [varchar](10) NOT NULL,
	[LegacyTopNav] [varchar](50) NOT NULL,
	[LegacySubNav] [nvarchar](50) NULL,
	[SubNavPermissions] [varchar](8000) NULL,
	[TopNavPermissions] [varchar](8000) NULL,
	[ECATopNav] [varchar](50) NOT NULL,
	[ECASubNav] [nvarchar](50) NULL,
	[ECATopNavSort] [int] NULL,
	[SubNavParameter] [varchar](255) NULL,
 CONSTRAINT [UQ_LegacyTopSubNav] UNIQUE NONCLUSTERED 
(
	[LegacyTopNav] ASC,
	[LegacySubNav] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
