USE [Alaska_udb_dev]
GO
/****** Object:  Table [Student].[InsightUsername]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Student].[InsightUsername](
	[AdministrationID] [int] NOT NULL,
	[StudentID] [int] NOT NULL,
	[UsernameStem] [varchar](14) NOT NULL,
	[UsernameNumber] [int] NOT NULL,
	[Username]  AS ([UsernameStem]+CONVERT([varchar](6),[UsernameNumber],(0))) PERSISTED,
	[CreateDate] [datetime] NOT NULL,
	[Password] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[StudentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[AdministrationID] ASC,
	[UsernameStem] ASC,
	[UsernameNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Student].[InsightUsername] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Student].[InsightUsername]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [StudentID])
REFERENCES [Core].[Student] ([AdministrationID], [StudentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
