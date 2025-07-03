Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutSessionLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebPutSessionLog]
GO


CREATE PROC dbo.spWebPutSessionLog (
	@SessionID varchar(50),
	@SessionData varchar(1000))
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 31/01/07 4:05p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutSessionLog.sql $-->
--<!--$$NoKeywords: $-->
AS
/*
 Purpose: Log session data
*/
 SET NOCOUNT ON
 --update it if exists
 UPDATE tblSessionLog
   SET SessionData = @SessionData,
	LogDate = GetDate()
 WHERE SessionID = @SessionID

 --otherwise add
 IF @@ROWCOUNT = 0
 	INSERT tblSessionLog 
		(SessionID,
		SessionData,
		LogDate)
		VALUES 
		(@SessionID, 
		@SessionData, 
		GetDate())

 RETURN @@ERROR

/*
EXEC spWebPutSessionLog 
select * from tblActionLog
*/
GO


Grant EXEC on spWebPutSessionLog to eCAMS_Role
Go


