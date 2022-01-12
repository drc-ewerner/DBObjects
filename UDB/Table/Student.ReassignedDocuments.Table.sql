USE [Alaska_udb_dev]
GO
/****** Object:  Table [Student].[ReassignedDocuments]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Student].[ReassignedDocuments](
	[AdministrationID] [int] NOT NULL,
	[StudentID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[Action] [varchar](100) NOT NULL,
	[UserEmail] [varchar](256) NULL,
	[UserID] [uniqueidentifier] NULL,
	[UserNotes] [varchar](max) NULL,
	[ReassignDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[StudentID] ASC,
	[DocumentID] ASC,
	[Action] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Student].[ReassignedDocuments] ADD  DEFAULT (getdate()) FOR [ReassignDate]
GO
ALTER TABLE [Student].[ReassignedDocuments]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [StudentID])
REFERENCES [Core].[Student] ([AdministrationID], [StudentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
