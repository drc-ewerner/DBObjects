USE [Alaska_udb_dev]
GO
/****** Object:  Table [Audit].[StagingErrorLog]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[StagingErrorLog](
	[AdministrationID] [int] NULL,
	[StagingErrorLogID] [int] IDENTITY(1,1) NOT NULL,
	[StagingLogID] [int] NULL,
	[ErrorTime] [datetime] NOT NULL,
	[Error] [xml] NULL,
 CONSTRAINT [pk_StagingErrorLog] PRIMARY KEY CLUSTERED 
(
	[StagingErrorLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[StagingErrorLog] ADD  DEFAULT (getdate()) FOR [ErrorTime]
GO
