Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutActionLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebPutActionLog]
GO


CREATE PROC dbo.spWebPutActionLog (
	@ActionTypeID smallint,
	@ActionData varchar(6000),
	@UserID int)
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/10/03 10:14 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutActionLog.sql $-->
--<!--$$NoKeywords: $-->
AS
/*
 Purpose: Add action data to tblActionLog
*/
 SET NOCOUNT ON
 INSERT tblActionLog 
		(ActionTypeID,
		ActionData,
		UserID,
		LogDate)
		VALUES 
		(@ActionTypeID, 
		@ActionData, 
		@UserID, 
		GetDate())

 RETURN @@ERROR

/*
EXEC spWebPutActionLog 
select * from tblActionLog
*/
GO


Grant EXEC on spWebPutActionLog to eCAMS_Role
Go


