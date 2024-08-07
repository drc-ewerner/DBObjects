USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestFormScores]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestFormScores](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[Score] [varchar](50) NOT NULL,
	[MaxRawScore] [decimal](10, 5) NULL,
	[MaxScaleScore] [decimal](10, 5) NULL,
	[MaxItemsAttempted] [int] NULL,
	[AttemptThreshold] [int] NULL,
	[RawScoreThreshold] [decimal](10, 5) NULL,
	[MinScaleScore] [decimal](10, 5) NULL,
	[ScalingFactorMultiply] [decimal](10, 5) NULL,
	[ScalingFactorAdd] [decimal](10, 5) NULL,
	[ScalingConstantD] [decimal](10, 5) NULL,
	[ScalingConstantP] [decimal](10, 5) NULL,
	[MinAbility] [decimal](10, 5) NULL,
	[MaxAbility] [decimal](10, 5) NULL,
	[MinItemsRequired] [int] NULL,
	[AverageParamA] [decimal](10, 5) NULL,
	[AverageParamB] [decimal](10, 5) NULL,
 CONSTRAINT [pk_TestFormScores] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC,
	[Score] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestFormScores]  WITH CHECK ADD  CONSTRAINT [fk_TestFormScores_TestForms] FOREIGN KEY([AdministrationID], [Test], [Level], [Form])
REFERENCES [Scoring].[TestForms] ([AdministrationID], [Test], [Level], [Form])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestFormScores] CHECK CONSTRAINT [fk_TestFormScores_TestForms]
GO
ALTER TABLE [Scoring].[TestFormScores]  WITH CHECK ADD  CONSTRAINT [fk_TestFormScores_TestScores] FOREIGN KEY([AdministrationID], [Test], [Score])
REFERENCES [Scoring].[TestScores] ([AdministrationID], [Test], [Score])
GO
ALTER TABLE [Scoring].[TestFormScores] CHECK CONSTRAINT [fk_TestFormScores_TestScores]
GO
