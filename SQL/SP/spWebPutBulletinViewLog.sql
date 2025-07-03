Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutBulletinViewLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebPutBulletinViewLog]
GO


Create Procedure dbo.spWebPutBulletinViewLog 
	(
		@UserID int,
		@BulletinID int,
		@ActionTakenID tinyint --1: OK, 2: Accepted, 3: declined
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 10/05/10 10:31 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutBulletinViewLog.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Put Bulletin View Log
*/
 SET NOCOUNT ON

  insert CAMS.dbo.tblWebBulletinViewLog(UserID,BulletinID, ActionTakenID, LoggedDateTime)
	values(@UserID, @BulletinID, @ActionTakenID, GETDATE())
	 
  select @@error
/*

spWebPutBulletinViewLog 199510

select * from CAMS.dbo.tblWebBulletinViewLog


*/
Go

Grant EXEC on spWebPutBulletinViewLog to eCAMS_Role
Go





