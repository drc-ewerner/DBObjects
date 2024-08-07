USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[UnprocessedOnlineTestResponses]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[UnprocessedOnlineTestResponses](
	[AdministrationID] [int] NOT NULL,
	[UnprocessedOnlineTestID] [int] NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[Position] [int] NULL,
	[Response] [varchar](10) NULL,
	[ExtendedResponse] [nvarchar](max) NULL,
 CONSTRAINT [pk_UnprocessedOnlineTestResponses] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[UnprocessedOnlineTestID] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Insight].[UnprocessedOnlineTestResponses]  WITH CHECK ADD  CONSTRAINT [fk_UnprocessedOnlineTestResponses_UnprocessedOnlineTests] FOREIGN KEY([AdministrationID], [UnprocessedOnlineTestID])
REFERENCES [Insight].[UnprocessedOnlineTests] ([AdministrationID], [UnprocessedOnlineTestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Insight].[UnprocessedOnlineTestResponses] CHECK CONSTRAINT [fk_UnprocessedOnlineTestResponses_UnprocessedOnlineTests]
GO
