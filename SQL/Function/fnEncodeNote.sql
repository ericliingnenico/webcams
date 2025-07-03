USE CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnEncodeNote]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnEncodeNote]
GO

CREATE FUNCTION dbo.fnEncodeNote(
	@Type tinyint,
	@String varchar(1000)
) RETURNS varchar(1200)
--'<!--$$Revision: 6 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 29/12/10 17:24 $-->
--'<!--$$Logfile: /eCAMSSource/SQL/Function/fnEncodeNote.sql $-->
--'<!--$$NoKeywords: $-->
/*
 Purpose: Encode note based on type:
	Type=1: JobNote
	Type=2: SpecialInstruction
	Type=3: TradingHours
	Type=4: SwapComponent
	Type=5: CAIC
 This function is used to encode jobnote/specialinstruction which entered by web user via webCAMS.
 webCAMS will append the encoded note to jobnote.
 wevCAMS CallViewer/JobViewer will decode the note and display back original JobNote/SpecialInstruction
*/
AS
BEGIN
 RETURN CASE WHEN @Type = 1 THEN '<WebJobNote>' 
			WHEN @Type = 2 THEN '<WebSpecialInstruction>' 
			WHEN @Type = 3 THEN '<TradingHour>' 
			WHEN @Type = 4 THEN '<SwapComponent>'
			WHEN @Type = 5 THEN '<CAIC>'
			ELSE '' END
		 + @String +
		CASE WHEN @Type = 1 THEN '</WebJobNote>' 
			WHEN @Type = 2 THEN '</WebSpecialInstruction>'
			WHEN @Type = 3 THEN '</TradingHour>'
			WHEN @Type = 4 THEN '</SwapComponent>'
			WHEN @Type = 5 THEN '</CAIC>'
			ELSE '' END
END

/*
 select dbo.fnEncodeNote (1, 'dwed   21321453543<>#@$@# t')
 select dbo.fnEncodeNote (2, 'dwed   21321453543<>#@$@# t')

*/

Go

