USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestSessionSubTestLevels]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestSessionSubTestLevels](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[SubTest] [varchar](50) NOT NULL,
	[SubLevel] [varchar](20) NOT NULL,
	[LevelMatchGroup] [varchar](50) NULL,
	[DisplayOrderTest] [int] NULL,
	[DisplayOrderSubTest] [int] NULL,
	[DisplayOrderSubLevel] [int] NULL,
	[PreSelect] [bit] NULL,
	[AllowMultipleLevelsEnforceSingular] [bit] NULL,
	[FTSubTest] [varchar](50) NULL,
	[FTSubLevel] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[SubTest] ASC,
	[SubLevel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestSessionSubTestLevels]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [SubTest], [SubLevel])
REFERENCES [Scoring].[TestLevels] ([AdministrationID], [Test], [Level])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[TestSessionSubTestLevels]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [Level])
REFERENCES [Scoring].[TestLevels] ([AdministrationID], [Test], [Level])
GO
