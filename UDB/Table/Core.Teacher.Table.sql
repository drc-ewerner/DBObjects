USE [Alaska_udb_dev]
GO
/****** Object:  Table [Core].[Teacher]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Core].[Teacher](
	[AdministrationID] [int] NOT NULL,
	[TeacherID] [int] NOT NULL,
	[StateTeacherID] [varchar](256) NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[MiddleName] [nvarchar](100) NULL,
	[Email] [varchar](256) NULL,
	[Status] [varchar](20) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TeacherID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Core].[Teacher] ADD  DEFAULT (NEXT VALUE FOR [Core].[Teacher_SeqEven]) FOR [TeacherID]
GO
ALTER TABLE [Core].[Teacher] ADD  DEFAULT ('Active') FOR [Status]
GO
ALTER TABLE [Core].[Teacher] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Core].[Teacher] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
