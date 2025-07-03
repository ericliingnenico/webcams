Use WebCAMS
Go

Alter Procedure dbo.spWebAdminUser 
	(
		@UserID		int,
		@EmailAddress	varchar(50),
		@Name	varchar(50),
		@NewPassword	binary(16),
		@ClientIDs varchar(100) = NULL,
		@InstallerID int = NULL,
		@MenuSetID tinyint,
		
		@Flag		tinyint
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 10/05/07 12:03p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebAdminUser.sql $-->
--<!--$$NoKeywords: $-->
 -- @Flag = 1 - Add new user, need fields: @Name, @NewPassword, @ClientIDs, @InstallerID, @MenuSetID
 -- @Flag = 2 - Reset password, need field: @NewPassword
 -- @Flag = 3 - DeActive user
 -- @Flag = 4 - Activate user
 -- only the user who has permission to access AdminUser Module can use this proc
 SET NOCOUNT ON
 DECLARE @ret int

 --init 
 SELECT @ret = -1

 IF EXISTS(SELECT * FROM tblUserModule um JOIN tblModule m ON um.ModuleID = m.ModuleID	WHERE um.UserID = @UserID AND m.IsActive = 1 AND m.ModuleID = 4)
  BEGIN
	--add new user
	 IF @Flag = 1 
	  BEGIN
		EXEC @ret = dbo.spWebAddNewUser 
			@EmailAddress = @EmailAddress,
			@Name = @Name,
			@NewPassword = @NewPassword,
			@ClientIDs = @ClientIDs,
			@InstallerID = @InstallerID,
			@MenuSetID = @MenuSetID
	  END

	--reset password
	 IF @Flag = 2
	  BEGIN
		 UPDATE tblUser
		    SET [Password] = @NewPassword,
			UpdateTime = Getdate(),
			ExpiryDate = DateAdd(d, 60, GetDate()),
			IsActive = 1
		  WHERE EmailAddress = @EmailAddress
	  END
		
	--deactivate user
	 IF @Flag = 3
	  BEGIN
		 UPDATE tblUser
		    SET IsActive = 0
		  WHERE EmailAddress = @EmailAddress
	  END

	--activate user
	 IF @Flag = 4
	  BEGIN
		 UPDATE tblUser
		    SET IsActive = 1,
			UpdateTime = Getdate(),
			ExpiryDate = DateAdd(d, 60, GetDate())
		  WHERE EmailAddress = @EmailAddress
	  END

  END
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
/*

exec spWebAdminUser 
		@UserID		= 199649,
		@EmailAddress	= '3091',
		@Name		= '3091',
		@NewPassword	= 0x08637BA2941A368AFCF72FABF79F4C2D,
		@ClientIDs  = NULL,
		@InstallerID 	= 3091,
		@MenuSetID =3,
		
		@Flag		=1

select * from tbluser


*/

GO


Grant EXEC on spWebAdminUser to eCAMS_Role
Go
