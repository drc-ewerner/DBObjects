USE [Alaska_udb_dev]
GO
/****** Object:  Table [Core].[TestEvent]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Core].[TestEvent](
	[AdministrationID] [int] NOT NULL,
	[TestEventID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[FormVersion] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestEventID] ASC,
	[Test] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[AdministrationID] ASC,
	[TestEventID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Core].[TestEvent] ADD  DEFAULT (NEXT VALUE FOR [Core].[TestEvent_SeqEven]) FOR [TestEventID]
GO
ALTER TABLE [Core].[TestEvent] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Core].[TestEvent] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
ALTER TABLE [Core].[TestEvent]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [DocumentID])
REFERENCES [Core].[Document] ([AdministrationID], [DocumentID])
ON DELETE CASCADE
GO
ALTER TABLE [Core].[TestEvent]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [Level], [Form])
REFERENCES [Scoring].[TestForms] ([AdministrationID], [Test], [Level], [Form])
GO
