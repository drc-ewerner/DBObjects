USE [Alaska_udb_dev]
GO
/****** Object:  Table [Core].[Document]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Core].[Document](
	[AdministrationID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[StudentID] [int] NOT NULL,
	[DocumentLabelCode] [varchar](50) NULL,
	[BatchNumber] [varchar](30) NULL,
	[SerialNumber] [varchar](6) NULL,
	[SecurityCode] [varchar](15) NULL,
	[DocumentSprayValue] [varchar](30) NULL,
	[Lithocode] [varchar](15) NULL,
	[OriginDate] [varchar](50) NULL,
	[Priority] [varchar](10) NULL,
	[DocumentCode] [varchar](20) NULL,
	[LinkBasis] [varchar](100) NULL,
	[LinkInfo] [varchar](200) NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_Document] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_Document] UNIQUE NONCLUSTERED 
(
	[AdministrationID] ASC,
	[StudentID] ASC,
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Core].[Document] ADD  DEFAULT (NEXT VALUE FOR [Core].[Document_SeqEven]) FOR [DocumentID]
GO
ALTER TABLE [Core].[Document] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Core].[Document] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
ALTER TABLE [Core].[Document]  WITH CHECK ADD  CONSTRAINT [fk_Document_Student] FOREIGN KEY([AdministrationID], [StudentID])
REFERENCES [Core].[Student] ([AdministrationID], [StudentID])
ON DELETE CASCADE
GO
ALTER TABLE [Core].[Document] CHECK CONSTRAINT [fk_Document_Student]
GO
