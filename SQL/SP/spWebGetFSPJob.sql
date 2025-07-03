Use WebCAMS
Go

ALTER PROCEDURE dbo.spWebGetFSPJob 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 15 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 23/06/11 13:45 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPJob @UserID = @UserID, @JobID = @JobID
/*
spWebGetFSPJob 199649, 20110610270


*/
GO

Grant EXEC on spWebGetFSPJob to eCAMS_Role
Go


Use CAMS
Go

Alter Procedure dbo.spWebGetFSPJob 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 4 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 9/04/03 13:04 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebGetFSPJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @InstallerID int

 --Get FSPID
 SELECT @InstallerID = InstallerID 
   FROM WebCams.dbo.tblUser
   WHERE UserID = @UserID
   
 --cache the FSP location
 select * into #FSP
	from dbo.fnGetLocationChildrenExt(@InstallerID)
	
 if dbo.fnIsSwapCall(@JobID) = 1
  begin
	 IF EXISTS(SELECT 1 FROM vwCalls with (nolock) WHERE CallNumber = cast(@JobID as varchar))
	  BEGIN
		 SELECT 
			JobType = 'SWAP',
			*
			From vwCalls 
			WHERE CallNumber = cast(@JobID as varchar) and AssignedTo in (select Location from #FSP)

	  END
	 ELSE
	  BEGIN
		 SELECT 
			JobType = 'SWAP',		 
			*
			From vwCallsHistory with (nolock) 
			WHERE CallNumber = cast(@JobID as varchar) and AssignedTo in (select Location from #FSP)
	  END
  end
 else
  begin
	 IF EXISTS(SELECT 1 FROM vwIMSJob with (nolock) WHERE JobID = @JobID)
	  BEGIN
		 SELECT 
			*
			FROM vwIMSJob
			WHERE  JobID = @JobID and BookedInstaller in (select Location from #FSP)

	  END
	 ELSE
	  BEGIN
		SELECT * 
			FROM vwIMSJobHistory with (nolock) 
			WHERE  JobID = @JobID and BookedInstaller in (select Location from #FSP)
	  END
  end  
GO

Grant EXEC on spWebGetFSPJob to eCAMS_Role
Go


