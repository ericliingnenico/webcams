Imports System

Namespace eCAMS

    NotInheritable Class CommonUtil
        ''' <summary>
        ''' Prevent instantiation.
        ''' </summary>
        Private Sub New()

        End Sub

        Public Shared Function SortJobNote(notes As String, ascOrder As Boolean) As String
            Dim sortedNotes As String = ""

            If ascOrder = False Then

                Dim splitString As String = CChar(vbCrLf)
                Dim listStr As New List(Of String)
                Dim passage As String = ""
                Dim dateLine As Boolean = False
                Dim paragraph As String = ""

                'ContactResolution: Left Voice Message(KATE VAS (KV1375) 17/03/2022 16:33:40)  =>  match  17/03/2022 16:33:38
                'Dim regExStr As String = "\s([0-3][0-9])(\/)([0-1][0-9])(\/)([0-9]{4})\s([0-1][0-9]|[2][0-3]):([0-5][0-9]):([0-5][0-9])"


                'ContactResolution: Left Voice Message(KATE VAS (KV1375) 17/03/2022 16:33:40)  =>  match (KATE VAS (KV1375) 17/03/2022 16:33:40)
                Dim regExStr As String = "\(.*\s([0-3][0-9])(\/)([0-1][0-9])(\/)([0-9]{4})\s([0-1][0-9]|[2][0-3]):([0-5][0-9]):([0-5][0-9]).{0,4}\)"

                Dim regEx As Regex = New Regex(regExStr)
                Dim regExMatch As Match

                Try

                    Dim addedToList As Boolean = False
                    For Each strLine As String In notes.Split(New String() {splitString}, StringSplitOptions.None)
                        regExMatch = regEx.Match(strLine)

                        If regExMatch.Success Then
                            passage += strLine
                            listStr.Add(passage)
                            passage = ""
                        Else
                            passage += strLine
                        End If
                    Next

                    If (Not String.IsNullOrEmpty(passage)) Then
                        listStr.Add(passage)
                    End If

                    listStr.Reverse()
                    sortedNotes = String.Join(splitString, listStr)
                Catch
                    sortedNotes = notes
                End Try

            Else
                sortedNotes = notes
            End If

            Return sortedNotes
        End Function
    End Class

End Namespace