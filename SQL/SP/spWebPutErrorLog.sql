Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutErrorLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebPutErrorLog]
GO


CREATE PROC dbo.spWebPutErrorLog (
	@UserID int,
	@Msg varchar(8000)
	)
--<!--$$Revision: 4 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/04/03 9:27 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutErrorLog.sql $-->
--<!--$$NoKeywords: $-->
AS
/*
 Purpose: Insert Error message into error log 
*/
 SET NOCOUNT ON

 INSERT tblErrorLog 
		(Msg,
		UserID,
		LogDate)
		VALUES 
		(@Msg, 
		@UserID, 
		GetDate())
 RETURN @@ERROR

/*
EXEC spWebPutErrorLog  1, 'aa'
select * from tblErrorLog
*/
GO



Grant EXEC on spWebPutErrorLog to eCAMS_Role
Go
