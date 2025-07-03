USE Master
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[fnIsValidEmail]') AND xtype IN (N'FN', N'IF', N'TF'))
	DROP FUNCTION [dbo].[fnIsValidEmail]
GO

CREATE FUNCTION dbo.fnIsValidEmail
	(
		@EmailAddress varchar(500)
	) RETURNS bit
--'<!--$$Revision: 3 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 22/04/13 12:01 $-->
--'<!--$$Logfile: /SQL/Master/fnIsValidEmail.sql $-->
--'<!--$$NoKeywords: $-->

AS

BEGIN
 --Purpose: verify if the email address is valid one
 DECLARE @IsOK bit
 SET @IsOK = 0

 IF @EmailAddress LIKE '_%@__%.__%'
     SET @IsOK = 1   -- Valid

 RETURN @IsOK



END
/*
	SELECT dbo.fnIsValidEmail('bl100@eftpos.com.au;chester@gmail.com')
*/
GO


Grant EXEC on dbo.fnIsValidEmail to public
GO

