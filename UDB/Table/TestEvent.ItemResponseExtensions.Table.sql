USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestEvent].[ItemResponseExtensions]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TestEvent].[ItemResponseExtensions](
	[AdministrationID] [int] NOT NULL,
	[TestEventID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[RescoreFlag] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](1000) NOT NULL,
 CONSTRAINT [pk_ItemResponseExtensions] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestEventID] ASC,
	[Test] ASC,
	[ItemID] ASC,
	[RescoreFlag] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [TestEvent].[ItemResponseExtensions] ADD  DEFAULT ((0)) FOR [RescoreFlag]
GO
ALTER TABLE [TestEvent].[ItemResponseExtensions]  WITH CHECK ADD  CONSTRAINT [fk_ItemResponseExtensions_Core_TestEvent] FOREIGN KEY([AdministrationID], [TestEventID], [Test])
REFERENCES [Core].[TestEvent] ([AdministrationID], [TestEventID], [Test])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestEvent].[ItemResponseExtensions] CHECK CONSTRAINT [fk_ItemResponseExtensions_Core_TestEvent]
GO
ALTER TABLE [TestEvent].[ItemResponseExtensions]  WITH CHECK ADD  CONSTRAINT [fk_ItemResponseExtensions_Scoring_Items] FOREIGN KEY([AdministrationID], [Test], [ItemID])
REFERENCES [Scoring].[Items] ([AdministrationID], [Test], [ItemID])
GO
ALTER TABLE [TestEvent].[ItemResponseExtensions] CHECK CONSTRAINT [fk_ItemResponseExtensions_Scoring_Items]
GO
