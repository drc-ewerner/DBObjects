USE [Alaska_udb_dev]
GO
/****** Object:  Table [Document].[Images]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Document].[Images](
	[AdministrationID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[ImageType] [varchar](20) NOT NULL,
	[ImageID] [varchar](200) NOT NULL,
	[ImageFilePath] [varchar](1000) NOT NULL,
	[OverlayFilePath] [varchar](1000) NULL,
	[TransferAction] [varchar](20) NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC,
	[ImageType] ASC,
	[ImageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Document].[Images] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Document].[Images] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
ALTER TABLE [Document].[Images]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [DocumentID])
REFERENCES [Core].[Document] ([AdministrationID], [DocumentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
