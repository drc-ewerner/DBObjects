USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[StudentList]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[StudentList](
	[StudentListId] [int] IDENTITY(1,1) NOT NULL,
	[StudentUID] [varchar](20) NOT NULL,
	[ListId] [int] NOT NULL,
	[FirstName] [varchar](20) NULL,
	[LastName] [varchar](40) NULL,
	[MiddleName] [varchar](20) NULL,
	[Gender] [char](1) NULL,
	[BirthDate] [datetime] NULL,
	[Ethnicity] [varchar](100) NULL,
	[DistrictCode] [varchar](10) NULL,
	[SchoolCode] [varchar](10) NULL,
	[Grade] [varchar](2) NULL,
	[Proficiency1] [smallint] NULL,
	[Proficiency2] [smallint] NULL,
	[Proficiency3] [smallint] NULL,
	[Proficiency4] [smallint] NULL,
	[Proficiency5] [smallint] NULL,
	[PrecodeID] [varchar](20) NULL,
 CONSTRAINT [PK_StudentList] PRIMARY KEY CLUSTERED 
(
	[StudentListId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[StudentList]  WITH CHECK ADD  CONSTRAINT [FK_StudentList_TeacherStudentList] FOREIGN KEY([ListId])
REFERENCES [eWeb].[TeacherStudentList] ([ListId])
GO
ALTER TABLE [eWeb].[StudentList] CHECK CONSTRAINT [FK_StudentList_TeacherStudentList]
GO
