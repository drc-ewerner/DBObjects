USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestEvent].[TestScoreExtensions]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TestEvent].[TestScoreExtensions](
	[AdministrationID] [int] NOT NULL,
	[TestEventID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Score] [varchar](50) NOT NULL,
	[RescoreFlag] [int] NOT NULL,
	[Category] [varchar](50) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](100) NOT NULL,
 CONSTRAINT [pk_TestScoreExtensions] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestEventID] ASC,
	[Test] ASC,
	[Score] ASC,
	[RescoreFlag] ASC,
	[Category] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [TestEvent].[TestScoreExtensions] ADD  DEFAULT ((0)) FOR [RescoreFlag]
GO
ALTER TABLE [TestEvent].[TestScoreExtensions]  WITH CHECK ADD  CONSTRAINT [fk_TestScoreExtensions_TestScores] FOREIGN KEY([AdministrationID], [TestEventID], [Test], [Score], [RescoreFlag])
REFERENCES [TestEvent].[TestScores] ([AdministrationID], [TestEventID], [Test], [Score], [RescoreFlag])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestEvent].[TestScoreExtensions] CHECK CONSTRAINT [fk_TestScoreExtensions_TestScores]
GO
