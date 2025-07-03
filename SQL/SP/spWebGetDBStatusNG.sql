USE CAMS
go

if object_id('spWebGetDBStatusNG') is null
	exec ('create procedure dbo.spWebGetDBStatusNG as return 1')
go


alter Procedure dbo.spWebGetDBStatusNG 
	(
		@UserID int)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 16/09/15 9:07 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetDBStatusNG.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get DB Status
 SET NOCOUNT OFF
 SELECT [Status] = upper(AttrValue)
  FROM tblControl WHERE Attribute = 'IsLiveDB'
/*
exec dbo.spWebGetDBStatusNG 
		@UserID = 210001


*/
GO

Grant EXEC on spWebGetDBStatusNG to eCAMS_Role
Go
