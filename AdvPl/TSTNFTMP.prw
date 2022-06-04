/*/{Protheus.doc} TSTNFTMP
    Funcao para testar classe SDK NFTMakerPro
    @type  Function
    @author DS2U (SDA)
    @since 27/05/2022
    @version 1.0.0
    /*/
User Function TSTNFTMP()

Local cfileCfg   := "D:\git\SDKs-NFT-Maker-PRO\AdvPl\.env"
Local cProjectID := "36326"
Local cFileImg   := "C:\Users\sergi\OneDrive\1.DS2U\1_Contas\CrypTechArt\_Projetos\Plataforma NFT\Arquivos\Amostragem\Assets\1_Guitar\I\1.png"
Local cFileAudio := "C:\Users\sergi\OneDrive\1.DS2U\1_Contas\CrypTechArt\_Projetos\Plataforma NFT\Arquivos\Amostragem\Assets\1_Guitar\A\1.mp3"
Local aSubFiles  := {}
Local oNft       As Object

AADD( aSubFiles, cFileAudio )

oNft := NFTMakerPro():New( cfileCfg, cProjectID )
//oNft:UploadNFT( cFileImg, aSubFiles )
oNft:GetNftDetails( "NFT1" )

Return 
