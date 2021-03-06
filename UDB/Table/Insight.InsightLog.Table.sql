USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[InsightLog]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[InsightLog](
	[AdministrationID] [int] NOT NULL,
	[InsightLogID] [int] IDENTITY(1,1) NOT NULL,
	[LogCode] [varchar](10) NOT NULL,
	[StartTime]  AS (dateadd(millisecond, -[Duration],[LogTime])),
	[Duration] [int] NULL,
	[LogTime] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[InsightLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Insight].[InsightLog] ADD  DEFAULT (getdate()) FOR [LogTime]
GO
