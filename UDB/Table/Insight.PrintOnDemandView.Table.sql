USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[PrintOnDemandView]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[PrintOnDemandView](
	[AdministrationID] [int] NOT NULL,
	[RequestID] [int] NOT NULL,
	[BarcodeContent] [varchar](100) NOT NULL,
	[BarcodeFirstChars] [varchar](50) NOT NULL,
	[BarcodeNumbers] [int] NOT NULL,
	[ViewID] [int] IDENTITY(1,1) NOT NULL,
	[ViewState] [varchar](20) NULL,
	[CreateDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[RequestID] ASC,
	[BarcodeContent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Insight].[PrintOnDemandView] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Insight].[PrintOnDemandView]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [RequestID])
REFERENCES [Insight].[PrintOnDemandRequest] ([AdministrationID], [RequestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
