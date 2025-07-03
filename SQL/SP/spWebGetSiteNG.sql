USE CAMS
Go

if object_id('spWebGetSiteNG') is null
	exec ('create procedure dbo.spWebGetSiteNG as return 1')
go

Alter Procedure dbo.spWebGetSiteNG 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20)
	)
	AS
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/09/16 9:53 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetSiteNG.sql $-->
--<!--$$NoKeywords: $-->
 set nocount on
 declare @ret int

 exec @ret = dbo.spWebIsUserAllowedAPIAccessNG @UserID = @UserID, @MethodID = 7	--1: UpdateJobNote; 2: CloseJob; 3: LogNewJob; 4: GetOpenJobList; 5: GetJob; 6: GetCall, 7: GetMerchant
 if @ret <> 0 return @ret

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
	sm.Acq1CAIC as CAIC,
	s.StateRegion
	FROM Sites s WITH (NOLOCK) JOIN UserClientDeviceType u WITH (NOLOCK) ON s.ClientID = u.ClientID AND isnull(s.DeviceType, '') = ISNULL(u.DeviceType, isnull(s.DeviceType, ''))
		left outer join vwRegion r WITH (NOLOCK) ON s.RegionID = r.RegionID
		left outer join site_maintenance sm WITH (NOLOCK) ON s.ClientID = sm.ClientID and s.TerminalID = sm.TerminalID
	WHERE s.ClientID =  @ClientID 
		AND u.UserID = @UserID
		AND s.TerminalID = @TerminalID

--Return
RETURN @@ERROR

GO

Grant EXEC on spWebGetSiteNG to eCAMS_Role
Go

/*

 exec dbo.spWebGetSiteNG 
		@UserID = 210000 ,
		@ClientID = 'cba',
		@TerminalID = '16151900'

*/
Go
