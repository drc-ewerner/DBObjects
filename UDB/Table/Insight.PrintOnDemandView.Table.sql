USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[PrintOnDemandView]    Script Date: 7/2/2024 9:12:03 AM ******/
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
 CONSTRAINT [pk_PrintOnDemandView] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[RequestID] ASC,
	[BarcodeContent] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Insight].[PrintOnDemandView] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Insight].[PrintOnDemandView]  WITH CHECK ADD  CONSTRAINT [fk_PrintOnDemandView_PrintOnDemandRequest] FOREIGN KEY([AdministrationID], [RequestID])
REFERENCES [Insight].[PrintOnDemandRequest] ([AdministrationID], [RequestID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Insight].[PrintOnDemandView] CHECK CONSTRAINT [fk_PrintOnDemandView_PrintOnDemandRequest]
GO
