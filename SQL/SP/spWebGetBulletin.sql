Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetBulletin]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetBulletin]
GO


Create Procedure dbo.spWebGetBulletin 
	(
		@UserID int,
		@BulletinID int = null,
		@Mode tinyint = 1 --1: for FSP display, 2: for edit
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 16/03/15 11:41 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetBulletin.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: 
	@Mode  --1: for FSP display, 2: for edit
*/
 SET NOCOUNT ON

 --validate user
 --only show the Bulletin for the FSP web users
 if EXISTS(SELECT 1 FROM tblUser WHERE UserID = @UserID AND IsActive = 1 and ISNULL(InstallerID,0) <>0)
  begin
    if @Mode = 1
     begin --for FSP display, need to check the view log - show only non-viewed items
		select * 
			from CAMS.dbo.tblWebBulletin
			where IsActive = 1
				and BulletinID not in (select BulletinID from CAMS.dbo.tblWebBulletinViewLog where UserID = @UserID and ActionTakenID in (1,2)) --OK or Accepted
				
     end --@Mode = 1
    else if @Mode = 2
     begin --edit, need to check if user is admin in tblUserModule with ModuleID = 4
		select * 
			from CAMS.dbo.tblWebBulletin
			where IsActive = 1
				and ISNULL(@BulletinID , BulletinID) = BulletinID
				and exists(select 1 from tblUserModule where ModuleID = 4 and UserID = @UserID)
     end --@Mode = 2
	else
     begin --Bulletin Viwer @Mode = 3
		select * 
			from CAMS.dbo.tblWebBulletin
			where IsActive = 1
				and ISNULL(@BulletinID , BulletinID) = BulletinID
     end --@Mode = 3
 end --active FSP user
else
 begin
 	select * 
		from CAMS.dbo.tblWebBulletin
		where 1 = 2

 end
/*

exec spWebGetBulletin @UserID=199649,@BulletinID=null,@Mode=1

exec spWebGetBulletin @UserID=199649,@BulletinID=1,@Mode=2


*/
Go

Grant EXEC on spWebGetBulletin to eCAMS_Role
Go





