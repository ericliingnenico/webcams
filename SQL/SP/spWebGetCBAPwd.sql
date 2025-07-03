
Use WebCAMS
Go
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spWebGetCBAPwd]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spWebGetCBAPwd]
GO

Create Procedure dbo.spWebGetCBAPwd 
	(
		@UserID int,
		@TargetDate datetime,
		@Serial varchar(50),
		@SecretCode varchar(50)
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/11/12 10:44 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetCBAPwd.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 if EXISTS(SELECT 1 FROM tblUser WHERE UserID = @UserID AND IsActive = 1 and ISNULL(InstallerID,0) <>0)
  begin
	select Code ='xxx'
	--EXEC Cams.dbo.spGetCBAPwd @TargetDate = @TargetDate,
	--								@Serial = @Serial,
	--								@SecretCode = @SecretCode
  end
 Else
  begin
	select Code ='xxx'
  end
/*

spWebGetCBAPwd @UserID = 199516,
		@TargetDate = '12/12/12',
		@Serial = '12345678',
		@SecretCode = 'not an ordinary c0de'

*/
Go

Grant EXEC on spWebGetCBAPwd to eCAMS_Role
Go
