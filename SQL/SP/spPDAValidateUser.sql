Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spPDAValidateUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spPDAValidateUser]
GO


Create Procedure dbo.spPDAValidateUser 
	(
		@EmailAddress 	varchar(100),
		@Password 	binary(16)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 11/12/03 10:13 $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAValidateUser.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT OFF
 SELECT UserID  FROM tblUser WHERE EmailAddress = @EmailAddress 
					AND [Password] = @Password
 					AND IsActive = 1
					AND InstallerID IS NOT NULL

					

/*
exec spPDAValidateUser 'bo', 'bo'
SELECT * FROM tblUser 
*/
GO


Grant EXEC on spPDAValidateUser to eCAMS_Role
Go

