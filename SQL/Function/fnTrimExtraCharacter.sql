USE CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnTrimExtraCharacter]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnTrimExtraCharacter]
GO

CREATE FUNCTION fnTrimExtraCharacter(
--'<!--$$Revision: 1 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 22/04/04 1:40p $-->
--'<!--$$Logfile: /pCAMSSource/SQL/Function/fnTrimExtraCharacter.sql $-->
--'<!--$$NoKeywords: $-->
	@String varchar(255)
) RETURNS varchar(255)
/*
 Purpose: Trim Extra Character, such as ###, ***. The string length is 255
*/
AS
BEGIN
 RETURN REPLACE(REPLACE(@String, '###', ''), '***', '')
END

/*
 select dbo.fnTrimExtraCharacter ('##########this is ********** a test')




*/