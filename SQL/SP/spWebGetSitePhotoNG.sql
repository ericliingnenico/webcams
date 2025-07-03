USE CAMS
Go

if object_id('spWebGetSitePhotoNG') is null
	exec ('create procedure dbo.spWebGetSitePhotoNG as return 1')
go

Alter PROCEDURE dbo.spWebGetSitePhotoNG 
(
	@UserID int,
	@ClientID varchar(3),
	@TerminalID varchar(20) 

)
AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 25/08/15 10:33 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetSitePhotoNG.sql $-->
--<!--$$NoKeywords: $-->

 SET NOCOUNT ON
 --create table tblMerchantSitePhoto (ClientID varchar(3), TerminalID varchar(20), Photo image, ContentType varchar(20), JobID bigint, Latitude float, Longitude float, LogDateTime datetime, LogBy int, IsActive bit)

 --select s.*
	--FROM tblMerchantSitePhoto s JOIN UserClientDeviceType u ON s.ClientID = u.ClientID 
	--														AND isnull(s.DeviceType, '') = ISNULL(u.DeviceType, isnull(s.DeviceType, ''))
	--														AND u.ClientID = @ClientID 
	--														AND u.UserID = @UserID 
	--WHERE TerminalID = @TerminalID
--this is only for development purpose...
select top 5 ClientID = @ClientID, 
		TerminalID = @TerminalID, 
		JobSheet as Photo, 
		ContentType, 
		UpdateDateTime as LogDateTime
 from tblMerchantSignedJobSheet

/*
EXECUTE spWebGetSitePhotoNG 210000, 'CBA', '0000001'
*/
GO

Grant EXEC on dbo.spWebGetSitePhotoNG  to eCAMS_Role
Go
