USE CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fnGetSurveyCombinedText]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[fnGetSurveyCombinedText]
GO

CREATE FUNCTION dbo.fnGetSurveyCombinedText(
	@ClientID varchar(3),
	@JobType varchar(20),
	@Delimiter varchar(10)
) RETURNS varchar(max)
--'<!--$$Revision: 2 $-->
--'<!--$$Author: Bo $-->
--'<!--$$Date: 18/02/11 17:07 $-->
--'<!--$$Logfile: /eCAMSSource/SQL/Function/fnGetSurveyCombinedText.sql $-->
--'<!--$$NoKeywords: $-->
/*
 Purpose: return survey text consumed by JobSheet
*/
AS
BEGIN
declare @ret varchar(max)
select @ret = (SELECT q.[Text] + case when QuestionTypeID = 1 then ' Yes    No' 
							 when QuestionTypeID = 2 then ': ' + q.Limitations
							 when QuestionTypeID = 3 then ':_________'
							 else '' end
							 +  @Delimiter
							  FROM tblSurveyQuestionList l JOIN tblSurvey s ON l.SurveyID = s.SurveyID
											JOIN tblSurveyQuestion q ON l.QuestionID = q.QuestionID
							  WHERE s.IsActive = 1
								AND q.IsActive = 1
								and q.QuestionTypeID in (1 ,2,3)
								--and q.[Text] like 'Technician%'
								and s.JobType = @JobType
								and s.Clientid = @ClientID
							  order by l.DisplayOrder
							  for xml path('') )
 return isnull(@ret, '')
END

/*
 select dbo.fnGetSurveyCombinedText ('cba','install', '[br]')
 select dbo.fnGetSurveyCombinedText ('ctx','swap', '[br]')
 select dbo.fnGetSurveyCombinedText ('cba','install', char(10))
 

*/

Go

