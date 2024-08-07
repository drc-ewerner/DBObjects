USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[StudentTransferRequest]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[StudentTransferRequest](
	[StudentTransferRequestId] [int] IDENTITY(1,1) NOT NULL,
	[AdminID] [int] NOT NULL,
	[FromDistrictCode] [varchar](15) NOT NULL,
	[FromSchoolCode] [varchar](15) NOT NULL,
	[ToDistrictCode] [varchar](15) NOT NULL,
	[ToSchoolCode] [varchar](15) NOT NULL,
	[FromCompletedContentArea1] [bit] NOT NULL,
	[FromCompletedContentArea2] [bit] NOT NULL,
	[FromCompletedContentArea3] [bit] NOT NULL,
	[FromCompletedContentArea4] [bit] NOT NULL,
	[FromTestingMode] [varchar](50) NOT NULL,
	[ToCompletedContentArea1] [bit] NOT NULL,
	[ToCompletedContentArea2] [bit] NOT NULL,
	[ToCompletedContentArea3] [bit] NOT NULL,
	[ToCompletedContentArea4] [bit] NOT NULL,
	[ToTestingMode] [varchar](50) NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[BirthDate] [nvarchar](20) NOT NULL,
	[StateStudentID] [varchar](30) NOT NULL,
	[Grade] [varchar](2) NOT NULL,
	[Status] [varchar](50) NULL,
	[SendersPhoneNumber] [varchar](10) NOT NULL,
	[TimeOfRequest] [datetime] NOT NULL,
	[SendersEmail] [varchar](256) NOT NULL,
	[SendersFullName] [varchar](70) NULL,
	[SendersUserId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_StudentTransferRequest] PRIMARY KEY CLUSTERED 
(
	[StudentTransferRequestId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[StudentTransferRequest] ADD  DEFAULT ('In Progress') FOR [Status]
GO
