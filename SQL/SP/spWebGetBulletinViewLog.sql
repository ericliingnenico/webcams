Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetBulletinViewLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetBulletinViewLog]
GO


Create Procedure dbo.spWebGetBulletinViewLog 
	(
		@UserID int,
		@From tinyint
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/06/12 13:57 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetBulletinViewLog.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Put Bulletin View Log
 ---@From : 1 - From Web, 2 - From Mobile Device
*/
 SET NOCOUNT ON
 if @From = 1
  begin
	  select 
			'<A HREF="#" onclick="javascript:popupwindow(''../Member/BulletinView.aspx?BNO=' + CAST(l.BulletinID as varchar) + ''')">' + b.Title + '</A>' as Title,
			t.ActionTaken,
			l.LoggedDateTime
	   from CAMS.dbo.tblWebBulletinViewLog l join CAMS.dbo.tblWebBulletin b on l.BulletinID = b.BulletinID
											left outer join CAMS.dbo.tblWebBulletinActionTaken t on l.ActionTakenID = t.ActionTakenID
		and DATEDIFF(day, b.UpdatedDateTime, GETDATE())<=90
	   where l.UserID = @UserID
	   order by l.LogID desc
  end
 if @From = 2
  begin
	  select 
			b.*,
			t.ActionTaken,
			l.LoggedDateTime
	   from CAMS.dbo.tblWebBulletinViewLog l join CAMS.dbo.tblWebBulletin b on l.BulletinID = b.BulletinID
											left outer join CAMS.dbo.tblWebBulletinActionTaken t on l.ActionTakenID = t.ActionTakenID
	   where l.UserID = @UserID
		and DATEDIFF(day, b.UpdatedDateTime, GETDATE())<=30
	   order by l.LogID desc
  end
	 
  select @@error
/*

spWebGetBulletinViewLog 199649, 2

select * from CAMS.dbo.tblWebBulletinViewLog


*/
Go

Grant EXEC on spWebGetBulletinViewLog to eCAMS_Role
Go





