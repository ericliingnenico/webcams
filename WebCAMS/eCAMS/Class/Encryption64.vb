#Region "vss version"
''<!--$$Revision: 2 $-->
''<!--$$Author: Bo $-->
''<!--$$Date: 8/03/13 10:01 $-->
''<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/Encryption64.vb $-->
''<!--$$NoKeywords: $-->
#End Region

Imports System
Imports System.IO
Imports System.Xml
Imports System.Text
Imports System.Security.Cryptography

Public Class Encryption64
    Private key() As Byte = {}
    Private IV() As Byte = {&H12, &H34, &H56, &H78, &H90, &HAB, &HCD, &HEF}
''    Private IV() As Byte = {&H94, &H23, &H17, &H20, &HAB, &HAB, &HCD, &HEF}

    Public Function Decrypt(ByVal stringToDecrypt As String, ByVal sEncryptionKey As String) As String
        Dim inputByteArray(stringToDecrypt.Length) As Byte
        Try
            key = System.Text.Encoding.UTF8.GetBytes(sEncryptionKey.Substring(0, 8))
            Dim des As New DESCryptoServiceProvider()
            inputByteArray = Convert.FromBase64String(stringToDecrypt)
            Dim ms As New MemoryStream()
            Dim cs As New CryptoStream(ms, des.CreateDecryptor(key, IV), CryptoStreamMode.Write)
            cs.Write(inputByteArray, 0, inputByteArray.Length)
            cs.FlushFinalBlock()
            Dim encoding As System.Text.Encoding = System.Text.Encoding.UTF8
            Return encoding.GetString(ms.ToArray())
        Catch e As Exception
            Return e.Message
        End Try
    End Function

    Public Function Encrypt(ByVal stringToEncrypt As String, ByVal sEncryptionKey As String) As String
        Try
            key = System.Text.Encoding.UTF8.GetBytes(sEncryptionKey.Substring(0, 8))
            Dim des As New DESCryptoServiceProvider()
            Dim inputByteArray() As Byte = Encoding.UTF8.GetBytes(stringToEncrypt)
            Dim ms As New MemoryStream()
            Dim cs As New CryptoStream(ms, des.CreateEncryptor(key, IV), CryptoStreamMode.Write)
            cs.Write(inputByteArray, 0, inputByteArray.Length)
            cs.FlushFinalBlock()
            Return Convert.ToBase64String(ms.ToArray())
        Catch e As Exception
            Return e.Message
        End Try
    End Function


    Public Function Decrypt(ByVal byteToDecrypt As byte(), ByVal sEncryptionKey As String) As byte()
        Try
            key = System.Text.Encoding.UTF8.GetBytes(sEncryptionKey.Substring(0, 8))
            Dim des As New DESCryptoServiceProvider()
            Dim ms As New MemoryStream()
            Dim cs As New CryptoStream(ms, des.CreateDecryptor(key, IV), CryptoStreamMode.Write)
            cs.Write(byteToDecrypt, 0, byteToDecrypt.Length)
            cs.FlushFinalBlock()
            Dim encoding As System.Text.Encoding = System.Text.Encoding.UTF8
            Return ms.ToArray()
        Catch e As Exception
            ' Return e.Message
        End Try

        Return Nothing
    End Function

    Public Function Encrypt(ByVal byteToEncrypt As byte(), ByVal sEncryptionKey As String) As byte()
        Try
            key = System.Text.Encoding.UTF8.GetBytes(sEncryptionKey.Substring(0, 8))
            Dim des As New DESCryptoServiceProvider()
            Dim ms As New MemoryStream()
            Dim cs As New CryptoStream(ms, des.CreateEncryptor(key, IV), CryptoStreamMode.Write)
            cs.Write(byteToEncrypt, 0, byteToEncrypt.Length)
            cs.FlushFinalBlock()
            Return ms.ToArray()
        Catch e As Exception
            'Return e.Message
        End Try
        Return Nothing
    End Function

End Class
Public Class EncryptionRijndael
    Public Shared Function EncryptString(message As String) As String
	    Dim Key As Byte() '= ASCIIEncoding.UTF8.GetBytes(KeyString)
	    Dim IV As Byte() '= ASCIIEncoding.UTF8.GetBytes(IVString)

	    Dim encrypted As String = Nothing
	    Dim rj As New RijndaelManaged()

        'Dim md5Hash as MD5 = MD5.Create()
        
        'Key =  md5Hash.ComputeHash(Encoding.UTF32.GetBytes(KeyString))
        'IV = md5Hash.ComputeHash(Encoding.UTF32.GetBytes(IVString))

        ''below are MD5 hash from php of Key=K3yc0rpV1d30L1br4ry789
        ''IV=C5F22C962979C1C2
        ''somehow .net md5 computehas return ony 16 bytes of key and Rijndae require 32 bytes

        Key = {&H35,&H66,&H62,&H34,&H31,&H37,&H39,&H30,&H37,&H64,&H65,&H37,&H66,&H35,&H31,&H62,&H35,&H38,&H65,&H63,&H62,&H66,&H62,&H35,&H61,&H38,&H34,&H64,&H63,&H65,&H30,&H65}
        IV = {&H64,&H36,&H65,&H64,&H38,&H31,&H34,&H39,&H30,&H36,&H34,&H65,&H36,&H36,&H33,&H31,&H65,&H33,&H31,&H33,&H64,&H62,&H36,&H66,&H34,&H61,&H39,&H30,&H32,&H34,&H32,&H39}

        rj.BlockSize = 256
	    rj.Key = key
	    rj.IV = iv
	    rj.Mode = CipherMode.CBC

	    Try
		    Dim ms As New MemoryStream()

		    Using cs As New CryptoStream(ms, rj.CreateEncryptor(Key, IV), CryptoStreamMode.Write)
			    Using sw As New StreamWriter(cs)
				    sw.Write(message)
				    sw.Close()
			    End Using
			    cs.Close()
		    End Using
		    Dim encoded As Byte() = ms.ToArray()
		    encrypted = Convert.ToBase64String(encoded)

		    ms.Close()
	    Catch e As CryptographicException
		    Console.WriteLine("A Cryptographic error occurred: {0}", e.Message)
		    Return Nothing
	    Catch e As UnauthorizedAccessException
		    Console.WriteLine("A file error occurred: {0}", e.Message)
		    Return Nothing
	    Catch e As Exception
		    Console.WriteLine("An error occurred: {0}", e.Message)
	    Finally
		    rj.Clear()
	    End Try

	    Return encrypted
    End Function

End Class
