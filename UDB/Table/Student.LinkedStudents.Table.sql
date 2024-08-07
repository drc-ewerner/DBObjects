USE [Alaska_udb_dev]
GO
/****** Object:  Table [Student].[LinkedStudents]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Student].[LinkedStudents](
	[AdministrationID] [int] NOT NULL,
	[StudentID] [int] NOT NULL,
	[LinkType] [varchar](50) NOT NULL,
	[LinkAdministrationID] [int] NOT NULL,
	[LinkStudentID] [int] NOT NULL,
	[LinkDate] [datetime] NOT NULL,
 CONSTRAINT [pk_LinkedStudents] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[StudentID] ASC,
	[LinkType] ASC,
	[LinkAdministrationID] ASC,
	[LinkStudentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Student].[LinkedStudents] ADD  DEFAULT (getdate()) FOR [LinkDate]
GO
ALTER TABLE [Student].[LinkedStudents]  WITH CHECK ADD  CONSTRAINT [fk_LinkedStudents_Core_Student] FOREIGN KEY([AdministrationID], [StudentID])
REFERENCES [Core].[Student] ([AdministrationID], [StudentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Student].[LinkedStudents] CHECK CONSTRAINT [fk_LinkedStudents_Core_Student]
GO
ALTER TABLE [Student].[LinkedStudents]  WITH CHECK ADD  CONSTRAINT [fk_LinkedStudents_Core_Student_2] FOREIGN KEY([LinkAdministrationID], [LinkStudentID])
REFERENCES [Core].[Student] ([AdministrationID], [StudentID])
GO
ALTER TABLE [Student].[LinkedStudents] CHECK CONSTRAINT [fk_LinkedStudents_Core_Student_2]
GO
