
use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetJobMethod' and type = 'p')
	drop proc spWebGetJobMethod
go

create proc spWebGetJobMethod (
	@UserID int,
	@ClientID varchar(3),
	@JobTypeID tinyint)
as
 SET NOCOUNT ON
 EXEC  CAMS.dbo.spGetJobMethod @ClientID = @ClientID,
				@JobTypeID = @JobTypeID


/*
 spWebGetJobMethod  1, 'BOQ', 1

*/

Go




GRANT EXEC ON spWebGetJobMethod TO eCAMS_Role
go

use CAMS
Go

Grant exec on spGetJobMethod to eCAMS_Role
go

use webCAMS
go



