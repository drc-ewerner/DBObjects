USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebAdminRoleScreen]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebAdminRoleScreen](
	[AdminRoleScreenId] [int] IDENTITY(1,1) NOT NULL,
	[ScreenCode] [varchar](100) NOT NULL,
	[AdminId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
	[IsDefaultSelected] [bit] NOT NULL,
	[TooltipHtml] [varchar](1000) NOT NULL,
 CONSTRAINT [PK_eWebAdminRoleScreen] PRIMARY KEY CLUSTERED 
(
	[AdminRoleScreenId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
