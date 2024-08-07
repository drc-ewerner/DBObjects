USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestEvent].[TestScoreGroups]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TestEvent].[TestScoreGroups](
	[AdministrationID] [int] NOT NULL,
	[TestEventID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Score] [varchar](50) NOT NULL,
	[Rescoreflag] [int] NOT NULL,
	[PartID] [varchar](50) NOT NULL,
	[PartAdministrationID] [int] NOT NULL,
	[PartTestEventID] [int] NOT NULL,
	[PartTest] [varchar](50) NOT NULL,
	[PartScore] [varchar](50) NOT NULL,
	[PartRescoreflag] [int] NOT NULL,
 CONSTRAINT [pk_TestScoreGroups] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestEventID] ASC,
	[Test] ASC,
	[Score] ASC,
	[Rescoreflag] ASC,
	[PartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [TestEvent].[TestScoreGroups]  WITH CHECK ADD  CONSTRAINT [fk_TestScoreGroups_TestScores] FOREIGN KEY([AdministrationID], [TestEventID], [Test], [Score], [Rescoreflag])
REFERENCES [TestEvent].[TestScores] ([AdministrationID], [TestEventID], [Test], [Score], [RescoreFlag])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestEvent].[TestScoreGroups] CHECK CONSTRAINT [fk_TestScoreGroups_TestScores]
GO
