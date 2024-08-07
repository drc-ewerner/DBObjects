USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestSession].[SubTestLevels]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TestSession].[SubTestLevels](
	[AdministrationID] [int] NOT NULL,
	[TestSessionID] [int] NOT NULL,
	[SubTest] [varchar](50) NOT NULL,
	[SubLevel] [varchar](20) NOT NULL,
 CONSTRAINT [pk_SubTestLevels] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestSessionID] ASC,
	[SubTest] ASC,
	[SubLevel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [TestSession].[SubTestLevels]  WITH CHECK ADD  CONSTRAINT [fk_SubTestLevels_Core_TestSession] FOREIGN KEY([AdministrationID], [TestSessionID])
REFERENCES [Core].[TestSession] ([AdministrationID], [TestSessionID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestSession].[SubTestLevels] CHECK CONSTRAINT [fk_SubTestLevels_Core_TestSession]
GO
ALTER TABLE [TestSession].[SubTestLevels]  WITH CHECK ADD  CONSTRAINT [fk_SubTestLevels_Scoring_TestLevels] FOREIGN KEY([AdministrationID], [SubTest], [SubLevel])
REFERENCES [Scoring].[TestLevels] ([AdministrationID], [Test], [Level])
GO
ALTER TABLE [TestSession].[SubTestLevels] CHECK CONSTRAINT [fk_SubTestLevels_Scoring_TestLevels]
GO
