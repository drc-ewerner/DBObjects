USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestSession].[Links]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TestSession].[Links](
	[AdministrationID] [int] NOT NULL,
	[TestSessionID] [int] NOT NULL,
	[StudentID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
 CONSTRAINT [pk_Links] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TestSessionID] ASC,
	[StudentID] ASC,
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_Links] UNIQUE NONCLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [TestSession].[Links]  WITH CHECK ADD  CONSTRAINT [fk_Links_Core_Document] FOREIGN KEY([AdministrationID], [StudentID], [DocumentID])
REFERENCES [Core].[Document] ([AdministrationID], [StudentID], [DocumentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestSession].[Links] CHECK CONSTRAINT [fk_Links_Core_Document]
GO
ALTER TABLE [TestSession].[Links]  WITH CHECK ADD  CONSTRAINT [fk_Links_Core_TestSession] FOREIGN KEY([AdministrationID], [TestSessionID])
REFERENCES [Core].[TestSession] ([AdministrationID], [TestSessionID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [TestSession].[Links] CHECK CONSTRAINT [fk_Links_Core_TestSession]
GO
