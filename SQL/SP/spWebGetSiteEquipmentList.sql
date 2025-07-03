Use WebCAMS
Go

Alter Procedure dbo.spWebGetSiteEquipmentList 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20)
	)
	AS
--<!--$$Revision: 18 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 8/11/10 9:15 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetSiteEquipmentList.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC CAMS.dbo.spWebGetSiteEquipmentList @UserID = @UserID, @ClientID = @ClientID, @TerminalID = @TerminalID

/*
spWebGetSiteEquipmentList 2, 'wbc', '21999853'
*/

GO

Grant EXEC on spWebGetSiteEquipmentList to eCAMS_Role
Go


Use CAMS
Go

alter Procedure dbo.spWebGetSiteEquipmentList 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20)
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 31/03/03 17:17 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebGetSiteEquipmentList.sql $-->
--<!--$$NoKeywords: $-->

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 SELECT se.ClientID, 
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/SiteView.aspx?CID=' + se.ClientID + '&TID=' + se.TerminalID + ''')">' + se.TerminalID + '</A>' as TerminalID,
	se.TerminalNumber,
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/DeviceView.aspx?SN=' + LTRIM(se.Serial) + '&CID=' + se.ClientID + '&From=SE'')">' + LTRIM(se.Serial) + '</A>' as Serial,
	se.MMD_ID,
	se.SoftwareVersion,
	se.LastChanged as LastChangedDateTime,
	se.NumberOfChanges
	FROM Site_Equipment se JOIN Sites s ON se.ClientID = s.ClientID AND se.TerminalID = s.TerminalID
				JOIN WebCams.dbo.tblUserClientDeviceType u ON s.ClientID = u.ClientID AND isnull(s.DeviceType, '') = ISNULL(u.DeviceType, isnull(s.DeviceType, ''))
	WHERE se.ClientID = @ClientID  
		AND se.TerminalID = @TerminalID
		AND u.UserID = @UserID
--Return
RETURN @@ERROR



GO

Grant EXEC on spWebGetSiteEquipmentList to eCAMS_Role
Go

