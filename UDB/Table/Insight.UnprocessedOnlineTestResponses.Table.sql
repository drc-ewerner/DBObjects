USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[UnprocessedOnlineTestResponses]    Script Date: 1/12/2022 1:28:44 PM ******/
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
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[UnprocessedOnlineTestID] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Insight].[UnprocessedOnlineTestResponses]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [UnprocessedOnlineTestID])
REFERENCES [Insight].[UnprocessedOnlineTests] ([AdministrationID], [UnprocessedOnlineTestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
