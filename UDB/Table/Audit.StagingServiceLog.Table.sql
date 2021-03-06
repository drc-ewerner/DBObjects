USE [Alaska_udb_dev]
GO
/****** Object:  Table [Audit].[StagingServiceLog]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[StagingServiceLog](
	[AdministrationID] [int] NULL,
	[StagingServiceLogID] [int] IDENTITY(1,1) NOT NULL,
	[ParentLogID] [int] NULL,
	[LogAction] [varchar](100) NULL,
	[LogTime] [datetime] NOT NULL,
	[LogData] [xml] NULL,
PRIMARY KEY CLUSTERED 
(
	[StagingServiceLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[StagingServiceLog] ADD  DEFAULT (getdate()) FOR [LogTime]
GO
