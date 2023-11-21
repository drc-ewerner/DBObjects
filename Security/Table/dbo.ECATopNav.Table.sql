USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[ECATopNav]    Script Date: 11/21/2023 8:39:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ECATopNav](
	[Client] [varchar](10) NOT NULL,
	[ECATopNavSort] [int] NOT NULL,
	[ECATopNav] [varchar](50) NOT NULL,
	[ECATopNavPermission] [varchar](50) NOT NULL,
	[IsPublic] [bit] NULL,
	[LegacyQueryStringAppValue] [varchar](50) NOT NULL,
 CONSTRAINT [UQ_ECATopNav] UNIQUE NONCLUSTERED 
(
	[ECATopNav] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
