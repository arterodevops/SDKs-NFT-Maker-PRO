#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} NFTMakerPro
    Classe que representa o SDK para integração com a plataforma NFT Maker PRO
    @author DS2U (SDA)
    @since 27/05/2022
    @version 1.0.0
    /*/
Class NFTMakerPro

    Data projectId As String
    Data endPoint  As String
    Data apiKey    As String
    Data fileCfg   As String
    
    Method New( cfileCfg, cProjectId )
    
    Method LoadEnv()
    Method UploadNFT( cFile, aSubFiles )
    Method GetNftDetails( cNftName )
    Method GetNftById( cNftId )
    Method UpMetaData( oNFT )

EndClass

/*/{Protheus.doc} New
    Metodo para instanciação da classe
    @author DS2U (SDA)
    @since 27/05/2022
    @version 1.0.0
    @param cfileCfg, Char, Caminho absoluto do arquivo .env
    @param cProjectId, Char, ID do Projeto
    @return SELF, object, Objeto instanciado da classe NFTMakerPro
    /*/
Method New( cfileCfg, cProjectId ) CLASS NFTMakerPro

    Default cfileCfg   := ""
    Default cProjectId := ""

    ::fileCfg   := cfileCfg
    ::projectId := cProjectId
    ::loadEnv()

Return SELF

/*/{Protheus.doc} LoadEnv
    Funcao para carregar o arquivo de configuração .env, que contem as informações de acesso a plataforma NFT Maker PRO
    @type  Static Function
    @author DS2U (SDA)
    @since 27/05/2022
    @version 1.0.0
    @return SELF, object, Objeto instanciado da classe NFTMakerPro
/*/
Method LoadEnv() CLASS NFTMakerPro

Local aParams As Array
Local aLines  As Array
Local cEnv    As String
Local cTexto  As String
Local nlx
Local nPos
Local cMsgErro := ""
Local nHandle As Numeric

If ( File( ::fileCfg ) )

    nHandle := fOpen( ::fileCfg )

    If nHandle == -1
        MsgStop('Erro de abertura : FERROR '+str(ferror(),4))
    Else

        cTexto  := ""
        cEnv    := ""
        aParams := {}
        fRead( nHandle, cTexto, 80 )
        While !Empty( cTexto )
            cEnv += cTexto
            fRead( nHandle, cTexto, 80 )            
        EndDo

        aLines := separa(cEnv, CRLF)

        For nlx := 1 To Len( aLines )
            AADD( aParams, separa(aLines[nlx], "=") )
        Next nlx

        If ( ( nPos := aScan( aParams, {|x| Upper( AllTrim( x[1] ) ) == "WS_ENDPOINT" } ) ) > 0 )
            ::endPoint := aParams[nPos][2]
        Else
            cMsgErro += "WS_ENDPOINT não encontrado no arquivo .env" + CRLF
        EndIf

        If ( ( nPos := aScan( aParams, {|x| Upper( AllTrim( x[1] ) ) == "WS_API_KEY" } ) ) > 0 )
            ::apiKey := aParams[nPos][2]
        Else
            cMsgErro += "WS_API_KEY não encontrado no arquivo .env" + CRLF
        EndIf
        
    Endif
    fClose(nHandle) // Fecha arquivo
        
Else
    Alert("Arquivo .env não encontrado!")
EndIf

If ( !Empty( cMsgErro ) )
    Alert(cMsgErro)
EndIf

Return SELF

/*/{Protheus.doc} UploadNFT
    Funcao para carregar o arquivo de configuração .env, que contem as informações de acesso a plataforma NFT Maker PRO
    @type  Static Function
    @author DS2U (SDA)
    @since 27/05/2022
    @version 1.0.0
    @param cFile, Char, Caminho absoluto do arquivo .env
    @param aSubFiles, Array, Array de arquivos que serão anexados ao arquivo nft
    @param aMetadata, Array, Array de atributos que serão alterados / incluidos no arquivo metadadata do nft
    @return SELF, object, Objeto instanciado da classe NFTMakerPro
    @see https://api.nft-maker.io/swagger/index.html - UploadNft
