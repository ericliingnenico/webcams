Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetUserModuleList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetUserModuleList]
GO



Create Procedure dbo.spWebGetUserModuleList 
	(
		@UserID		int
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 21/03/05 4:49p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetUserModuleList.sql $-->
--<!--$$NoKeywords: $-->
 SELECT * FROM tblUserModule um JOIN tblModule m ON um.ModuleID = m.ModuleID
	WHERE um.UserID = @UserID
		AND m.IsActive = 1
/*

exec spWebGetUserModuleList 199675

*/

GO


Grant EXEC on spWebGetUserModuleList to eCAMS_Role
Go
