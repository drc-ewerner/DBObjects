USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebMasterPermissions]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebMasterPermissions](
	[MasterPermissionId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[MasterDescription] [varchar](300) NULL,
	[Code] [varchar](100) NOT NULL,
	[Client] [varchar](100) NULL,
 CONSTRAINT [PK__eWebMasterPermissions] PRIMARY KEY NONCLUSTERED 
(
	[MasterPermissionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
