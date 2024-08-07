USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[PrintOnDemandRequest]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[PrintOnDemandRequest](
	[AdministrationID] [int] NOT NULL,
	[RequestID] [int] IDENTITY(1,1) NOT NULL,
	[RequestType] [varchar](50) NOT NULL,
	[Form] [varchar](20) NULL,
	[PassageID] [int] NULL,
	[PassageIndicator] [varchar](100) NULL,
	[ItemID] [varchar](50) NULL,
	[Position] [int] NULL,
	[StudentID] [int] NOT NULL,
	[TestSessionID] [int] NOT NULL,
	[ViewCount] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_PrintOnDemandRequest] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[RequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Insight].[PrintOnDemandRequest] ADD  DEFAULT ((0)) FOR [ViewCount]
GO
ALTER TABLE [Insight].[PrintOnDemandRequest] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
