USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[StudentGroup_Student]    Script Date: 1/12/2022 1:28:44 PM ******/
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
 CONSTRAINT [PK_StudentGroup_Student] PRIMARY KEY CLUSTERED 
(
	[StudentGroupStudentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[StudentGroup_Student]  WITH CHECK ADD  CONSTRAINT [FK_StudentGroup_Student_StudentGroup] FOREIGN KEY([StudentGroupID])
REFERENCES [eWeb].[StudentGroup] ([StudentGroupID])
GO
ALTER TABLE [eWeb].[StudentGroup_Student] CHECK CONSTRAINT [FK_StudentGroup_Student_StudentGroup]
GO
