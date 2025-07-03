Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutBulletin]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebPutBulletin]
GO


Create Procedure dbo.spWebPutBulletin 
	(
		@UserID int,
		@BulletinID int,
		@Title varchar(1000),
		@Body varchar(max),
		@ButtonTypeID tinyint = 1 ,  --1: OK button, 2: Accept button
		@ActionOnDeclined tinyint = 0, --0: No Action, 1: log off
		@TargetTypeID  tinyint = 1 --1: FSP ALL, 2: FSP Selective
	)
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 3/03/15 14:15 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutBulletin.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON

 --validate Body to prevent XSS (Cross-Site Scripting)
 if @Body like '%<link%href%'
		or @Body like '%<embed%'
		or @Body like '%<object%'
		or @Body like '%<link%href%'
		or @Body like '%<img%stc%'
		or @Body like '%javascript%'
		or @Body like '%<@Body%onload%'
		or @Body like '%<script%'
		or @Body like '%<a%href%'
		or @Body like '%<form%'
		or @Body like '%<input%'
		or @Body like '%<iframe%src=%'
 begin
	raiserror ('@Body contains potential XSS (Cross-Site Scripting) HTML element', 16, 1)
	return -1 
 end



 --validate user
 IF EXISTS(SELECT 1 FROM tblUser WHERE UserID = @UserID AND IsActive = 1 and isnumeric(InstallerID) = 1)
  BEGIN
	if exists(select 1 from CAMS.dbo.tblWebBulletin where BulletinID = @BulletinID)
	 begin
		update CAMS.dbo.tblWebBulletin
		 set Title = @Title,
			Body = @Body,
			ButtonTypeID = @ButtonTypeID,
			ActionOnDeclined = @ActionOnDeclined,
			TargetTypeID = @TargetTypeID,
			UpdatedDateTime = GETDATE()
		 where BulletinID = @BulletinID
	 end
	else
	 begin
		Insert CAMS.dbo.tblWebBulletin(
			Title, 
			Body,
			ButtonTypeID,
			ActionOnDeclined,
			TargetTypeID,
			IsActive,
			UpdatedDateTime)
		values (@Title, 
			@Body,
			@ButtonTypeID,
			@ActionOnDeclined,
			@TargetTypeID,
			1,
			GETDATE())

	 end
	 
	 select @@error
	
 END
/*

spWebPutBulletin 199510

select * from CAMS.dbo.tblWebBulletin


*/
Go

Grant EXEC on spWebPutBulletin to eCAMS_Role
Go





