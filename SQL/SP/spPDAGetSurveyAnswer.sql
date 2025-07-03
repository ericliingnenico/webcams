Use CAMS
Go

Alter PROCEDURE dbo.spPDAGetSurveyAnswer (
	@JobID		bigint
)
--<!--$$Revision: 7 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 8/02/13 13:57 $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetSurveyAnswer.sql $-->
--<!--$$NoKeywords: $-->
AS
--Create Sequence Number
/*
27 FEB 2012
Added QuestionTypeID to one of the returned fields
For Signature Viewer
*/
SET NOCOUNT ON

SELECT  s.SurveyName,
	s.JobType,
	QuestionText = sq.[Text],
	sa.AnswerID,
	sa.JobID,
	sa.SurveyID,
	sa.QuestionID,
	[Text]=case when sq.IsEncrypted = 1 then dbo.fnDecryptData(sa.TextExt) else sa.[Text] end,
	sq.QuestionTypeID,
	DisplayOrder = ROW_NUMBER() over (order by sa.AnswerID)
  FROM tblSurveyAnswer sa
  JOIN tblSurvey s ON (s.SurveyID = sa.SurveyID)
  JOIN tblSurveyQuestion sq ON (sq.QuestionID = sa.QuestionID)
			    AND (sq.IsPrivate = 0)
  WHERE sa.JobID = @JobID
  ORDER BY sa.AnswerID
/*
-- =============================================
-- example to execute the store procedure
-- =============================================
EXECUTE spPDAGetSurveyAnswer 1588999
*/
GO


Use webCAMS
go

if exists(Select 1 from sysobjects where name = 'spPDAGetSurveyAnswer')
	drop proc spPDAGetSurveyAnswer
go

create proc  dbo.spPDAGetSurveyAnswer (
	@JobID		bigint
)
--proxy to CAMS.dbo.spPDAGetSurveyAnswer
AS
SET NOCOUNT ON
EXEC CAMS.dbo.spPDAGetSurveyAnswer @JobID = @JobID
Go

GRANT EXEC on spPDAGetSurveyAnswer to eCAMS_Role
Go
