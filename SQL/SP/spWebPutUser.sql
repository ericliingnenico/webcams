Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebPutUser]
GO



Create Procedure dbo.spWebPutUser 
	(
		@UserID		int,
		@UserName	varchar(100),
		@EmailAddress	varchar(100),
		@Phone		varchar(20),
		@Fax		varchar(20),
		@InstallerID	int
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 4/04/05 10:57a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutUser.sql $-->
--<!--$$NoKeywords: $-->
--@InstallerID = -999, then convert to null
 UPDATE tblUser
    SET UserName = @UserName,
	EmailAddress = @EmailAddress,
	Phone = @Phone,
	Fax = @Fax,
	InstallerID = CASE WHEN @InstallerID = -999 THEN NULL ELSE @InstallerID END,
	UpdateTime = GetDate()
  WHERE UserID = @UserID
/*

SELECT * FROM tblUser 
*/

GO


Grant EXEC on spWebPutUser to eCAMS_Role
Go
