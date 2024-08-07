USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[AddStudentToStudentGroup]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	CREATE PROCEDURE [eWeb].[AddStudentToStudentGroup]

    @AdministrationID INT,
    @DistrictCode VARCHAR(15),
    @SchoolCode VARCHAR(15),
    @StateTeacherID VARCHAR(50),
    @StateStudentID VARCHAR(20),
    @StudentGroupName VARCHAR(250),
    @StudentGroupType VARCHAR(50),
    @AllowUpdateOnly BIT
WITH RECOMPILE 
AS

DECLARE @Count INT
DECLARE @TeacherID INT
DECLARE @StudentGroupID INT
DECLARE @StudentID INT
DECLARE @ErrorCode INT
DECLARE @GroupCreated BIT

SET @ErrorCode = 0

--*** Error Codes: ***
--0: Success()
--1: Teacher does not exist
--2: Group does not exist
--3: Student does not exist
--4: Duplicate StateTeacherID found
--5: Duplicate StateStudentID found
--6: Group Name is longer than 200 characters
--7: Student already added
--8: Group Required
--9: Group Name Invalid

SET @GroupCreated = 0

IF (LEN(COALESCE(@StudentGroupName,'')) > 200)
       SET @ErrorCode = 6
ELSE IF (LEN(COALESCE(@StudentGroupName,'')) = 0)
       SET @ErrorCode = 8 -- Group Required
ELSE IF @StudentGroupName LIKE '%[^A-Z0-9'' -]%' --[^] syntax = any single character *not* within the specified range ([^a-f]) or set ([^abcdef]).
       SET @ErrorCode = 9 --Group Name Invalid, may only contain alpha (A-Z, a-z), hyphen (-), apostrophe ('), and space
ELSE --GroupName length OK
BEGIN
       SELECT @Count = COUNT(*) 
    FROM [Core].[Teacher]    t
    JOIN [Teacher].[Sites]   ts  ON  t.[AdministrationID] = ts.[AdministrationID]
                                 AND t.[TeacherID]        = ts.[TeacherID]
       WHERE [StateTeacherID]     = @StateTeacherID 
      AND t.[AdministrationID] = @AdministrationID
      AND [DistrictCode]       = @DistrictCode
      AND [SchoolCode]         = @SchoolCode

       IF (@Count) > 1 
              SET @ErrorCode = 4 -- StateTeacherID not unique
       
       IF (@ErrorCode = 0)
       BEGIN
              SELECT @Count = COUNT(*) FROM [Core].[Student]
              WHERE [StateStudentID] = @StateStudentID AND [AdministrationID] = @AdministrationID

              IF (@Count) > 1 
                     SET @ErrorCode = 5 -- StateStudentID not unique
       END

       IF (@ErrorCode = 0) -- StateTeacherID and StateStudentID ARE unique
              BEGIN
              SELECT @TeacherID = [ct].[TeacherID]
                     FROM
                           [Core].[Teacher] [ct]
                           INNER JOIN [Teacher].[Sites] [ts]
                           ON [ts].[AdministrationID] = [ct].[AdministrationID] AND 
							  [ts].[TeacherID] = [ct].[TeacherID]
                     WHERE
                           [ct].[StateTeacherID] = @StateTeacherID AND
                           [ct].[AdministrationID] = @AdministrationID AND
                           [ts].[DistrictCode] = @DistrictCode AND
                           [ts].[SchoolCode] = @SchoolCode

              SELECT @StudentID = [StudentID] 
                     FROM [Core].[Student]
                     WHERE 
                           [StateStudentID] = @StateStudentID AND 
                           [AdministrationID] = @AdministrationID

              SELECT @StudentGroupID = [sg].[GroupID] 
                     FROM [Core].[StudentGroup] [sg]
                     INNER JOIN [Teacher].[StudentGroups] [tsg] 
                     ON [tsg].[AdministrationID] = [sg].[AdministrationID] AND 
                        [tsg].[GroupID] = [sg].[GroupID]
              WHERE 
                     [sg].[GroupName] = @StudentGroupName AND 
                     [sg].[AdministrationID] = @AdministrationID AND 
                     [sg].[DistrictCode] = @DistrictCode AND 
                     [sg].[SchoolCode] = @SchoolCode AND 
                     [tsg].[TeacherID] = @TeacherID

              IF (@TeacherID IS NULL)
              BEGIN
                     SET @ErrorCode = 1 --Teacher does not exist
              END

              IF (@ErrorCode = 0 AND @StudentID IS NULL)
              BEGIN
                     SET @ErrorCode = 3 --Student does not exist
              END

              IF (@ErrorCode = 0 AND @StudentGroupID IS NULL)
              BEGIN
                     IF (@AllowUpdateOnly = 1)
                     BEGIN
                           SET @ErrorCode = 2 -- Group does not exist
                     END
                     ELSE
                     BEGIN --add new group							
                           SET @StudentGroupID=next value for Core.StudentGroup_SeqEven;
                           INSERT [Core].[StudentGroup]
                           (
                                  [AdministrationID],
								  [GroupID],
                                  [GroupType],
                                  [GroupName],
                                  [DistrictCode],
                                  [SchoolCode],
                                  [CreateDate],
                                  [UpdateDate]
                           )
                           VALUES
                           (
                                  @AdministrationID,
								  @StudentGroupID,
                                  @StudentGroupType,
                                  @StudentGroupName,
                                  @DistrictCode,
                                  @SchoolCode,
                                  GETDATE(),
                                  GETDATE()
                           )
                           
                           INSERT [Teacher].[StudentGroups]
                           (
                                  [AdministrationID],
                                  [TeacherID],
                                  [GroupID],
                                  [CreateDate],
                                  [UpdateDate]
                           )
                           VALUES
                           (
                                  @AdministrationID,
                                  @TeacherID,
                                  @StudentGroupID,
                                  GETDATE(),
                                  GETDATE()
                           )
                           
                           SET @GroupCreated = 1
                     END
              END

              IF (@ErrorCode = 0 AND EXISTS (
                           SELECT * FROM [StudentGroup].[Links]
                           WHERE [AdministrationID] = @AdministrationID AND [GroupID] = @StudentGroupID AND [StudentID] = @StudentID))
                     SET @ErrorCode = 7 --duplicate student addition attempt

              IF (@ErrorCode = 0)
              BEGIN --Add Student to group
                     INSERT [StudentGroup].[Links] ( [AdministrationID], [GroupID], [StudentID] )
                     VALUES ( @AdministrationID, @StudentGroupID, @StudentID )
              END
       END -- StateTeacherID and StateStudentID ARE unique
END --GroupName length OK

SELECT
       ErrorCode = @ErrorCode,
       GroupCreated = @GroupCreated
GO
