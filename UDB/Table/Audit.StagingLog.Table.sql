USE [Alaska_udb_dev]
GO
/****** Object:  Table [Audit].[StagingLog]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[StagingLog](
	[StagingLogID] [int] IDENTITY(1,1) NOT NULL,
	[AdministrationID] [int] NULL,
	[Context] [varchar](100) NULL,
	[StartTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Status] [varchar](10) NULL,
	[Duration]  AS (datediff(millisecond,[StartTime],[EndTime])),
	[Results] [xml] NULL,
PRIMARY KEY CLUSTERED 
(
	[StagingLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
