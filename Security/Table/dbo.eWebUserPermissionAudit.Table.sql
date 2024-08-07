USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebUserPermissionAudit]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebUserPermissionAudit](
	[UserPermissionAuditID] [int] IDENTITY(1,1) NOT NULL,
	[UserAuditID] [int] NOT NULL,
	[AdminID] [int] NOT NULL,
	[Role] [nvarchar](50) NULL,
	[PermissionID] [nchar](10) NOT NULL,
	[Action] [nchar](10) NULL,
 CONSTRAINT [PK_eWebUserPermissionAudit] PRIMARY KEY CLUSTERED 
(
	[UserPermissionAuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
