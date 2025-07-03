Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPJobDS]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetFSPJobDS]
GO


Create Procedure dbo.spWebGetFSPJobDS 
	(
		@UserID int
	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/04/03 9:27 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPJobDS.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC dbo.spWebGetFSPJob @UserID = @UserID, @JobID = NULL

/*
spWebGetFSPJobDS 3

*/

GO

Grant EXEC on spWebGetFSPJobDS to eCAMS_Role
Go


