
use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetJobDeviceType' and type = 'p')
	drop proc spWebGetJobDeviceType
go

create proc spWebGetJobDeviceType (
	@UserID int,
	@ClientID varchar(3),
	@JobTypeID tinyint)
as
 SET NOCOUNT ON
 --Need to check if the user has a devicetype specified
 IF EXISTS(SELECT 1 FROM tblUserClientDeviceType WHERE UserID = @UserID AND ClientID = @ClientID AND ISNULL(DeviceType, '') <> '')
  BEGIN
	SELECT * FROM tblUserClientDeviceType WHERE UserID = @UserID AND ClientID = @ClientID
  END
 ELSE
  BEGIN
    CREATE TABLE #tmpDeviceType (DeviceType varchar(40) collate database_default)
    --insert empty to force user to select a devicetype on UI
	INSERT INTO #tmpDeviceType (DeviceType)
		values ('')
		
	INSERT INTO #tmpDeviceType  EXEC  CAMS.dbo.spGetJobDeviceType @DefaultType = 'E',
					@ClientID = @ClientID,
					@JobTypeID = @JobTypeID,
					@IncludeAll = 0
				
	SELECT * 
		from #tmpDeviceType
		order by DeviceType
  END


/*
 spWebGetJobDeviceType  1, 'WBC', 2

*/

Go




GRANT EXEC ON spWebGetJobDeviceType TO eCAMS_Role
go

use CAMS
Go

Grant exec on spGetJobDeviceType to eCAMS_Role
go

Grant select on tblJobMMDPartDefault to eCAMS_Role
go

use webCAMS
go



