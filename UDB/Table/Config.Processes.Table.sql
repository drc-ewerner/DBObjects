USE [Alaska_udb_dev]
GO
/****** Object:  Table [Config].[Processes]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Config].[Processes](
	[AdministrationID] [int] NOT NULL,
	[Process] [varchar](30) NOT NULL,
	[Priority] [int] NULL,
	[Status] [varchar](30) NOT NULL,
	[PollingInterval] [int] NOT NULL,
	[Description] [varchar](1000) NULL,
	[Config] [xml] NULL,
	[LastUpdated] [datetime] NULL,
	[LastUpdatedBy] [varchar](100) NULL,
 CONSTRAINT [pk_Processes] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Process] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Config].[Processes] ADD  DEFAULT ('Active') FOR [Status]
GO
ALTER TABLE [Config].[Processes] ADD  DEFAULT ((2)) FOR [PollingInterval]
GO
