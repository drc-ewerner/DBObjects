USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[OnlineTestResponses]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[OnlineTestResponses](
	[AdministrationID] [int] NOT NULL,
	[OnlineTestID] [int] NOT NULL,
	[ItemID] [varchar](50) NOT NULL,
	[Position] [int] NULL,
	[Response] [varchar](10) NULL,
	[ExtendedResponse] [nvarchar](max) NULL,
	[ItemVersion] [datetime] NULL,
	[ResponseGuid] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_OnlineTestResponses] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[OnlineTestID] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_OnlineTestResponses] UNIQUE NONCLUSTERED 
(
	[ResponseGuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Insight].[OnlineTestResponses] ADD  DEFAULT (newid()) FOR [ResponseGuid]
GO
ALTER TABLE [Insight].[OnlineTestResponses]  WITH CHECK ADD  CONSTRAINT [fk_OnlineTestResponses_OnlineTests] FOREIGN KEY([AdministrationID], [OnlineTestID])
REFERENCES [Insight].[OnlineTests] ([AdministrationID], [OnlineTestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Insight].[OnlineTestResponses] CHECK CONSTRAINT [fk_OnlineTestResponses_OnlineTests]
GO
