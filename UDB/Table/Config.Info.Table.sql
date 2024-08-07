USE [Alaska_udb_dev]
GO
/****** Object:  Table [Config].[Info]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[Info](
	[Version]  AS ((((CONVERT([varchar],[VersionMajor])+'.')+CONVERT([varchar],[VersionMinor]))+'.')+CONVERT([varchar],[VersionRevision])) PERSISTED,
	[VersionMajor] [int] NULL,
	[VersionMinor] [int] NULL,
	[VersionRevision] [int] NULL,
	[VersionDate] [datetime] NULL,
	[Description] [varchar](100) NULL,
	[Owner] [varchar](100) NULL,
	[Environment] [varchar](100) NULL,
	[CreateUsername] [sysname] NOT NULL,
	[CreateHost] [sysname] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[ID] [tinyint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [uq_Info] UNIQUE NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Config].[Info] ADD  DEFAULT (user_name()) FOR [CreateUsername]
GO
ALTER TABLE [Config].[Info] ADD  DEFAULT (host_name()) FOR [CreateHost]
GO
ALTER TABLE [Config].[Info] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Config].[Info] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
ALTER TABLE [Config].[Info]  WITH CHECK ADD  CONSTRAINT [ck_Info_ID] CHECK  (([ID]=(1)))
GO
ALTER TABLE [Config].[Info] CHECK CONSTRAINT [ck_Info_ID]
GO
