
Use CAMS
Go

Alter Procedure dbo.spWebPutFSPTask 
	(
		@UserID int,
		@TaskID int,
		@CarrierID tinyint,
		@ConNoteNo varchar(30),
		@CloseComment varchar(100)
	)
	AS
--<!--$$Revision: 10 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 30/03/05 1:41p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutFSPTask.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @InstallerID int,
	@Count int,
	@ClientID varchar(3),
	@FSPOperator int,
	@ToLocation int,
	@ret int

 SELECT @ret = 0

 --Get FSPID
 SELECT @InstallerID = InstallerID,
	@FSPOperator = -InstallerID
   FROM WebCams.dbo.tblUser
   WHERE UserID = @UserID


 IF EXISTS(SELECT 1 FROM tblTask t JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON t.AssignedTo = l.Location
		WHERE  TaskID = @TaskID)
  BEGIN
	--get task info
	SELECT @ClientID = ISNULL(j.ClientID, c.ClientID),
		@ToLocation = t.ToLocation
		FROM tblTask t LEFT OUTER JOIN IMS_Jobs j ON j.JobID = t.JobID AND t.SourceID = 1
			LEFT OUTER JOIN Calls c ON CAST(c.CallNumber as BigInt) = t.JobID AND t.SourceID = 2
		WHERE t.TaskID = @TaskID

	--update task details
	UPDATE tblTask
	   SET CarrierID = ISNULL(@CarrierID, CarrierID),
		ConNoteNo = ISNULL(@ConNoteNo, ConNoteNo),
		CloseComment = ISNULL(@CloseComment, CloseComment)
  	 WHERE  TaskID = @TaskID

	SELECT @ret = @@ERROR
  END

 RETURN @ret
GO

Grant EXEC on spWebPutFSPTask to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebPutFSPTask 
	(
		@UserID int,
		@TaskID int,
		@CarrierID tinyint,
		@ConNoteNo varchar(30),
		@CloseComment varchar(100)
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutFSPTask.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebPutFSPTask @UserID = @UserID, 
				@TaskID = @TaskID,
				@CarrierID = @CarrierID,
				@ConNoteNo = @ConNoteNo,
				@CloseComment = @CloseComment

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
/*

spWebPutFSPTask 199512, 1670, 'bl101', null, 1, 'abc', 'test'

SELECT * FROM tblTask t JOIN dbo.fnGetLocationChildrenExt(3001) l ON t.ToLocation = l.Location
		WHERE  TaskID = 1672

*/
GO

Grant EXEC on spWebPutFSPTask to eCAMS_Role
Go
