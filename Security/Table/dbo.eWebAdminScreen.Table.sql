USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebAdminScreen]    Script Date: 11/21/2023 8:39:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebAdminScreen](
	[AdminScreenId] [int] IDENTITY(1,1) NOT NULL,
	[ScreenCode] [nvarchar](100) NOT NULL,
	[AdminId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdminScreenId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
