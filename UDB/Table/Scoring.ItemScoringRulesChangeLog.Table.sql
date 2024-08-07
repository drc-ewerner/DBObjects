USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[ItemScoringRulesChangeLog]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[ItemScoringRulesChangeLog](
	[AdministrationID] [int] NOT NULL,
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[ScoringRulesXml] [xml] NOT NULL,
	[Action] [varchar](10) NOT NULL,
	[LogDate] [datetime] NOT NULL,
 CONSTRAINT [pk_ItemScoringRulesChangeLog] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Scoring].[ItemScoringRulesChangeLog] ADD  DEFAULT (getdate()) FOR [LogDate]
GO
