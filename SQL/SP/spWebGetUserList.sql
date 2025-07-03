Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetUserList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetUserList]
GO



Create Procedure dbo.spWebGetUserList 
	(
		@UserID		int,
		@EmailAddress	varchar(50)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 29/01/07 4:12p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetUserList.sql $-->
--<!--$$NoKeywords: $-->
 -- only the user who has permission to access AdminUser Module can use this proc
 SELECT * 
	FROM tblUser
  	WHERE EmailAddress = @EmailAddress
		AND EXISTS(SELECT * FROM tblUserModule um JOIN tblModule m ON um.ModuleID = m.ModuleID	WHERE um.UserID = @UserID AND m.IsActive = 1  AND m.ModuleID = 4)

/*

exec spWebGetUserList 199649, '3003'


*/

GO


Grant EXEC on spWebGetUserList to eCAMS_Role
Go
