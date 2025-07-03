
use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetClientTerminalConfigField' and type = 'p')
	drop proc spWebGetClientTerminalConfigField
go

create proc spWebGetClientTerminalConfigField (
	@UserID int,
	@ClientID varchar(3))
as
 SET NOCOUNT ON
 EXEC  CAMS.dbo.spGetClientTerminalConfigField @ClientID = @ClientID

/*
 spWebGetClientTerminalConfigField  1, 'WBC'

*/

Go




GRANT EXEC ON spWebGetClientTerminalConfigField TO eCAMS_Role
go

use CAMS
Go

Grant exec on spGetClientTerminalConfigField to eCAMS_Role
go



