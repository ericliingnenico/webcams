Use WebCAMS
Go

Alter Procedure dbo.spWebGetUser 
	(
		@UserID		int
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 11/07/11 9:36 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetUser.sql $-->
--<!--$$NoKeywords: $-->
 SELECT u.*,
	m.MenuSet,
	dbo.fnCanUseNewPCAMS(u.UserID) as CanUseNewPCAMS
  FROM tblUser u JOIN tblMenuSet m ON u.MenuSetID = m.MenuSetID
  WHERE u.UserID = @UserID

/*
exec spWebGetUser 201222
SELECT * FROM tblUser 
*/

GO


Grant EXEC on spWebGetUser to eCAMS_Role
Go