/*/
Method UploadNFT( cFile, aSubFiles, aMetaData ) CLASS NFTMakerPro

Local oRest     As Object
Local oBody     As Object
Local oPreview  As Object
Local oSubFiles As Object
Local oJsonRet  As Object
Local aHeader   := {}
Local nlx       As Numeric
Local cError    As String
Local nStatus   As Numeric

Default aSubFiles := {}

AADD( aHeader, "Content-Type: application/json" )

// Monta o body
oPreview := JsonObject():New()
oPreview["mimetype"]       :=  GetType( cFile )
oPreview["displayname"]    :=  GetName( cFile )
oPreview["fileFromBase64"] :=  Encode64(,cFile)
 
oBody := JsonObject():New()
oBody["assetName"]       := GetName( cFile )
oBody["previewImageNft"] := oPreview

If ( Len( aSubFiles ) > 0 )

    oBody["subfiles"] := {}

    For nlx := 1 To Len( aSubFiles )
        
        oSubFiles := JsonObject():New()
        oSubFiles["mimetype"]       :=  GetType( aSubFiles[nlx] )
        oSubFiles["displayname"]    :=  GetName( aSubFiles[nlx] )
        oSubFiles["fileFromBase64"] :=  Encode64(,aSubFiles[nlx])

        AADD( oBody["subfiles"], oSubFiles )

    Next nlx

EndIf

// Realiza o POST para upload da NFT
oRest := FWRest():New( ::endPoint )
oRest:SetPath( "/UploadNft/" + ::apiKey + "/" + ::projectId )
oRest:SetPostParams( oBody:toJson() )
oRest:SetChkStatus(.F.)

If ( oRest:Post( aHeader ) )

    cError := ""
    nStatus := HTTPGetStatus(@cError)

    If ( nStatus >= 200 .And. nStatus <= 299 )

        If ( Empty( oRest:getResult() ) )
            MsgInfo(nStatus)
        Else
            oJsonRet := JsonObject():New()
            oJsonRet:FromJson( oRest:getResult() )

            If ( Len( aMetaData ) > 0 )
                ::UpMetaData( aMetaData, oJsonRet["nftId"] )
            EndIf

        EndIf

    Else
        MsgStop(oRest:getLastError() + CRLF + oRest:getResult())
    EndIf

Else
    MsgStop(oRest:getLastError() + CRLF + oRest:getResult())
EndIf

Return SELF

/*/{Protheus.doc} GetNftDetails
    Metodo para buscar detalhes do NFT dado o nome do NFT
    @author DS2U (SDA)
    @since 04/06/2022
    @version 1.0.0
    @param cNftName, Char, Nome do arquivo NFT
    @return SELF, object, Objeto instanciado da classe NFTMakerPro
    @see https://api.nft-maker.io/swagger/index.html - GetNftDetails
    /*/
Method GetNftDetails( cNftName ) CLASS NFTMakerPro

Local oRest     As Object
Local oJsonRet  As Object
Local aHeader   := {}
Local cError    As String
Local nStatus   As Numeric

AADD( aHeader, "Content-Type: application/json" )

// Realiza o POST para upload da NFT
oRest := FWRest():New( ::endPoint )
oRest:SetPath( "/GetNftDetails/" + ::apiKey + "/" + ::projectId + "/" + cNftName )
oRest:SetChkStatus(.F.)

oJsonRet := JsonObject():New()

If ( oRest:Get( aHeader ) )

    cError := ""
    nStatus := HTTPGetStatus(@cError)

    If ( nStatus >= 200 .And. nStatus <= 299 )

        If ( Empty( oRest:getResult() ) )
            MsgInfo(nStatus)
        Else
            oJsonRet:FromJson( oRest:getResult() )
        EndIf

    Else
        MsgStop(oRest:getLastError() + CRLF + oRest:getResult())
    EndIf

Else
    MsgStop(oRest:getLastError() + CRLF + oRest:getResult())
EndIf

Return oJsonRet

/*/{Protheus.doc} GetNftById
    Metodo para buscar detalhes do NFT dado o ID do NFT
    @author DS2U (SDA)
    @since 04/06/2022
    @version 1.0.0
    @param nIdNft, Numeric, ID do arquivo NFT
    @return SELF, object, Objeto instanciado da classe NFTMakerPro
    /*/
Method GetNftById( nIdNft ) CLASS NFTMakerPro

Local oRest     As Object
Local oJsonRet  As Object
Local aHeader   := {}
Local cError    As String
Local nStatus   As Numeric

AADD( aHeader, "Content-Type: application/json" )

// Realiza o POST para upload da NFT
oRest := FWRest():New( ::endPoint )
oRest:SetPath( "/GetNftDetailsById/" + ::apiKey + "/" + ::projectId + "/" + AllTrim( cValToChar( nIdNft ) ) )
oRest:SetChkStatus(.F.)

oJsonRet := JsonObject():New()

If ( oRest:Get( aHeader ) )

    cError := ""
    nStatus := HTTPGetStatus(@cError)

    If ( nStatus >= 200 .And. nStatus <= 299 )

        If ( Empty( oRest:getResult() ) )
            MsgInfo(nStatus)
        Else
            oJsonRet:FromJson( oRest:getResult() )
        EndIf

    Else
        MsgStop(oRest:getLastError() + CRLF + oRest:getResult())
    EndIf

Else
    MsgStop(oRest:getLastError() + CRLF + oRest:getResult())
EndIf

Return oJsonRet

/*/{Protheus.doc} UpMetaData
    Metodo para realizar o POST de atualização de metadados do NFT
    @type  Static Function
    @author DS2U (SDA)
    @since 27/05/2022
    @version 1.0.0
    @param aMetaData, Array, Array com os atributos para serem adicionados / alterados no metadados
    @param nIdNft, Numeric, Id do NFT
    @return SELF, object, Objeto instanciado da classe NFTMakerPro
    @see https://api.nft-maker.io/swagger/index.html - UpdateMetadata
