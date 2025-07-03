Use WebCAMS
Go

Alter Procedure spWebAddNewUser (
	@EmailAddress varchar(100),
	@Name varchar(100),
	@NewPassword binary(16),
	@ClientIDs varchar(100) = NULL,
	@InstallerID int = NULL,
	@MenuSetID tinyint)
AS
--<!--$$Revision: 10 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/10/12 11:29 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebAddNewUser.sql $-->
--<!--$$NoKeywords: $-->
 DECLARE @ret int,
	@UserID int

 SET NOCOUNT ON

 SET @ret = 0
 --Start Transaction
 DECLARE @bInCallerTransaction bit
 SET @bInCallerTransaction = @@TRANCOUNT
 IF @bInCallerTransaction = 0
	BEGIN TRAN

 --add to tblUser
 INSERT tblUser (EmailAddress,
		[Password],
		UserNAme,
		Phone,
		Fax,
		IsActive,
		InstallerID,
		UpdateTime,
		ExpiryDate,
		MenuSetID)
	Values (@EmailAddress,
		@NewPassword,
		@Name,
		'N/A',
		'N/A',
		1,
		@InstallerID,
		getdate(),
		DateAdd(d, 60, GetDate()),
		@MenuSetID)


 SET @ret = @@ERROR		
 IF @ret <> 0 
	GOTO RollBack_Handle

 --get userid
 SELECT @UserID = IDENT_CURRENT('tblUser')

 SET @ret = @@ERROR		
 IF @ret <> 0 
	GOTO RollBack_Handle

 --ClientIDs is not null, adding to tblUserClient
 IF @ClientIDs IS NOT NULL
  BEGIN
	CREATE TABLE #t (DisplayOrder int IDENTITY, ClientID varchar(5) collate database_default)
	 SET @ret = @@ERROR		
	 IF @ret <> 0 
		GOTO RollBack_Handle

	INSERT #t (ClientID) SELECT * FROM CAMS.dbo.fnConvertListToTable(@ClientIDs)
	 SET @ret = @@ERROR		
	 IF @ret <> 0 
		GOTO RollBack_Handle

	INSERT tblUserClientDeviceType (UserID,
				ClientID,
				DisplayOrder,
				UpdateTime)
		SELECT @UserID,
			ClientID,
			DisplayOrder,
			GetDate()
		 FROM #t
	

	 SET @ret = @@ERROR		
	 IF @ret <> 0 
		GOTO RollBack_Handle
  END	 

 --Commit
 IF @bInCallerTransaction = 0
	COMMIT TRAN

Exit_Handle:
 RETURN @ret

RollBack_Handle:
 IF @bInCallerTransaction = 0
	ROLLBACK TRAN

 GOTO Exit_Handle



/*


 --example to add FSP
 EXEC spWebAddNewUser 
	@EmailAddress = '300',
	@Name = 'PFS',
	@ClientIDs = NULL,
	@InstallerID = 300

 --example to add client user
 EXEC spWebAddNewUser 
	@EmailAddress = 'test@nab.com.au',
	@Name = 'test user',
	@ClientIDs = 'NAB,HIC',
	@InstallerID = NULL


*/

Go