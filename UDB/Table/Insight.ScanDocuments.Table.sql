USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[ScanDocuments]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[ScanDocuments](
	[AdministrationID] [int] NOT NULL,
	[ScanDocumentID] [int] IDENTITY(1,1) NOT NULL,
	[DocumentID] [int] NOT NULL,
	[ItemErrorCount] [int] NOT NULL,
	[ItemResults] [xml] NULL,
	[ScanData] [xml] NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_ScanDocuments] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[ScanDocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Insight].[ScanDocuments] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
