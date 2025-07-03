

Use CAMS
Go

Alter Procedure dbo.spWebGetFSPOpenCallList 
	(
		@UserID int,
		@ClientID varchar(3) = null,
		@From tinyint
	)
	AS
--<!--$$Revision: 21 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/07/09 2:13p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPOpenCallList.sql $-->
--<!--$$NoKeywords: $-->
---@From : 1 - From Web, 2 - From Mobile Device
 IF @From = 1
  --From Web Site
  BEGIN
	 IF @ClientID IS NULL OR @ClientID = 'ALL'
		SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + CallNumber + ''')">' + CallNumber + '</A>' as CallNumber,
	 		 c.ClientID, 
			MerchantID as MerchantID, 
			TerminalID as TerminalID, 
			Status, 
		    AgentSLADateTimeLocal AS RequiredDateTime,
			[Name] as MerchantName,
			Postcode,
			CASE WHEN c.AllowPDADownload = 1 AND c.AgentSLADateTimeLocal IS NOT NULL THEN '<A HREF="../Member/FSPReAssignJob.aspx?JID=' + CallNumber + '">ReAssign</A>'
				ELSE '' 
			END as [Action]
			FROM vwCalls c JOIN WebCams.dbo.tblUser u ON c.AssignedTo = u.InstallerID
			WHERE u.UserID = @UserID
				AND c.AllowFSPWebAccess = 1
			Order by c.ClientID, TerminalID, Postcode
	 ELSE
		SELECT 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + CallNumber + ''')">' + CallNumber + '</A>' as CallNumber,
	 		 c.ClientID, 
			MerchantID as MerchantID, 
			TerminalID as TerminalID, 
			Status, 
		    AgentSLADateTimeLocal AS RequiredDateTime,
			[Name] as MerchantName,
			Postcode,
			CASE WHEN c.AllowPDADownload = 1 AND c.AgentSLADateTimeLocal IS NOT NULL THEN '<A HREF="../Member/FSPReAssignJob.aspx?JID=' + CallNumber + '">ReAssign</A>'
				ELSE '' 
			END as [Action]
			FROM vwCalls c JOIN WebCams.dbo.tblUser u ON c.AssignedTo = u.InstallerID
			WHERE u.UserID = @UserID
				AND c.ClientID = @ClientID
				AND c.AllowFSPWebAccess = 1
			Order by c.ClientID, TerminalID, Postcode
  END
 ELSE
  --From Mobile Device
  BEGIN
	 IF @ClientID IS NULL OR @ClientID = 'ALL'
	 	SELECT 
			CallNumber as JobID,
	 		 c.ClientID, 
			MerchantID as MerchantID, 
			TerminalID as TerminalID, 
			Status, 
		     	dbo.fnFormatDateTime(AgentSLADateTimeLocal) AS RequiredDateTime,
			[Name] as MerchantName,
			Postcode
			FROM vwCalls c JOIN WebCams.dbo.tblUser u ON c.AssignedTo = u.InstallerID
			WHERE u.UserID = @UserID
				AND c.AllowFSPWebAccess = 1
			Order by c.ClientID, TerminalID, Postcode
	 ELSE
	 	SELECT 
			CallNumber as JobID,
	 		 c.ClientID, 
			MerchantID as MerchantID, 
			TerminalID as TerminalID, 
			Status, 
		     	dbo.fnFormatDateTime(AgentSLADateTimeLocal) AS RequiredDateTime,
			[Name] as MerchantName,
			Postcode
			FROM vwCalls c JOIN WebCams.dbo.tblUser u ON c.AssignedTo = u.InstallerID
			WHERE u.UserID = @UserID
				AND c.ClientID = @ClientID
				AND c.AllowFSPWebAccess = 1
			Order by c.ClientID, TerminalID, Postcode


  END



GO

Grant EXEC on spWebGetFSPOpenCallList to eCAMS_Role
Go


Use WebCAMS
Go

Alter Procedure dbo.spWebGetFSPOpenCallList 
	(
		@UserID int,
		@ClientID varchar(3) = null,
		@From tinyint
	)
	AS
--<!--$$Revision: 13 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 25/05/04 4:51p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPOpenCallList.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPOpenCallList @UserID = @UserID, @ClientID = @ClientID, @From = @From
/*
spWebGetFSPOpenCallList 3,null,1
*/
Go

Grant EXEC on spWebGetFSPOpenCallList to eCAMS_Role
Go


