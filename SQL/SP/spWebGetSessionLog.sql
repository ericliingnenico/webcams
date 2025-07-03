Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetSessionLog]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetSessionLog]
GO


Create Procedure dbo.spWebGetSessionLog 
	(
		@SessionID varchar(50)
	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 31/01/07 4:08p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetSessionLog.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON

 SELECT TOP 1 *,
	dbo.fnGetXMLValue(SessionData, 'Skin') as Skin
	FROM tblSessionLog WITH (NOLOCK)
	WHERE SessionID = @SessionID

/*
spWebGetSessionLog 199635


*/
Go

Grant EXEC on spWebGetSessionLog to eCAMS_Role
Go

