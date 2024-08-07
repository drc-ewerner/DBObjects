USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[OnlineTestAttachments]    Script Date: 7/2/2024 9:12:03 AM ******/
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
 CONSTRAINT [pk_OnlineTestAttachments] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[OnlineTestID] ASC,
	[ItemID] ASC,
	[AttachmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Insight].[OnlineTestAttachments]  WITH CHECK ADD  CONSTRAINT [fk_OnlineTestAttachments_OnlineTests] FOREIGN KEY([AdministrationID], [OnlineTestID])
REFERENCES [Insight].[OnlineTests] ([AdministrationID], [OnlineTestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Insight].[OnlineTestAttachments] CHECK CONSTRAINT [fk_OnlineTestAttachments_OnlineTests]
GO
