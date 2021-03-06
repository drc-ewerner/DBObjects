USE [Alaska_udb_dev]
GO
/****** Object:  Table [Teacher].[StudentGroups]    Script Date: 1/12/2022 1:28:44 PM ******/
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
PRIMARY KEY CLUSTERED 
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
ALTER TABLE [Teacher].[StudentGroups]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [GroupID])
REFERENCES [Core].[StudentGroup] ([AdministrationID], [GroupID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Teacher].[StudentGroups]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [TeacherID])
REFERENCES [Core].[Teacher] ([AdministrationID], [TeacherID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
