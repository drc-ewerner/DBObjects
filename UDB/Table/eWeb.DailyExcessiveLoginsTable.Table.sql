USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[DailyExcessiveLoginsTable]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[DailyExcessiveLoginsTable](
	[AdministrationID] [int] NOT NULL,
	[DistrictCode] [varchar](15) NOT NULL,
	[SchoolCode] [varchar](15) NOT NULL,
	[StudentID] [int] NOT NULL,
	[LoggedinDate] [varchar](30) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[TestSessionID] [int] NOT NULL,
	[DistrictName] [varchar](50) NULL,
	[SchoolName] [varchar](50) NULL,
	[Grade] [varchar](2) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[StateStudentID] [varchar](30) NULL,
	[DistrictStudentID] [varchar](30) NULL,
	[ContentArea] [varchar](50) NULL,
	[DayLogins] [int] NULL,
	[TotalLogins] [int] NULL,
	[AllTotalLogins] [int] NULL,
 CONSTRAINT [pk_DailyExcessiveLoginsTable] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DistrictCode] ASC,
	[SchoolCode] ASC,
	[StudentID] ASC,
	[LoggedinDate] ASC,
	[Form] ASC,
	[TestSessionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
