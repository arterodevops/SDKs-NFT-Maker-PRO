# SDKs-NFT-Maker-PRO
Projeto de Desenvolvimento de SDK para integração com Plataforma NFT Maker PRO

## AdvPl

* Configurar arquivo .env, baseado no arquivo .env-sample
* Exemplo de uso da classe:
``` 
User Function TSTNFTMP()

Local cFileEnv   := "D:\git\NFTMakerProSDK\AdvPl\.env"
Local cProjectID := "36326"
Local cFileImg   := "C:\Users\sergi\OneDrive\1.DS2U\1_Contas\CrypTechArt\_Projetos\Plataforma NFT\Arquivos\Amostragem\Assets\1_Guitar\I\1.png"
Local cFileAudio := "C:\Users\sergi\OneDrive\1.DS2U\1_Contas\CrypTechArt\_Projetos\Plataforma NFT\Arquivos\Amostragem\Assets\1_Guitar\A\1.mp3"
Local aSubFiles  := {}
Local oNft       As Object

AADD( aSubFiles, cFileAudio )

oNft := NFTMakerPro():New( cFileEnv, cProjectID )
oNft:UploadNFT( cFileImg, aSubFiles )

Return 
```