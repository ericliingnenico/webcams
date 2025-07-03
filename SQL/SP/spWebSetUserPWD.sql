Use WebCAMS
Go

Alter Procedure dbo.spWebSetUserPWD 
	(
		@UserID		int,
		@Password 	binary(16)

	)
	AS
--<!--$$Revision: 12 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 25/05/15 13:52 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebSetUserPWD.sql $-->
--<!--$$NoKeywords: $-->

 SET NOCOUNT ON

insert tblActionLog(ActionTypeID, ActionData, UserID,LogDate)
	values(8,'',@UserID,GETDATE())

 SET NOCOUNT OFF

 UPDATE tblUser
	SET [Password] = @Password,
	IsActive = 1,
	UpdateTime = GetDate(),
	ExpiryDate = DateAdd(d, 60, GetDate())
	WHERE UserID = @UserID


/*
exec spWebSetUserPWD 202566, 0x5E7ED46BA4B1C4396F5B029BCA3A8BE1

*/

GO

Grant EXEC on spWebSetUserPWD to eCAMS_Role
Go


