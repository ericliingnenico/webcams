

Use CAMS
Go

Alter Procedure dbo.spWebGetFSPJobClosure 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 13/12/06 8:30a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPJobClosure.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get Job Equipment
 DECLARE @Location int
	
	
 SELECT @Location = InstallerID FROM WebCAMS.dbo.tblUser WHERE UserID = @UserID

 
 IF LEN(@JobID) = 11
  BEGIN
	--get call info
	SELECT JobType = 'SWAP',
		ClientID,
		TerminalID = TerminalID,
		MerchantName = [Name],
		JobFSP = AssignedTo,
		OnSiteDateTime = DateAdd(mi, OnSiteDateTimeOffset, OnSiteDateTime),	
		OffSiteDateTime = DateAdd(mi, OffSiteDateTimeOffset, OffSiteDateTime)
	  FROM Calls j  JOIN dbo.fnGetLocationFamilyExt(@Location) l ON j.AssignedTo = l.Location
	 WHERE CallNumber = @JobID


  END
 ELSE
  BEGIN
	SELECT JobType,
		ClientID,
		TerminalID,
		MerchantName = [Name],
		JobFSP = BookedInstaller,
		OnSiteDateTime = DateAdd(mi, OnSiteDateTimeOffset, OnSiteDateTime),	
		OffSiteDateTime = DateAdd(mi, OffSiteDateTimeOffset, OffSiteDateTime)
	  FROM vwIMSJob j  JOIN dbo.fnGetLocationFamilyExt(@Location) l ON j.BookedInstaller = l.Location
 	 WHERE JobID = @JobID

  END

GO
Grant EXEC on spWebGetFSPJobClosure to eCAMS_Role
Go


Use WebCAMS
Go
Alter Procedure dbo.spWebGetFSPJobClosure 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 17/10/03 11:25 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPJobClosure.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPJobClosure @UserID = @UserID, @JobID = @JobID
/*
spWebGetFSPJobClosure 199663, 20050303172
spWebGetFSPJobClosure 199663, 310352
312691

select * from webcams.dbo.tblUSer

select * from calls
 where assignedto = 3011

select * from ims_jobs
 where bookedinstaller = 3011



*/
Go

Grant EXEC on spWebGetFSPJobClosure to eCAMS_Role
Go
