USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[EnrollmentOrder]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[EnrollmentOrder](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[AdminID] [int] NOT NULL,
	[StatusID] [int] NULL,
	[DistrictCode] [char](15) NULL,
	[SchoolCode] [char](15) NULL,
	[LastUpdateDate] [datetime] NULL,
	[AppletCode] [varchar](10) NOT NULL,
	[ExportDate] [datetime] NULL,
	[FirstName] [varchar](30) NULL,
	[LastName] [varchar](30) NULL,
	[EmailAddress] [varchar](256) NULL,
 CONSTRAINT [pk_EnrollmentOrder] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[EnrollmentOrder] ADD  CONSTRAINT [DF_EnrollmentOrder_LastUpdateDate]  DEFAULT (getdate()) FOR [LastUpdateDate]
GO
ALTER TABLE [eWeb].[EnrollmentOrder] ADD  DEFAULT ('EVS') FOR [AppletCode]
GO
ALTER TABLE [eWeb].[EnrollmentOrder]  WITH CHECK ADD  CONSTRAINT [fk_EnrollmentOrder_EnrollmentStatus] FOREIGN KEY([StatusID])
REFERENCES [eWeb].[EnrollmentStatus] ([StatusID])
GO
ALTER TABLE [eWeb].[EnrollmentOrder] CHECK CONSTRAINT [fk_EnrollmentOrder_EnrollmentStatus]
GO