/*/
Method UpMetaData( aMetaData, nIdNft ) CLASS NFTMakerPro

Local oRest     As Object
Local oJsonRet  As Object
Local aHeader   := {}
Local cError    As String
Local nStatus   As Numeric
Local oNFT      := ::GetNftById( nIdNft )
Local oMetaData := JsonObject():New()      
Local nlx
Local cJson As String

Default aSubFiles := {}

If ( ValType( oNFT ) == "J" )

    oMetaData:FromJson( oNFT["metadata"] )

    // Desta maneira acrescenta/altera atributos do NFT. Se precisar alterar do SubFiles, precisar descer mais o niveis nos atributos do Json
    For nlx := 1 To Len( aMetaData )
        oMetaData["721"][oNFT["policyid"]][oNFT["name"]][aMetaData[nlx][1]] := aMetaData[nlx][2]
    Next nlx

    oNFT["metadata"] := oMetaData:ToJson()

Else
    Alert("NFT [" + cIdNft + "] nao encontrada")
EndIf

AADD( aHeader, "Content-Type: application/json" )

cJson := NftProJson( oMetaData:ToJson() ) 

// Realiza o POST para upload da NFT
oRest := FWRest():New( ::endPoint )
oRest:SetPath( "/UpdateMetadata/" + ::apiKey + "/" + ::projectId + "/" + AllTrim( cValToChar( oNFT["id"] ) ) )
oRest:SetPostParams( cJson )
oRest:SetChkStatus(.F.)

If ( oRest:Post( aHeader ) )

    cError := ""
    nStatus := HTTPGetStatus(@cError)

    If ( nStatus >= 200 .And. nStatus <= 299 )

        If ( Empty( oRest:getResult() ) )
            MsgInfo(nStatus)
        Else
            oJsonRet := JsonObject():New()
            oJsonRet:FromJson( oRest:getResult() )
        EndIf

    Else
        MsgStop(oRest:getLastError() + CRLF + oRest:getResult())
    EndIf

Else
    MsgStop(oRest:getLastError() + CRLF + oRest:getResult())
EndIf

Return oJsonRet

/*/{Protheus.doc} GetType
    (long_description)
    @type  Static Function
    @author DS2U (SDA)
    @since 27/05/2022
    @version 1.0.0
    @param cFile, Char, Diretorio + nome do arquivo
    @return cMimeType, Char, mimetype do arquivo
