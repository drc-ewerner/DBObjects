USE [Alaska_udb_dev]
GO
/****** Object:  Table [Student].[Courses]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Student].[Courses](
	[AdministrationID] [int] NOT NULL,
	[StudentID] [int] NOT NULL,
	[CourseKey] [varchar](250) NOT NULL,
	[AcademicSession] [varchar](20) NULL,
	[EnrollmentID] [varchar](50) NULL,
	[DistrictCode] [varchar](15) NULL,
	[SchoolCode] [varchar](15) NULL,
	[EnrollmentStatus] [varchar](20) NULL,
	[ClassID] [varchar](50) NULL,
	[ClassTitle] [varchar](100) NULL,
	[ClassType] [varchar](20) NULL,
	[CourseTitle] [varchar](100) NULL,
	[CourseCode] [varchar](50) NULL,
	[ContentArea] [varchar](100) NULL,
	[TeacherLastName] [nvarchar](100) NULL,
	[TeacherFirstName] [nvarchar](100) NULL,
	[TeacherEmail] [varchar](255) NULL,
	[TermStartDate] [date] NULL,
	[TermEndDate] [date] NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_Courses] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[StudentID] ASC,
	[CourseKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Student].[Courses] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Student].[Courses] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
ALTER TABLE [Student].[Courses]  WITH CHECK ADD  CONSTRAINT [fk_Courses_Core_Student] FOREIGN KEY([AdministrationID], [StudentID])
REFERENCES [Core].[Student] ([AdministrationID], [StudentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Student].[Courses] CHECK CONSTRAINT [fk_Courses_Core_Student]
GO
