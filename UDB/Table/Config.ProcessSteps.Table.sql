USE [Alaska_udb_dev]
GO
/****** Object:  Table [Config].[ProcessSteps]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[ProcessSteps](
	[AdministrationID] [int] NOT NULL,
	[Process] [varchar](30) NOT NULL,
	[StepID] [int] NOT NULL,
	[StepName] [varchar](30) NOT NULL,
	[Status] [varchar](30) NOT NULL,
	[Description] [varchar](1000) NULL,
	[PluginAssembly] [varchar](200) NULL,
	[PluginClass] [varchar](500) NULL,
	[PluginVersion] [varchar](100) NULL,
	[PluginConfig] [xml] NULL,
	[LastUpdated] [datetime] NULL,
	[LastUpdatedBy] [varchar](100) NULL,
 CONSTRAINT [pk_ProcessSteps] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Process] ASC,
	[StepID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Config].[ProcessSteps] ADD  DEFAULT ('Active') FOR [Status]
GO
ALTER TABLE [Config].[ProcessSteps]  WITH CHECK ADD  CONSTRAINT [fk_ProcessSteps_Processes] FOREIGN KEY([AdministrationID], [Process])
REFERENCES [Config].[Processes] ([AdministrationID], [Process])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Config].[ProcessSteps] CHECK CONSTRAINT [fk_ProcessSteps_Processes]
GO
