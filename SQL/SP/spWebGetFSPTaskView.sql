use CAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetFSPTaskView' and type = 'p')
	drop proc spWebGetFSPTaskView
go

create proc spWebGetFSPTaskView (
	@UserID int,
	@TaskID int)
as
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 30/01/06 4:11p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPTaskView.sql $-->
--<!--$$NoKeywords: $-->
DECLARE @InstallerID int
 SET NOCOUNT ON

 SELECT @InstallerID = InstallerID 
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 SELECT t.TaskRefID,
	t.ClientID,
	t.TaskSummary,
	t.TaskDetails,
	t.AssignedTo,
	t.DeliveryName,
	t.DeliveryAddress1,
	t.DeliveryAddress2,
	t.DeliveryContact,
	t.DeliveryCity,
	t.DeliveryState,
	t.TerminalID,
	t.DeviceType,
	t.Serial,
	t.DeviceDescription,
	t.ClosedDateTime
   FROM vwTaskFax t JOIN dbo.fnGetLocationChildrenExt(@InstallerID) l ON t.AssignedTo = l.Location
  WHERE TaskID = @TaskID

/*
spWebGetFSPTaskView 199611, 20552
*/
go

grant EXEC on spWebGetFSPTaskView to eCAMS_Role
go

use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetFSPTaskView' and type = 'p')
	drop proc spWebGetFSPTaskView

go

create proc spWebGetFSPTaskView (
	@UserID int,
	@TaskID int)
as
 exec CAMS.dbo.spWebGetFSPTaskView @UserID = @UserID,
				@TaskID = @TaskID

Go

	
grant exec on spWebGetFSPTaskView to eCAMS_Role
go
