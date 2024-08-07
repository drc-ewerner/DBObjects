USE [Alaska_udb_dev]
GO
/****** Object:  Table [Audit].[SchemaChangeLog]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[SchemaChangeLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Time] [datetime] NOT NULL,
	[Username] [sysname] NOT NULL,
	[Host] [sysname] NOT NULL,
	[Event] [sysname] NOT NULL,
	[SchemaName] [sysname] NULL,
	[ObjectName] [sysname] NULL,
	[ObjectType] [sysname] NULL,
	[Sql] [nvarchar](max) NULL,
 CONSTRAINT [pk_SchemaChangeLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[SchemaChangeLog] ADD  DEFAULT (getdate()) FOR [Time]
GO
ALTER TABLE [Audit].[SchemaChangeLog] ADD  DEFAULT (suser_sname()) FOR [Username]
GO
ALTER TABLE [Audit].[SchemaChangeLog] ADD  DEFAULT (host_name()) FOR [Host]
GO
