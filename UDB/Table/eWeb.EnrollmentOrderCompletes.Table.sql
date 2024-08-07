USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[EnrollmentOrderCompletes]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[EnrollmentOrderCompletes](
	[AdminID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[CompleteID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](30) NULL,
	[LastName] [varchar](30) NULL,
	[EmailAddress] [varchar](256) NULL,
	[LastUpdateDate] [datetime] NULL,
 CONSTRAINT [pk_EnrollmentOrderCompletes] PRIMARY KEY CLUSTERED 
(
	[AdminID] ASC,
	[OrderID] ASC,
	[CompleteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
