USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormScorePSLookup]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestFormScorePSLookup](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[Score] [varchar](50) NOT NULL,
	[SubgroupName] [varchar](50) NOT NULL,
	[SubgroupValue] [varchar](100) NOT NULL,
	[ScaleScore] [decimal](10, 5) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](100) NOT NULL,
 CONSTRAINT [pk_TestFormScorePSLookup] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC,
	[Score] ASC,
	[SubgroupName] ASC,
	[SubgroupValue] ASC,
	[ScaleScore] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestFormScorePSLookup] ADD  DEFAULT ('') FOR [SubgroupName]
GO
ALTER TABLE [Scoring].[TestFormScorePSLookup] ADD  DEFAULT ('') FOR [SubgroupValue]
GO
ALTER TABLE [Scoring].[TestFormScorePSLookup]  WITH CHECK ADD  CONSTRAINT [fk_TestFormScorePSLookup_TestFormScores] FOREIGN KEY([AdministrationID], [Test], [Level], [Form], [Score])
REFERENCES [Scoring].[TestFormScores] ([AdministrationID], [Test], [Level], [Form], [Score])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormScorePSLookup] CHECK CONSTRAINT [fk_TestFormScorePSLookup_TestFormScores]
GO
