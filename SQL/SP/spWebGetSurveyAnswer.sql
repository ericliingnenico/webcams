Use CAMS
Go
if exists(Select 1 from sysobjects where name = 'spWebGetSurveyAnswer')
	drop proc spWebGetSurveyAnswer
go

create PROCEDURE dbo.spWebGetSurveyAnswer (
	@JobID		bigint
)
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 6/11/10 8:01 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetSurveyAnswer.sql $-->
--<!--$$NoKeywords: $-->
AS
--Create Sequence Number

SET NOCOUNT ON

SELECT  s.SurveyName,
	s.JobType,
	QuestionText = sq.[Text],
	sa.*
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
EXECUTE spWebGetSurveyAnswer 199512,1206914

*/
GO

grant exec on dbo.spWebGetSurveyAnswer to CAMSApp, eCAMS_Role
go


Use webCAMS
go

if exists(Select 1 from sysobjects where name = 'spWebGetSurveyAnswer')
	drop proc spWebGetSurveyAnswer
go

create proc  dbo.spWebGetSurveyAnswer (
	@UserID int,
	@JobID		bigint
)
--proxy to CAMS.dbo.spWebGetSurveyAnswer
AS
set nocount on;
if exists(select 1 from tblUser where UserID = @UserID	and IsActive = 1)
	exec Cams.dbo.spWebGetSurveyAnswer @JobID = @JobID
Go


GRANT EXEC on spWebGetSurveyAnswer to eCAMS_Role
Go
