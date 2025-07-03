'<!--$$Revision: 1 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 31/12/10 15:46 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/clsSignature.vb $-->
'<!--$$NoKeywords: $-->

Imports System.Data
Imports System.Data.SqlClient
Imports System.Drawing
Imports System.Drawing.Drawing2D
Imports System.IO
Imports EECommon
Imports System.Text
Imports System
Imports Microsoft.VisualBasic
Namespace eCAMS


'----------------------------------------------------------------
' Namespace: eCAMS
' Class: clsSignature
'
' Description: 
'   Code-behind to extract the signature data and rendering it
'   as a bitmap and put it back to the record set.
'----------------------------------------------------------------
Public Class clsSignature
    ''a returned data set that included decrypted signature bitmap
    Public dsSig As DataSet
    '' a signature object
    Private _signature As EECommon.SignatureData

    ''declare a constant bitmap size here
    Private picSize As New Size(200, 50)

    ''Local variables 
    Private nJobID As Int64 = 0
    Private nUserID As Int64 = 0
    Private m_DataLayer As DataLayer
    '----------------------------------------------------------------
    ' Sub New:
    '   Constructor. Initialize private members.
    '----------------------------------------------------------------
    Public Sub New()
        m_DataLayer = New DataLayer
        dsSig = New DataSet
    End Sub

    '----------------------------------------------------------------
    ' Sub New:
    '   Constructor. Initialize private members with mDataLayer passing
    '   from the parent.
    '----------------------------------------------------------------
    Public Sub New(ByVal mDataLayer As DataLayer)
        m_DataLayer = mDataLayer
        dsSig = New DataSet
    End Sub

    '----------------------------------------------------------------
    ' Function GetSignature():
    '   Extract the original encrypted signature dataset
    '----------------------------------------------------------------
    Public Function GetSignature(ByVal vJobID As Int64) As Boolean
        Dim bRet As Boolean
        Try
            bRet = False
            If m_DataLayer.GetMerchantAcceptance(vJobID) = DataLayerResult.Success Then
                dsSig = m_DataLayer.dsJob
                If m_DataLayer.dsJob.Tables(0).Rows.Count > 0 Then
                    bRet = True
                End If
            End If

        Catch ex As Exception
            Throw ex
        End Try
        Return bRet
    End Function

    '----------------------------------------------------------------
    ' Function DecodeSignature():
    '   Extract the original encrypted signature dataset
    '----------------------------------------------------------------
    Public Function DecodeSignature(ByVal vUserID As Int64, ByVal vJobID As Int64) As Boolean
        Dim bRet As Boolean = False
        Dim oBitmap As Bitmap

        nUserID = vUserID
        nJobID = vJobID
        ''First load the signature data from database
        If GetSignature(vJobID) Then
            Try
                ''Create an empty bitmap
                oBitmap = New Bitmap(picSize.Width, picSize.Height, Imaging.PixelFormat.Format24bppRgb)
                Dim oGrp As Graphics = Graphics.FromImage(oBitmap)
                If Not IsDBNull(dsSig.Tables(0).Rows(0)(1)) Then
                    'Dim ascii As Encoding = Encoding.ASCII

                    'oBytes = ascii.GetBytes(dsSig.Tables(0).Rows(0)(1))

                    _signature = New EECommon.SignatureData(dsSig.Tables(0).Rows(0)(1))

                    'Call a draw signature to draw a function
                    DrawSignature(oGrp)
                    'Now convert a bitmap to byte array
                    dsSig.Tables(0).Rows(0)(1) = BitmapToByte(oBitmap)

                    bRet = True
                End If
            Catch ex As Exception
                Throw ex
            End Try
            'No need to generate a blank signature
            'Else
            'Insert a blank bitmap here
            'GenerateBlankSignature()
        End If

        Return bRet
    End Function

    Private Sub GenerateBlankSignature()
        Dim oBitmap As Bitmap = New Bitmap(picSize.Width, picSize.Height, Imaging.PixelFormat.Format24bppRgb)
        Dim oRow As DataRow

        Try
            oRow = dsSig.Tables(0).NewRow()
            oRow("JobID") = nJobID
            Dim oGrp As Graphics = Graphics.FromImage(oBitmap)
            oGrp.Clear(Color.White)
            oRow("SignatureData") = BitmapToByte(oBitmap)
            dsSig.Tables(0).Rows.Add(oRow)
        Catch ex As Exception
            Throw ex
        End Try
    End Sub
    '----------------------------------------------------------------
    ' Function BitmapToByte():
    '   A helper function that used to convert any bitmap object memory
    '   into array of bytes
    '----------------------------------------------------------------
    Public Function BitmapToByte(ByVal oB As Bitmap) As Byte()
        Dim memStream As MemoryStream = New MemoryStream

        oB.Save(memStream, System.Drawing.Imaging.ImageFormat.Bmp)
        Return memStream.GetBuffer()
    End Function

    '----------------------------------------------------------------
    ' Function GetStream():
    '   Return an array of bytes from bitmap, just for debug
    '----------------------------------------------------------------
    'Public Function GetStream() As MemoryStream
    '    Dim memStream As MemoryStream = New MemoryStream
    '    oBitmap.Save(memStream, System.Drawing.Imaging.ImageFormat.Bmp)
    '   Return memStream
    'End Function

    '----------------------------------------------------------------
    ' Function DrawSignature():
    '   Draw a signature base on decrypted data
    '----------------------------------------------------------------
    Public Sub DrawSignature(ByRef g As Graphics)

        Try
            ' background
            g.Clear(Color.White)

            'border
            'g.DrawRectangle(Pens.Gray, 0, 0, picSize.Width - 1, picSize.Height - 1)

            ' return if don't have a signature
            If (_signature Is Nothing) Or (_signature.Width = 0) Or (_signature.Height = 0) Then
                Return
            End If

            'setup drawing surface
            g.SmoothingMode = SmoothingMode.AntiAlias

            'scale the signature
            Dim matrix As Matrix = New Matrix

            matrix.Scale(Convert.ToDouble(picSize.Width) / Convert.ToDouble(_signature.Width), Convert.ToDouble(picSize.Height) / Convert.ToDouble(_signature.Height))
            g.Transform = matrix

            ' draw each line segment
            For Each line As Point() In _signature.Lines
                If Not (line Is Nothing) And (line.Length > 0) Then
                    'draw lines or curves
                    'If (checkSmooth.Checked) Then
                    g.DrawCurve(Pens.Black, line, 0.5F)
                    'Else
                    'g.DrawLines(Pens.Firebrick, line)
                    'End If
                End If
            Next
        Catch ex As Exception
            Throw (ex)
        End Try
    End Sub

End Class

End Namespace
