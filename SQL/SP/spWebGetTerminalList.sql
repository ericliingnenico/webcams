Use CAMS
Go

Alter Procedure dbo.spWebGetTerminalList 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20)
	)
	AS
--<!--$$Revision: 24 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 8/11/10 9:16 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetTerminalList.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 SELECT 
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as RefID,
	dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
	'Open' as Status,
	j.ClientID, 
	MerchantID, 
	CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
	     ELSE TerminalID 
	END as TerminalID,
	CASE WHEN JobType = 'UPGRADE' THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + ''')">' + OldTerminalID + '</A>'
	     ELSE OldTerminalID 
	END as OldTerminalID,
   	LoggedDateTime,
	[Name] as MerchantName,
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
	CASE WHEN JobType = 'DEINSTALL' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
	     WHEN JobType = 'UPGRADE' THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + OldTerminalID + '">View</A>'
	     ELSE NULL 
	END as SiteEquipment
	FROM vwIMSJob j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
	WHERE j.ClientID = @ClientID 
		AND (TerminalID = @TerminalID OR OldTerminalID = @TerminalID)
		AND u.UserID = @UserID
 UNION
 SELECT
 	'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + ''')">' + cast(JobID as varchar) + '</A>' as RefID,
	dbo.fnGetClientJobType(j.ClientID, j.JobTypeID) as Type,
	'Closed' as Status,
	j.ClientID, 
	MerchantID, 
	CASE WHEN JobType IN ('INSTALL', 'UPGRADE') THEN '<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>'
		ELSE TerminalID
	END as TerminalID,
	OldTerminalID,
   	LoggedDateTime,
	[Name] as MerchantName,
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/JobView.aspx?JID=' + cast(JobID as varchar) + '&XN=1#atgJobNote'')">JobNote</A>' as ViewNote,
	CASE WHEN JobType IN ('INSTALL', 'UPGRADE') THEN '<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>'
		ELSE NULL 
	END as SiteEquipment
	FROM vwIMSJobHistory j JOIN WebCams.dbo.tblUserClientDeviceType u ON j.ClientID = u.ClientID AND j.DeviceType = ISNULL(u.DeviceType, j.DeviceType)
	WHERE j.ClientID = @ClientID 
		AND (TerminalID = @TerminalID OR OldTerminalID = @TerminalID)
		AND u.UserID = @UserID

 UNION

 SELECT 
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as RefID,
	dbo.fnGetClientJobType(j.ClientID, 4) as Type,
	'Open' as Status,
	j.ClientID, 
	MerchantID as MerchantID, 
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>' as TerminalID,
	NULL as OldTerminalID,
   	LoggedDateTime,
	[Name] as MerchantName,
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
	'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>' as SiteEquipment
	FROM vwCalls j JOIN WebCams.dbo.vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
	WHERE j.ClientID = @ClientID 
		AND TerminalID = @TerminalID
		AND u.UserID = @UserID

 UNION
 SELECT 
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + ''')">' + CallNumber + '</A>' as RefID,
	dbo.fnGetClientJobType(j.ClientID, 4) as Type,
	'Closed' as Status,
	j.ClientID, 
	MerchantID as MerchantID, 
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + ''')">' + TerminalID + '</A>' as TerminalID,
	NULL as OldTerminalID,	     	
   	LoggedDateTime,
	[Name] as MerchantName,
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/CallView.aspx?CNO=' + CallNumber + '&XN=1#atgJobNote'')">CallNote</A>' as ViewNote,
	'<A HREF="../Member/SiteEquipmentList.aspx?CID=' + j.ClientID + '&TID=' + TerminalID + '">View</A>' as SiteEquipment
	FROM vwCallsHistory j JOIN WebCams.dbo.vwUserClientEquipmentCode u ON j.ClientID = u.ClientID AND j.EquipmentCodes = ISNULL(u.EquipmentCode, j.EquipmentCodes)
	WHERE j.ClientID = @ClientID 
		AND TerminalID = @TerminalID
		AND u.UserID = @UserID
 Order by LoggedDateTime desc
--Return
RETURN @@ERROR

GO

Grant EXEC on spWebGetTerminalList to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebGetTerminalList 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20)
	)
	AS
--<!--$$Revision: 10 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 9/05/03 12:30 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetTerminalList.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC CAMS.dbo.spWebGetTerminalList @UserID = @UserID, @ClientID = @ClientID, @TerminalID = @TerminalID
/*

exec spWebGetTerminalList 
		@UserID=200462,
		@ClientID='CTX',
		@TerminalID='28747'


*/
GO

Grant EXEC on spWebGetTerminalList to eCAMS_Role
Go




