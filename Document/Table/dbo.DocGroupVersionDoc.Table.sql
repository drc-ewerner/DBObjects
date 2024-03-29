USE [Alaska_documents_dev]
GO
/****** Object:  Table [dbo].[DocGroupVersionDoc]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocGroupVersionDoc](
	[DocGroupVerID] [bigint] NOT NULL,
	[DocID] [uniqueidentifier] NOT NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_DocGroupVersionDoc] PRIMARY KEY CLUSTERED 
(
	[DocID] ASC,
	[DocGroupVerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DocGroupVersionDoc] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[DocGroupVersionDoc]  WITH CHECK ADD  CONSTRAINT [FK_DocGroupVersionDoc_Doc] FOREIGN KEY([DocID])
REFERENCES [dbo].[Doc] ([DocID])
GO
ALTER TABLE [dbo].[DocGroupVersionDoc] CHECK CONSTRAINT [FK_DocGroupVersionDoc_Doc]
GO
ALTER TABLE [dbo].[DocGroupVersionDoc]  WITH CHECK ADD  CONSTRAINT [FK_DocGroupVersionDoc_DocGroupVersion] FOREIGN KEY([DocGroupVerID])
REFERENCES [dbo].[DocGroupVersion] ([DocGroupVerID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DocGroupVersionDoc] CHECK CONSTRAINT [FK_DocGroupVersionDoc_DocGroupVersion]
GO
