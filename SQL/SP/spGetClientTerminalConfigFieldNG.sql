USE CAMS
Go

if object_id('spGetClientTerminalConfigFieldNG') is null
	exec ('create procedure dbo.spGetClientTerminalConfigFieldNG as return 1')
go

Alter Procedure dbo.spGetClientTerminalConfigFieldNG 
	(
		@UserID int,
		@ClientID varchar(3),
		@DeviceType varchar(15) = 'ALL'
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 31/08/15 14:56 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spGetClientTerminalConfigFieldNG.sql $-->
--<!--$$NoKeywords: $-->
DECLARE @ret int
 set nocount on
 select @ret = 0

  SET NOCOUNT ON
  if not exists (select 1 from UserClientDeviceType where ClientID = @ClientID and UserID = @UserID)
   begin
	raiserror ('You do not have permission to access this client data', 16, 1)
	select @ret = -1
   end

  --exec  spGetClientTerminalConfigField @ClientID = @ClientID, @DeviceType = 'ALL'
  exec  @ret = spGetClientTerminalConfigField @ClientID = @ClientID, @DeviceType = @DeviceType



--Return
RETURN @ret

GO

Grant EXEC on spGetClientTerminalConfigFieldNG to eCAMS_Role
Go

/*

 exec dbo.spGetClientTerminalConfigFieldNG 
		@UserID = 210000 ,
		@ClientID = 'cba',
		@DeviceType  = 'ALL'

*/
Go
