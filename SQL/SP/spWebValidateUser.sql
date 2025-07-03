Use WebCAMS
Go

Alter Procedure dbo.spWebValidateUser 
	(
		@EmailAddress 	varchar(100),
		@Password 	binary(16)
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 29/01/07 9:41a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebValidateUser.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT OFF
 SELECT UserID  FROM tblUser WHERE EmailAddress = @EmailAddress 
					AND [Password] = @Password
 					AND IsActive = 1

 IF @@ROWCOUNT = 0
	insert tblFailureLoginLog (EmailAddress, [Password], LogDateTime)
		values (@EmailAddress, @Password, getdate())

/*
exec spWebValidateUser 'bo', 'bo'
SELECT * FROM tblUser 
*/
GO


Grant EXEC on spWebValidateUser to eCAMS_Role
Go

