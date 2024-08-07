USE [Alaska_udb_dev]
GO
/****** Object:  Table [Audit].[ObjectAuditLog]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[ObjectAuditLog](
	[AdministrationID] [int] NOT NULL,
	[ObjectID] [int] NOT NULL,
	[ObjectType] [varchar](100) NOT NULL,
	[StagingLogID] [int] NOT NULL,
 CONSTRAINT [pk_ObjectAuditLog] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[ObjectID] ASC,
	[ObjectType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
