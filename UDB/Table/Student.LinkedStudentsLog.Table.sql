USE [Alaska_udb_dev]
GO
/****** Object:  Table [Student].[LinkedStudentsLog]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Student].[LinkedStudentsLog](
	[AdministrationID] [int] NOT NULL,
	[StudentID] [int] NOT NULL,
	[LinkType] [varchar](50) NOT NULL,
	[LinkAdministrationID] [int] NOT NULL,
	[LinkStudentID] [int] NOT NULL,
	[LinkDate] [datetime] NOT NULL,
	[LinkAction] [varchar](20) NOT NULL,
	[LinkSource] [varchar](20) NOT NULL,
	[UserEmail] [varchar](256) NOT NULL,
	[UserID] [uniqueidentifier] NOT NULL,
	[UserNotes] [varchar](max) NULL,
 CONSTRAINT [pk_LinkedStudentsLog] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[StudentID] ASC,
	[LinkType] ASC,
	[LinkAdministrationID] ASC,
	[LinkStudentID] ASC,
	[LinkDate] ASC,
	[LinkAction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Student].[LinkedStudentsLog] ADD  DEFAULT (getdate()) FOR [LinkDate]
GO