/*/
Static Function GetType( cFile, lVideo )

Local cMimeType As String
Local cSep      As String
Local cFileExt  As String
Local cExtensao As String
Local aDirFile  As Array

Default lVideo  := .F.

// Identificando separador do path enviado com o diretorio e nome do arquivo
If ( "\\" $ cFile )
    cSep := "\\"
ElseIf ( "//" $ cFile )
    cSep := "//"
ElseIf ( "/" $ cFile )
    cSep := "/"
Else
    cSep := "\"
EndIf

// Quebra por diretorio e nome do arquivo
aDirFile := separa( cFile, cSep )

// Identifica nome e extensão do arquivo
cFileExt := aDirFile[Len(aDirFile)]

// Identifica extensão do arquivo
cExtensao := Upper( AllTrim( Separa( cFileExt, "." )[2] ) )

If ( cExtensao == "PNG" )
    cMimeType := "image/png"
ElseIf ( cExtensao == "JPG" )
    cMimeType := "image/jpg"
ElseIf ( cExtensao == "BMP" )
    cMimeType := "image/bmp"
ElseIf ( cExtensao == "SVG" )
    cMimeType := "image/svg+xml"
ElseIf ( cExtensao == "JPEG" )
    cMimeType := "image/jpeg"
ElseIf ( cExtensao == "GIF" )
    cMimeType := "image/gif"
ElseIf ( cExtensao == "APNG" )
    cMimeType := "image/apng"
ElseIf ( cExtensao == "WEBP" )
    cMimeType := "image/webp"
ElseIf ( cExtensao == "MPEG" .And. lVideo )
    cMimeType := "video/mpeg"
ElseIf ( cExtensao == "MPEG" .And. !lVideo )
    cMimeType := "audio/mpeg"
ElseIf ( cExtensao == "MP4" )
    cMimeType := "video/mp4"
ElseIf ( cExtensao == "OGG" .And. lVideo )
    cMimeType := "video/ogg"
ElseIf ( cExtensao == "OGG" .And. !lVideo )
    cMimeType := "audio/ogg"
ElseIf ( cExtensao == "QUICKTIME" )
    cMimeType := "video/quicktime"
ElseIf ( cExtensao == "WEBM" )
    cMimeType := "video/webm"
ElseIf ( cExtensao == "WAV" )
    cMimeType := "audio/wav"
ElseIf ( cExtensao == "FLAC" )
    cMimeType := "audio/flac"
ElseIf ( cExtensao == "MP3" )
    cMimeType := "audio/mpeg" // Na plataforma não existe o mimetype MP3
ElseIf ( cExtensao == "HTML" )
    cMimeType := "text/html"
ElseIf ( cExtensao == "JS" )
    cMimeType := "text/javascript"
ElseIf ( cExtensao == "js" )
    cMimeType := "text/javascript"
ElseIf ( cExtensao == "PLAIN" .Or. cExtensao == "TXT" )
    cMimeType := "text/plain"
ElseIf ( cExtensao == "CSS" )
    cMimeType := "text/css"
ElseIf ( cExtensao == "ZIP" )
    cMimeType := "application/zip"
ElseIf ( cExtensao == "PDF" )
    cMimeType := "application/pdf"
ElseIf ( cExtensao == "JSON" )
    cMimeType := "application/json"
ElseIf ( cExtensao == "GLTF" )
    cMimeType := "model/gltf+json"
EndIf

Return cMimeType

/*/{Protheus.doc} GetName
    Função auxiliar para retornar o nome do arquivo sem diretorio e sem extensão
    @type  Static Function
    @author DS2U (SDA)
    @since 27/05/2022
    @version 1.0.0
    @param cFile, Char, Diretorio + nome do arquivo
    @return cName, Char, nome do arquivo, sem diretorio e extensão
/*/
Static Function GetName( cFile )

Local cName      As String
Local cSep      As String
Local cFileExt  As String
Local aDirFile  As Array

Default cFile  := ""

// Identificando separador do path enviado com o diretorio e nome do arquivo
If ( "\\" $ cFile )
    cSep := "\\"
ElseIf ( "//" $ cFile )
    cSep := "//"
ElseIf ( "/" $ cFile )
    cSep := "/"
Else
    cSep := "\"
EndIf

// Quebra por diretorio e nome do arquivo
aDirFile := separa( cFile, cSep )

// Identifica nome e extensão do arquivo
cFileExt := aDirFile[Len(aDirFile)]

// Identifica nome do arquivo
cName := AllTrim( Separa( cFileExt, "." )[1] )

// Trata nome do arquivo pois nao pode ter caracteres especiais
cName := StrTran(cName, "_", "" )
cName := EncodeUtf8(cName)

// Nome não pode ser muito curto. Se for o caso, adiciono o prefixo NFT
If ( Len( cName ) < 4 )
    cName := "NFT" + cName
EndIf

Return cName

/*/{Protheus.doc} NftProJson
    Funcao para tratar o Json conforme o NFT Maker PRO espera
    @type  Static Function
    @author DS2U (SDA)
    @since 04/06/2022
    @version 1.0.0
    @param cJson, Char, JSon a ser tratado
    @return cJsonRet, Char, JSon tratado
/*/
Static Function NftProJson(cJson)

Local cJsonRet := StrTran( cJson, '"', '\"' )

Return cJsonRet
