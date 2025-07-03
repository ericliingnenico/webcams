USE [CAMS]
GO

if object_id('spWebGetJobDeviceTypeNG') is null
	exec ('create procedure dbo.spWebGetJobDeviceTypeNG as return 1')
go


alter proc  spWebGetJobDeviceTypeNG (
	@UserID int,
	@ClientID varchar(3),
	@JobTypeID tinyint)
as
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 24/08/15 14:15 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetJobDeviceTypeNG.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Retrieve device type
*/
 SET NOCOUNT ON
 --Need to check if the user has a devicetype specified
 IF EXISTS(SELECT 1 FROM UserClientDeviceType WHERE UserID = @UserID AND ClientID = @ClientID AND ISNULL(DeviceType, '') <> '')
  BEGIN
	SELECT * FROM UserClientDeviceType WHERE UserID = @UserID AND ClientID = @ClientID
  END
 ELSE
  BEGIN
    CREATE TABLE #tmpDeviceType (DeviceType varchar(40) collate database_default)
		
	INSERT INTO #tmpDeviceType  EXEC  CAMS.dbo.spGetJobDeviceType @DefaultType = 'E',
					@ClientID = @ClientID,
					@JobTypeID = @JobTypeID,
					@IncludeAll = 0
				
	SELECT * 
		from #tmpDeviceType
		order by DeviceType
  END


/*
 spWebGetJobDeviceTypeNG  1, 'WBC', 2

*/

Go




GRANT EXEC ON spWebGetJobDeviceTypeNG TO eCAMS_Role
go


