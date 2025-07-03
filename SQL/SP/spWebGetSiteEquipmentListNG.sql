
Use CAMS
Go

if object_id('spWebGetSiteEquipmentListNG') is null
	exec ('create procedure dbo.spWebGetSiteEquipmentListNG as return 1')
go


alter Procedure dbo.spWebGetSiteEquipmentListNG 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 24/08/15 9:57 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetSiteEquipmentListNG.sql $-->
--<!--$$NoKeywords: $-->

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 SELECT se.ClientID, 
	se.TerminalID,
	se.TerminalNumber,
	LTRIM(se.Serial) as Serial,
	se.MMD_ID,
	se.SoftwareVersion,
	se.LastChanged as LastChangedDateTime,
	se.NumberOfChanges
	FROM Site_Equipment se JOIN Sites s ON se.ClientID = s.ClientID AND se.TerminalID = s.TerminalID
				JOIN UserClientDeviceType u ON s.ClientID = u.ClientID AND isnull(s.DeviceType, '') = ISNULL(u.DeviceType, isnull(s.DeviceType, ''))
	WHERE se.ClientID = @ClientID  
		AND se.TerminalID = @TerminalID
		AND u.UserID = @UserID
--Return
RETURN @@ERROR



GO

Grant EXEC on spWebGetSiteEquipmentListNG to eCAMS_Role
Go

/*
exec spWebGetSiteEquipmentListNG @UserID=210000,@ClientID='CBA',@TerminalID='83271700'
*/
Go
