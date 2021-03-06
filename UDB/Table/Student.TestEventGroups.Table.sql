USE [Alaska_udb_dev]
GO
/****** Object:  Table [Student].[TestEventGroups]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Student].[TestEventGroups](
	[AdministrationID] [int] NOT NULL,
	[StudentID] [int] NOT NULL,
	[GroupName] [varchar](100) NOT NULL,
	[GroupID] [int] NOT NULL,
	[Slot] [varchar](100) NOT NULL,
	[TestEventID] [int] NOT NULL,
	[LogicalTestEventID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[StudentID] ASC,
	[GroupName] ASC,
	[GroupID] ASC,
	[Slot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Student].[TestEventGroups]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [StudentID])
REFERENCES [Core].[Student] ([AdministrationID], [StudentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Student].[TestEventGroups]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [TestEventID])
REFERENCES [Core].[TestEvent] ([AdministrationID], [TestEventID])
GO
