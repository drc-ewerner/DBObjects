USE [Alaska_documents_dev]
GO
/****** Object:  Table [dbo].[FileType]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FileType](
	[FileTypeExt] [varchar](10) NOT NULL,
	[Descr] [varchar](50) NOT NULL,
	[MimeType] [varchar](100) NOT NULL,
 CONSTRAINT [PK_FileType] PRIMARY KEY CLUSTERED 
(
	[FileTypeExt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
