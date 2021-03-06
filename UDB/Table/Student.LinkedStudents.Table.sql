USE [Alaska_udb_dev]
GO
/****** Object:  Table [Student].[LinkedStudents]    Script Date: 1/12/2022 1:28:44 PM ******/
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
PRIMARY KEY CLUSTERED 
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
ALTER TABLE [Student].[LinkedStudents]  WITH CHECK ADD FOREIGN KEY([LinkAdministrationID], [LinkStudentID])
REFERENCES [Core].[Student] ([AdministrationID], [StudentID])
GO
ALTER TABLE [Student].[LinkedStudents]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [StudentID])
REFERENCES [Core].[Student] ([AdministrationID], [StudentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
