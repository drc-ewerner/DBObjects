USE [Alaska_udb_dev]
GO
/****** Object:  Table [Teacher].[StudentGroups]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Teacher].[StudentGroups](
	[AdministrationID] [int] NOT NULL,
	[TeacherID] [int] NOT NULL,
	[GroupID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_StudentGroups] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TeacherID] ASC,
	[GroupID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Teacher].[StudentGroups] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Teacher].[StudentGroups] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
ALTER TABLE [Teacher].[StudentGroups]  WITH CHECK ADD  CONSTRAINT [fk_StudentGroups_Core_StudentGroup] FOREIGN KEY([AdministrationID], [GroupID])
REFERENCES [Core].[StudentGroup] ([AdministrationID], [GroupID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Teacher].[StudentGroups] CHECK CONSTRAINT [fk_StudentGroups_Core_StudentGroup]
GO
ALTER TABLE [Teacher].[StudentGroups]  WITH CHECK ADD  CONSTRAINT [fk_StudentGroups_Core_Teacher] FOREIGN KEY([AdministrationID], [TeacherID])
REFERENCES [Core].[Teacher] ([AdministrationID], [TeacherID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Teacher].[StudentGroups] CHECK CONSTRAINT [fk_StudentGroups_Core_Teacher]
GO
