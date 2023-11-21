USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetTicketsBySessionWithAccommsForUnsupportedForms]    Script Date: 11/21/2023 8:56:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [eWeb].[GetTicketsBySessionWithAccommsForUnsupportedForms] 
       @AdministrationID INT,
       @TestSessionID INT,
       @LastName VARCHAR (100) = null,
       @Status VARCHAR (100) = null
AS

DECLARE @showAccommByAssignedForm bit
SET @showAccommByAssignedForm = 0
select @showAccommByAssignedForm=case when eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','TestTickets.ShowAccommByAssignedForm','N')='Y' then 1 else 0 end

-- get the list of accomms that are to be shown for the unsupported forms (as exceptions)
DECLARE @CSVInput VARCHAR(MAX)
DECLARE @ret TABLE(Accomm VARCHAR(300))

SELECT @CSVInput = eWeb.GetConfigExtensionValue(@AdministrationID,'eWeb','TestTickets.ListOfExceptedAccommsForUnsupportedForms','')	
    
IF LTRIM(RTRIM(@CSVInput)) != '''' 
BEGIN
    DECLARE @start BIGINT
    DECLARE @laststart BIGINT
    SET @laststart=0
    SET @start=CHARINDEX(',', @CSVInput, 0)

    IF @start=0
    INSERT INTO @ret VALUES(LTRIM(SUBSTRING(@CSVInput, 0, LEN(@CSVInput)+1)))

    WHILE(@start > 0)
    BEGIN
        INSERT INTO @ret VALUES(LTRIM(SUBSTRING(@CSVInput, @laststart, @start - @laststart)))
        SET @laststart=@start+1
        SET @start=CHARINDEX(',', @CSVInput, @start+1)
        IF(@start=0)
            INSERT INTO @ret VALUES(LTRIM(SUBSTRING(@CSVInput, @laststart, LEN(@CSVInput)+1)))
    END
END

SELECT DISTINCT
       [t].[AdministrationID],
       [t].[DocumentID],
       [t].[Test],
       [t].[Level],
       [t].[Form],
       [t].[UserName],
       [t].[Password],
       [t].[Spiraled],
       [t].[NotTestedCode],
       [t].[Status],
       [s].[StudentID],
       'SchoolStudentID' = [s].[DistrictStudentID],
       [s].[StateStudentID],
       [s].[DistrictStudentID],
       [s].[FirstName],
       [s].[LastName],
       [s].[MiddleName],
       [s].[BirthDate],
       [s].[Grade],
       [stf].[FormName],
       [stf].[VisualIndicator],
       'StartTime' = [t].[StartTime],
       'EndTime' = [t].[EndTime],
       'UnlockTime' = [t].[UnlockTime],
       [ts].[TestSessionID],
       'Accommodations' = COALESCE(LEFT([Accommodations], LEN([Accommodations]) - 1), ''),
       'PartName' = CASE WHEN t.PartName IS NULL 
                            THEN '' 
                        WHEN ISNULL(stf.FormSessionName,'') = '' 
                            THEN 'Module ' + t.PartName 
                        ELSE stf.FormSessionName 
                    END,
       'NoAssessedCode' = CAST([na].[Value] AS INT),
       'NonPublicEnrolled' = ISNULL([np].[Value], CAST([np].[Value] AS BIT)),
       [Answered],
       [Total],
       [AbbrevAccommodations] = COALESCE(LEFT([AbbrevAccommodations], LEN([AbbrevAccommodations]) - 1), ''),
       [SXV].DisplayValue,
       [ts].[ClassCode],
       [TCH].[TeacherID],
       [TCH].FirstName as TeacherFirstName,
       [TCH].LastName as TeacherLastName,
       [stf].FormSessionName
FROM [Core].[TestSession] [ts]
INNER JOIN [TestSession].[Links][k] ON
      [k].[AdministrationID] = [ts].[AdministrationID] AND
      [k].[TestSessionID] = [ts].[TestSessionID]
INNER JOIN [Document].[TestTicketView] [t] ON
      [t].[AdministrationID] = [k].[AdministrationID] AND
      [t].[DocumentID] = [k].[DocumentID]
INNER JOIN [Scoring].[Tests] [st] ON
      [st].[AdministrationID] = [t].[AdministrationID] AND
      [st].[Test] = [t].[Test]
LEFT JOIN [Scoring].[TestForms] [stf] ON
      [t].[AdministrationID] = [stf].[AdministrationID] AND
      [t].[Test] = [stf].[Test] AND
      [t].[Level] = [stf].[Level] AND
      [t].[Form] = [stf].[Form]
LEFT JOIN [Scoring].[TestFormParts] [fp] ON
      [t].[AdministrationId] = [fp].[AdministrationId] AND
      [t].[Test] = [fp].[Test] AND
      [t].[Level] = [fp].[Level] AND
      [t].[Form] = [fp].[FormPart] AND
      [t].[PartName] = [fp].[PartName]
INNER JOIN [Core].[Student] [s] ON
      [s].[AdministrationID] = [ts].[AdministrationID] AND
      [s].[StudentID] = [k].[StudentID]
LEFT JOIN [Document].[Extensions] [na] ON
      [na].[AdministrationID] = [t].[AdministrationID] AND
      [na].[DocumentID] = [t].[DocumentID] AND
      [na].[Name] = 'NonAssessedCd'
LEFT JOIN [Document].[Extensions] [np] ON
      [np].[AdministrationID] = [t].[AdministrationID] AND
      [np].[DocumentID] = [t].[DocumentID] and
      [np].[Name] = 'NonPublicEnrolled'
LEFT JOIN [Student].[Extensions] [SX1] ON
      [s].[AdministrationID] = [SX1].[AdministrationID] AND
      [s].[StudentID] = [SX1].[StudentID] AND
      [SX1].Name = 'Test_Type' AND
      [SX1].Category = 'Demographic'
LEFT JOIN [XRef].[StudentExtensionValues] [SXV] ON
      [s].[AdministrationID] = [SXV].[AdministrationID] AND
      [SX1].Value  = [SXV].Value  AND
      [SXV].Name = 'Test_Type' AND
      [SXV].Category = 'Demographic'
LEFT JOIN [Core].[Teacher] [TCH] ON
      [s].[AdministrationID] = [TCH].[AdministrationID] AND
      [ts].TeacherID = [TCH].TeacherID 

OUTER APPLY (
       SELECT
              [sx].[DisplayName] + ', '
       FROM
              [xref].[studentextensionnames] [sx]
              INNER JOIN [Student].[Extensions] [x] ON
                     [sx].[category] = [x].[category] AND
                     [sx].[name] = [x].[name] AND
                     [sx].[AdministrationID] = [x].[AdministrationID]
              INNER JOIN [config].[extensions] [cx] ON
                     [cx].[Category] = 'Accommodation.Online' AND
                     [cx].[AdministrationID] = [x].[AdministrationID] AND
                     [cx].[Name] = [x].[Category] + '.' + [x].[name]
              WHERE
                     [x].[AdministrationID] = [t].[AdministrationID] AND
                     [x].[StudentID] = [k].[StudentID] AND
                     [x].[Category] = [st].[ContentArea] AND
                     [x].[Value] = 'Y'
                     and (
                            (@showAccommByAssignedForm = 1 
                                and (
                                    not exists(select * from Scoring.TestAccommodationForms a 
                                                where a.AdministrationID=sx.AdministrationID 
                                                    and a.Test=ts.Test 
                                                    and a.Level=ts.Level 
                                                    and a.AccommodationName=sx.Name 
                                                    and left(a.Form,6)!=left(t.Form,6)
                                                    and not [sx].[Name] in (select Accomm from @ret)
                                            )
                                )
                            ) 
                            OR @showAccommByAssignedForm = 0
                        )
              GROUP BY [sx].[DisplayName]
              ORDER BY [sx].[DisplayName]
       FOR XML PATH('')) [sx](Accommodations)

OUTER APPLY (
       SELECT
              'Answered' = COUNT(DISTINCT
                     CASE
                           WHEN ([ExtendedResponse] IS NULL) AND (ISNULL([Response], '') NOT IN ('', '-')) THEN [isor].[ItemID]
                           WHEN ([Response] IS NULL) AND ([ExtendedResponse] LIKE '%answered="y"%') THEN [isor].[ItemID]
                           ELSE NULL
                     END)
       FROM
              [Insight].[OnlineTests] [iso]
              LEFT JOIN [Insight].[OnlineTestResponses] [isor] ON
                     [iso].[AdministrationID] = [isor].[AdministrationID] AND
                     [iso].[OnlineTestID] = [isor].[OnlineTestID]
       WHERE
              [iso].[AdministrationID] = [ts].[AdministrationID] AND
              [iso].[DocumentID] = [k].[DocumentID]
) [xte]

OUTER APPLY (
       SELECT
              'Total' = COUNT(DISTINCT [fi].[ItemID])
       FROM
              [Document].[TestTicket] [xte]
              INNER JOIN [Scoring].[TestFormItems] [fi]
              ON [fi].[AdministrationID] = [xte].[AdministrationID] AND
                     [fi].[Test] = [xte].[Test] AND
                     [fi].[Level] = [xte].[Level] AND
                     [fi].[Form] = [t].[Form]
       WHERE
              [xte].[AdministrationID] = [ts].[AdministrationID] AND
              [xte].[DocumentID] = [k].[DocumentID]
) [xte2]

OUTER APPLY (
       SELECT
              [sx2].[DisplayAbbreviation] + ', '
       FROM
              [xref].[studentextensionnames] [sx2]
              INNER JOIN Student.Extensions x ON
                     [sx2].[category] = [x].[category] AND
                     [sx2].[name] = [x].[name] AND
                     [sx2].[AdministrationID] = [x].[AdministrationID]
              INNER JOIN [config].[extensions] cx ON
                     [cx].[Category] = 'Accommodation.Online' AND
                     [cx].[AdministrationID] = [x].[AdministrationID] AND
                     [cx].[Name] = [x].[Category] + '.' + [x].[name]
              WHERE
                     [x].[AdministrationID] = t.AdministrationID AND
                     [x].[StudentID] = [k].[StudentID] AND
                     [x].[Category] = [st].[ContentArea] AND
                     [x].[Value] = 'Y'
                     and (
                            (@showAccommByAssignedForm = 1 
                                and (
                                    not exists(select * from Scoring.TestAccommodationForms a 
                                                where a.AdministrationID=sx2.AdministrationID 
                                                    and a.Test=ts.Test 
                                                    and a.Level=ts.Level 
                                                    and a.AccommodationName=sx2.Name 
                                                    and left(a.Form,6)!=left(t.Form,6)
                                                    and not [sx2].[Name] in (select Accomm from @ret)
                                            )
                                )
                            ) 
                            OR @showAccommByAssignedForm = 0
                        )
              GROUP BY
                     [sx2].[DisplayAbbreviation]
              ORDER BY
                     [sx2].[DisplayAbbreviation]
              FOR XML PATH('')
) [sx2](AbbrevAccommodations)

WHERE
       [ts].[AdministrationID] = @AdministrationID AND
       [ts].[TestSessionID] = @TestSessionID  AND
       (ISNULL(@LastName, '') = '' OR [s].[LastName] LIKE @LastName + '%') AND
       COALESCE(t.Status,'')= CASE WHEN  @Status <> '(All)' THEN COALESCE(@status,t.Status,'') ELSE t.status END
ORDER BY
       [Status] DESC,
       [Test],
       [LastName],
       [FirstName]
GO
