USE webCAMS
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spWebGetDeviceComponent]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spWebGetDeviceComponent]
Go


CREATE PROCEDURE dbo.spWebGetDeviceComponent (
	@UserID int,
	@ClientID varchar(3),
	@TerminalID varchar(20),
	@CategoryID int
)
 AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 8/05/09 5:18p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetDeviceComponent.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 --validate user
 IF EXISTS(SELECT 1 FROM tblUser WHERE UserID = @UserID AND IsActive = 1)
  BEGIN
 	EXEC Cams.dbo.spGetDeviceComponent @ClientID = @ClientID, @TerminalID = @TerminalID, @CategoryID = @CategoryID
  END

/*

 spWebGetDeviceComponent 199510, 'nab', 'F20137'
*/

GO

Grant EXEC on spWebGetDeviceComponent to eCAMS_Role
Go



