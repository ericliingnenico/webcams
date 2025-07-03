USE CAMS
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[fnCanUpdateJobInfo]') AND xtype IN (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[fnCanUpdateJobInfo]
GO

CREATE FUNCTION dbo.fnCanUpdateJobInfo
	(
		@ClientID varchar(3),
		@JobTypeID tinyint
	) RETURNS bit
--'<!--$$Revision: 1 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 16/04/08 8:31a $-->
--'<!--$$Logfile: /eCAMSSource/SQL/Function/fnCanUpdateJobInfo.sql $-->
--'<!--$$NoKeywords: $-->

AS

BEGIN
 --Purpose: Check if there is any record in tblWebClientUpdateInfoFieldList
 Return CASE WHEN EXISTS(select 1 from tblWebClientUpdateInfoFieldList WITH (NOLOCK) WHERE ClientID = @ClientID AND JobTypeID IN (@jobTypeID, 0)) THEN 1 ELSE 0 END

END
/*
	SELECT dbo.fnCanUpdateJobInfo('NAB',3)
*/
GO


Grant EXEC on dbo.fnCanUpdateJobInfo to eCAMS_Role, CAMSApp
GO

