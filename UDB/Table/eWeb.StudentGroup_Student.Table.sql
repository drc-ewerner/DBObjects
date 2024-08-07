USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[StudentGroup_Student]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[StudentGroup_Student](
	[StudentGroupStudentID] [int] IDENTITY(1,1) NOT NULL,
	[AdministrationID] [int] NOT NULL,
	[StudentGroupID] [int] NOT NULL,
	[StudentID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_StudentGroup_Student] PRIMARY KEY CLUSTERED 
(
	[StudentGroupStudentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[StudentGroup_Student]  WITH CHECK ADD  CONSTRAINT [fk_StudentGroup_Student_StudentGroup] FOREIGN KEY([StudentGroupID])
REFERENCES [eWeb].[StudentGroup] ([StudentGroupID])
GO
ALTER TABLE [eWeb].[StudentGroup_Student] CHECK CONSTRAINT [fk_StudentGroup_Student_StudentGroup]
GO
