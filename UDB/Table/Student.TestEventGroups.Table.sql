USE [Alaska_udb_dev]
GO
/****** Object:  Table [Student].[TestEventGroups]    Script Date: 7/2/2024 9:12:04 AM ******/
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
 CONSTRAINT [pk_TestEventGroups] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[StudentID] ASC,
	[GroupName] ASC,
	[GroupID] ASC,
	[Slot] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Student].[TestEventGroups]  WITH CHECK ADD  CONSTRAINT [fk_TestEventGroups_Core_Student] FOREIGN KEY([AdministrationID], [StudentID])
REFERENCES [Core].[Student] ([AdministrationID], [StudentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Student].[TestEventGroups] CHECK CONSTRAINT [fk_TestEventGroups_Core_Student]
GO
ALTER TABLE [Student].[TestEventGroups]  WITH CHECK ADD  CONSTRAINT [fk_TestEventGroups_Core_TestEvent] FOREIGN KEY([AdministrationID], [TestEventID])
REFERENCES [Core].[TestEvent] ([AdministrationID], [TestEventID])
GO
ALTER TABLE [Student].[TestEventGroups] CHECK CONSTRAINT [fk_TestEventGroups_Core_TestEvent]
GO
