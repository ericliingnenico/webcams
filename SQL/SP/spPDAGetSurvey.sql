
Use CAMS
Go

Alter proc spPDAGetSurvey 
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 30/10/07 12:59p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetSurvey.sql $-->
--<!--$$NoKeywords: $-->
as
--retrieve Survey related data
 
 SET NOCOUNT ON

 --get Survey version
 SELECT A = AttrValue
   FROM CAMS.dbo.tblControl
  WHERE Attribute = 'SurveyVersion'

 --tblSurvey
 SELECT 
	A = SurveyID,
	B = ClientID,
	C = JobType,
	D = SurveyName,
	E = IsSurveyMandatory,
	F = IsSignatureMandatory
   FROM tblSurvey 
  WHERE IsActive = 1


 --tblQuestion
 SELECT 
	A = QuestionID,
	B = QuestionTypeID,
	C = Text,
	D = Limitations
   FROM tblSurveyQuestion
  WHERE IsActive = 1

 --tblSurveyQuestionList
 SELECT 
	A = l.SurveyID,
	B = l.QuestionID,
	C = l.DisplayOrder
  FROM tblSurveyQuestionList l JOIN tblSurvey s ON l.SurveyID = s.SurveyID
				JOIN tblSurveyQuestion q ON l.QuestionID = q.QuestionID
  WHERE s.IsActive = 1
	AND q.IsActive = 1

go
Grant EXEC on spPDAGetSurvey to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spPDAGetSurvey 
 AS
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetSurvey
/*
spPDAGetSurvey
*/
Go

Grant EXEC on spPDAGetSurvey to eCAMS_Role
Go
