
Use CAMS
Go

Alter Procedure dbo.spWebGetFSPOpenTaskList 
	(
		@UserID int,
		@FSPID int,
		@From tinyint
	)
	AS
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 24/10/06 3:20p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPOpenTaskList.sql $-->
--<!--$$NoKeywords: $-->
---Get all open tasks for a FSP
DECLARE @InstallerID int

 IF @From = 1  --from desk top web
  BEGIN
	 IF @FSPID IS NULL
	  BEGIN
		--no fsp passed in, only return user's jobs
		SELECT 
			'<A HREF="../Member/FSPTask.aspx?JID=' + CAST(TaskID as varchar) + '">' + CAST(t.JobID as varchar) + '-' + CAST(TaskID as varchar) + '</A>' as JobID,
			ClientID = CASE WHEN t.SourceID = 1 THEN j.ClientID ELSE c.ClientID END,
		 	DeviceType = CASE WHEN t.SourceID = 1 THEN j.DeviceType ELSE c.CallType END,
	 		ToLocation, 
			t.DueDateTimeLocal
	
			FROM vwTask t JOIN WebCams.dbo.tblUser u ON t.AssignedTo = u.InstallerID
					LEFT OUTER JOIN IMS_Jobs j ON j.JobID = t.JobID AND t.SourceID = 1
					LEFT OUTER JOIN vwCalls c ON CAST(c.CallNumber as BigInt)  = t.JobID AND t.SourceID = 2
			WHERE u.UserID = @UserID
				AND t.IsTaskHistory = 0
		Order by t.DueDateTimeLocal
	
	  END
	 ELSE
	  BEGIN
		--fsp passed in
		--verify FSPID is valid
		SELECT @InstallerID = InstallerID 
		  FROM WebCams.dbo.tblUser
		  WHERE UserID = @UserID

		--no fsp passed in, only return user's jobs
		SELECT 
			'<A HREF="../Member/FSPTask.aspx?JID=' + CAST(TaskID as varchar) + '">' + CAST(t.JobID as varchar) + '-' + CAST(TaskID as varchar) + '</A>' as JobID,
			ClientID = CASE WHEN t.SourceID = 1 THEN j.ClientID ELSE c.ClientID END,
		 	DeviceType = CASE WHEN t.SourceID = 1 THEN j.DeviceType ELSE c.CallType END,
	 		ToLocation, 
			t.DueDateTimeLocal
	
			FROM vwTask t JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON t.AssignedTo = l.Location
					LEFT OUTER JOIN IMS_Jobs j ON j.JobID = t.JobID AND t.SourceID = 1
					LEFT OUTER JOIN vwCalls c ON CAST(c.CallNumber as BigInt)  = t.JobID AND t.SourceID = 2
			WHERE t.AssignedTo = @FSPID
				AND t.IsTaskHistory = 0
		Order by t.DueDateTimeLocal
	
	  END
	

  END --from desktop web
 ELSE
  --from PDA web
  BEGIN
	 IF @FSPID IS NULL
	  BEGIN
		--no fsp passed in, only return user's jobs
		SELECT 
			'<A HREF="../Member/pFSPTask.aspx?JID=' + CAST(TaskID as varchar) + '">' + CAST(t.JobID as varchar) + '-' + CAST(TaskID as varchar) + '</A>' as JobID,
			ClientID = CASE WHEN t.SourceID = 1 THEN j.ClientID ELSE c.ClientID END,
		 	DeviceType = CASE WHEN t.SourceID = 1 THEN j.DeviceType ELSE c.CallType END,
	 		--ToLocation, 
			t.DueDateTimeLocal
	
			FROM vwTask t JOIN WebCams.dbo.tblUser u ON t.AssignedTo = u.InstallerID
					LEFT OUTER JOIN IMS_Jobs j ON j.JobID = t.JobID AND t.SourceID = 1
					LEFT OUTER JOIN vwCalls c ON CAST(c.CallNumber as BigInt)  = t.JobID AND t.SourceID = 2
			WHERE u.UserID = @UserID
				AND t.IsTaskHistory = 0
		Order by t.DueDateTimeLocal
	
	  END
	 ELSE
	  BEGIN
		--fsp passed in
		--verify FSPID is valid
		SELECT @InstallerID = InstallerID 
		  FROM WebCams.dbo.tblUser
		  WHERE UserID = @UserID

		--no fsp passed in, only return user's jobs
		SELECT 
			'<A HREF="../Member/pFSPTask.aspx?JID=' + CAST(TaskID as varchar) + '">' + CAST(t.JobID as varchar) + '-' + CAST(TaskID as varchar) + '</A>' as JobID,
			ClientID = CASE WHEN t.SourceID = 1 THEN j.ClientID ELSE c.ClientID END,
		 	DeviceType = CASE WHEN t.SourceID = 1 THEN j.DeviceType ELSE c.CallType END,
	 		--ToLocation, 
			t.DueDateTimeLocal
	
			FROM vwTask t JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON t.AssignedTo = l.Location
					LEFT OUTER JOIN IMS_Jobs j ON j.JobID = t.JobID AND t.SourceID = 1
					LEFT OUTER JOIN vwCalls c ON CAST(c.CallNumber as BigInt)  = t.JobID AND t.SourceID = 2
			WHERE t.AssignedTo = @FSPID
				AND t.IsTaskHistory = 0
		Order by t.DueDateTimeLocal
	
	  END

  END

GO

Grant EXEC on spWebGetFSPOpenTaskList to eCAMS_Role
Go

Use WebCAMS
Go

ALter Procedure dbo.spWebGetFSPOpenTaskList 
	(
		@UserID int,
		@FSPID int,
		@From tinyint
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 11:41a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPOpenTaskList.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPOpenTaskList @UserID = @UserID, @FSPID = @FSPID, @From = @From
/*
select * from webcams.dbo.tblUser

spWebGetFSPOpenTaskList 199512, 3001, 1

select * from tblTask where taskID = 1663

*/
Go

Grant EXEC on spWebGetFSPOpenTaskList to eCAMS_Role
Go
