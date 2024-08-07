USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[TeacherStudentList]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[TeacherStudentList](
	[ListId] [int] IDENTITY(1,1) NOT NULL,
	[TeacherId] [uniqueidentifier] NOT NULL,
	[TimeWindowId] [int] NOT NULL,
	[DisctrictCode] [varchar](15) NOT NULL,
	[SchoolCode] [varchar](15) NOT NULL,
	[Descr] [varchar](300) NOT NULL,
	[IsSubmittedTRS] [bit] NOT NULL,
 CONSTRAINT [pk_TeacherStudentList] PRIMARY KEY CLUSTERED 
(
	[ListId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[TeacherStudentList]  WITH CHECK ADD  CONSTRAINT [fk_TeacherStudentList_Teacher] FOREIGN KEY([TeacherId])
REFERENCES [eWeb].[Teacher] ([TeacherId])
GO
ALTER TABLE [eWeb].[TeacherStudentList] CHECK CONSTRAINT [fk_TeacherStudentList_Teacher]
GO
ALTER TABLE [eWeb].[TeacherStudentList]  WITH CHECK ADD  CONSTRAINT [fk_TeacherStudentList_TimeWindow] FOREIGN KEY([TimeWindowId])
REFERENCES [eWeb].[TimeWindow] ([TimeWindowId])
GO
ALTER TABLE [eWeb].[TeacherStudentList] CHECK CONSTRAINT [fk_TeacherStudentList_TimeWindow]
GO
