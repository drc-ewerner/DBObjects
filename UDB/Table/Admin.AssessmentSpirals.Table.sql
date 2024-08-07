USE [Alaska_udb_dev]
GO
/****** Object:  Table [Admin].[AssessmentSpirals]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Admin].[AssessmentSpirals](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[SpiralNumber] [int] NOT NULL,
	[SpiralField1] [varchar](50) NOT NULL,
 CONSTRAINT [pk_AssessmentSpirals] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[SpiralField1] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Admin].[AssessmentSpirals] ADD  DEFAULT ('') FOR [SpiralField1]
GO
ALTER TABLE [Admin].[AssessmentSpirals]  WITH CHECK ADD  CONSTRAINT [fk_AssessmentSpirals_Scoring_TestLevels] FOREIGN KEY([AdministrationID], [Test], [Level])
REFERENCES [Scoring].[TestLevels] ([AdministrationID], [Test], [Level])
GO
ALTER TABLE [Admin].[AssessmentSpirals] CHECK CONSTRAINT [fk_AssessmentSpirals_Scoring_TestLevels]
GO
