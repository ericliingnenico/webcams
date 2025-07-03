use CAMS
Go

if exists(select 1 from sysobjects where name = 'spWebGetJobFilterStatus' and type = 'p')
   drop proc spWebGetJobFilterStatus
go

CREATE PROC spWebGetJobFilterStatus 
(
 @UserID int
)
AS

--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 30/07/15 9:44 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetJobFilterStatus.sql $-->
--<!--$$NoKeywords: $-->

 SET NOCOUNT ON
 
 --return IMS Job 
 SELECT Distinct FilterStatus, FilterStatusID
 FROM vwWebJobFilterStatus
 WHERE IsSwap = 0
 ORDER BY FilterStatus

 --Swap
 SELECT Distinct FilterStatus, FilterStatusID
 FROM vwWebJobFilterStatus
 WHERE IsSwap = 1
 ORDER BY FilterStatus

 --return all 
 SELECT *
 FROM vwWebJobFilterStatus
 ORDER BY IsSwap,FilterStatusID, StatusID


/*
spWebGetJobFilterStatus 1
*/

Go

Grant exec on spWebGetJobFilterStatus to eCAMS_Role
go



USE WEBCAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetJobFilterStatus' and type = 'p')
   drop proc spWebGetJobFilterStatus
go

CREATE PROC spWebGetJobFilterStatus 
(
 @UserID int
)
AS

 SET NOCOUNT ON
 

 EXEC CAMS.dbo.spWebGetJobFilterStatus @UserID = @UserID
/*
spWebGetJobFilterStatus 1
*/

Go

GRANT EXEC ON spWebGetJobFilterStatus TO eCAMS_Role
go

