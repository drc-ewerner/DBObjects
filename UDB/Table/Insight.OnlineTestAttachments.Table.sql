USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[OnlineTestAttachments]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[OnlineTestAttachments](
	[AdministrationID] [int] NOT NULL,
	[OnlineTestID] [int] NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[AttachmentID] [int] NOT NULL,
	[AttachmentInputID] [varchar](100) NULL,
	[FilePath] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[OnlineTestID] ASC,
	[ItemID] ASC,
	[AttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Insight].[OnlineTestAttachments]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [OnlineTestID])
REFERENCES [Insight].[OnlineTests] ([AdministrationID], [OnlineTestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
