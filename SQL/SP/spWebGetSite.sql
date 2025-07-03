Use WebCAMS
Go

Alter PROCEDURE dbo.spWebGetSite 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20)
	)
	AS
--<!--$$Revision: 24 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 8/11/10 9:13 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetSite.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC CAMS.dbo.spWebGetSite @UserID = @UserID, @ClientID = @ClientID, @TerminalID = @TerminalID


/*
spWebGetSite 2, 'wbc', '21999853'
exec spWebGetSite @UserID=200206,@ClientID='NAB',@TerminalID='C47004'


*/
Go

Grant EXEC on spWebGetSite to eCAMS_Role
Go


Use CAMS
Go

Alter Procedure dbo.spWebGetSite 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/03/03 17:02 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebGetSite.sql $-->
--<!--$$NoKeywords: $-->
 set nocount on
 SELECT s.ClientID, 
	s.TerminalID,
	s.MerchantID, 
	s.[Name],
	s.Address,
	s.Address2,
	s.City, 
	s.State,
	s.Postcode,
	ISNULL(s.PhoneNumber, '') as Phone,
	ISNULL(s.PhoneNumber2, '') as Phone2,
	s.Contact,
	s.DeviceType,
	s.BusinessActivity,
	s.TradingHoursMon,
	s.TradingHoursTue,
	s.TradingHoursWed,
	s.TradingHoursThu,
	s.TradingHoursFri,
	s.TradingHoursSat,
	s.TradingHoursSun,
	dbo.fnGetTradingHoursInfo(s.TradingHoursMon, s.TradingHoursTue, s.TradingHoursWed, s.TradingHoursThu, s.TradingHoursFri, s.TradingHoursSat, s.TradingHoursSun) as TradingHoursInfo,
	sm.EquipmentCodes as EquipmentCode,
	s.RegionID,
	r.Region,
	sm.NetworkTerminalID,
	s.IsActive,
	s.CustomerNumber,
	s.AltMerchantID
	FROM Sites s WITH (NOLOCK) JOIN WebCams.dbo.tblUserClientDeviceType u WITH (NOLOCK) ON s.ClientID = u.ClientID AND isnull(s.DeviceType, '') = ISNULL(u.DeviceType, isnull(s.DeviceType, ''))
		left outer join vwRegion r WITH (NOLOCK) ON s.RegionID = r.RegionID
		left outer join site_maintenance sm WITH (NOLOCK) ON s.ClientID = sm.ClientID and s.TerminalID = sm.TerminalID
	WHERE s.ClientID =  @ClientID 
		AND u.UserID = @UserID
		AND s.TerminalID = @TerminalID


--Return
RETURN @@ERROR

GO

Grant EXEC on spWebGetSite to eCAMS_Role
Go

