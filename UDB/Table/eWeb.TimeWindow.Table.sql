USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[TimeWindow]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[TimeWindow](
	[TimeWindowId] [int] NOT NULL,
	[AdministrationId] [int] NOT NULL,
	[Descr] [varchar](255) NOT NULL,
	[AppletCode] [varchar](10) NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ReadOnlyDate] [datetime] NULL,
	[DisplayName] [varchar](255) NOT NULL,
	[LongDescription] [varchar](500) NULL,
 CONSTRAINT [pk_TimeWindow] PRIMARY KEY CLUSTERED 
(
	[TimeWindowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_TimeWindow] UNIQUE NONCLUSTERED 
(
	[AdministrationId] ASC,
	[AppletCode] ASC,
	[Descr] ASC,
	[DisplayName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[TimeWindow]  WITH CHECK ADD  CONSTRAINT [fk_TimeWindow_Applet] FOREIGN KEY([AppletCode])
REFERENCES [eWeb].[Applet] ([AppletCode])
GO
ALTER TABLE [eWeb].[TimeWindow] CHECK CONSTRAINT [fk_TimeWindow_Applet]
GO
