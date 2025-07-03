Use CAMS
Go

Alter Procedure dbo.spWebGetFSPOpenJobList 
	(
		@UserID int,
		@ClientID varchar(3) = NULL,
		@JobType varchar(20) = NULL,
		@From tinyint
	)
	AS
--<!--$$Revision: 22 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/07/09 2:13p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPOpenJobList.sql $-->
--<!--$$NoKeywords: $-->
---@From : 1 - From Web, 2 - From Mobile Device
 IF @From = 1
  --From Web Site
  BEGIN
	 IF @ClientID IS NULL OR @ClientID = 'ALL'
	 	SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as JobID,
			j.ClientID, 
			MerchantID, 
			TerminalID, 
			Status, 
	     	AgentSLADateTimeLocal AS RequiredDateTime,
			[Name] as MerchantName,
			Postcode,
			j.ProjectNo,
			CASE WHEN j.AllowPDADownload = 1 AND j.AgentSLADateTimeLocal IS NOT NULL THEN '<A HREF="../Member/FSPReAssignJob.aspx?JID=' + cast(JobID as varchar) + '">ReAssign</A>' 
				ELSE ''
			END as [Action]
			FROM vwIMSJob j JOIN WebCams.dbo.tblUser u ON j.BookedInstaller = u.InstallerID
			WHERE u.UserID = @UserID
				AND JobType = ISNULL(@JobType, JobType)
				AND j.AllowFSPWebAccess = 1
			 Order by j.ClientID, TerminalID, Postcode
	 ELSE
	 	SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as JobID,
			j.ClientID, 
			MerchantID, 
			TerminalID, 
			Status, 
	     	AgentSLADateTimeLocal AS RequiredDateTime,
			[Name] as MerchantName,
			Postcode,
			j.ProjectNo,
			CASE WHEN j.AllowPDADownload = 1 AND j.AgentSLADateTimeLocal IS NOT NULL THEN '<A HREF="../Member/FSPReAssignJob.aspx?JID=' + cast(JobID as varchar) + '">ReAssign</A>' 
				ELSE '' 
			END as [Action]
			FROM vwIMSJob j JOIN WebCams.dbo.tblUser u ON j.BookedInstaller = u.InstallerID
			WHERE u.UserID = @UserID
				AND ClientID = @ClientID
				AND JobType = ISNULL(@JobType, JobType)
				AND j.AllowFSPWebAccess = 1
			 Order by j.ClientID, TerminalID, Postcode

  END
 ELSE
  --From Mobile Device
  BEGIN
	 IF @ClientID IS NULL OR @ClientID = 'ALL'
	 	SELECT 
			JobID,
			j.ClientID, 
			MerchantID, 
			TerminalID, 
			Status, 
	     	ISNULL(dbo.fnFormatDateTime(AgentSLADateTimeLocal), 'N/A') AS RequiredDateTime,
			[Name] as MerchantName,
			Postcode
			FROM vwIMSJob j JOIN WebCams.dbo.tblUser u ON j.BookedInstaller = u.InstallerID
			WHERE u.UserID = @UserID
				AND JobType = ISNULL(@JobType, JobType)
				AND j.AllowFSPWebAccess = 1
			 Order by j.ClientID, TerminalID, Postcode
	 ELSE
	 	SELECT 
			JobID,
			j.ClientID, 
			MerchantID, 
			TerminalID, 
			Status, 
	     	ISNULL(dbo.fnFormatDateTime(AgentSLADateTimeLocal), 'N/A') AS RequiredDateTime,
			[Name] as MerchantName,
			Postcode
			FROM vwIMSJob j JOIN WebCams.dbo.tblUser u ON j.BookedInstaller = u.InstallerID
			WHERE u.UserID = @UserID
				AND ClientID = @ClientID
				AND JobType = ISNULL(@JobType, JobType)
				AND j.AllowFSPWebAccess = 1
			 Order by j.ClientID, TerminalID, Postcode

  END


GO

Grant EXEC on spWebGetFSPOpenJobList to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebGetFSPOpenJobList 
	(
		@UserID int,
		@ClientID varchar(3) = NULL,
		@JobType varchar(20) =  NULL,
		@From tinyint
	)
	AS
--<!--$$Revision: 13 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 25/05/04 4:51p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPOpenJobList.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPOpenJobList @UserID = @UserID, @ClientID = @ClientID, @JobType = @JobType, @From = @From
/*
spWebGetFSPOpenJobList 3, 'all', 'install', 1
*/
Go

Grant EXEC on spWebGetFSPOpenJobList to eCAMS_Role
Go
