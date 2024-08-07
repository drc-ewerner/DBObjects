USE [Alaska_udb_dev]
GO
/****** Object:  Table [Core].[Student]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Core].[Student](
	[AdministrationID] [int] NOT NULL,
	[StudentID] [int] NOT NULL,
	[LastName] [nvarchar](100) NULL,
	[FirstName] [nvarchar](100) NULL,
	[MiddleName] [nvarchar](100) NULL,
	[NameSuffix] [nvarchar](10) NULL,
	[BirthDate] [datetime] NULL,
	[Gender] [varchar](1) NULL,
	[Grade] [varchar](2) NULL,
	[StateStudentID] [varchar](30) NULL,
	[DistrictStudentID] [varchar](30) NULL,
	[SchoolStudentID] [varchar](30) NULL,
	[DistrictCode] [varchar](15) NULL,
	[SchoolCode] [varchar](15) NULL,
	[VendorStudentID] [varchar](50) NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[ParticipantID] [varchar](100) NULL,
	[ImportDate] [datetime] NULL,
	[WithdrawDate] [datetime] NULL,
 CONSTRAINT [pk_Student] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[StudentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Core].[Student] ADD  DEFAULT (NEXT VALUE FOR [Core].[Student_SeqEven]) FOR [StudentID]
GO
ALTER TABLE [Core].[Student] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Core].[Student] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
