Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetAdditionalServiceType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetAdditionalServiceType]
GO


Create Procedure dbo.spWebGetAdditionalServiceType 
	(
		@UserID int,
		@ClientID varchar(3)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 1/02/07 4:09p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetAdditionalServiceType.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON

 --validate user
 IF EXISTS(SELECT 1 FROM tblUser WHERE UserID = @UserID AND IsActive = 1)
  BEGIN
 	EXEC Cams.dbo.spGetAdditionalServiceType  @ClientID = @ClientID
  END
/*
spWebGetAdditionalServiceType 199623, 'wbc'

*/
Go

Grant EXEC on spWebGetAdditionalServiceType to eCAMS_Role
Go

