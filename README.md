# SDKs-NFT-Maker-PRO
Projeto de Desenvolvimento de SDK para integração com Plataforma NFT Maker PRO <br>
Neste caso de uso, é possível enviar arquivo de imagem e audio (subfiles) e também submeter alteração de metadata.

<br>
Referências das APIs: <a href="https://api.nft-maker.io/swagger/index.html">https://api.nft-maker.io/swagger/index.html</a>
<br>
<br>

## AdvPl

* Configurar arquivo .env, baseado no arquivo .env-sample
* Exemplo de uso da classe:
``` Python
User Function TSTNFTMP()

Local cfileCfg   := "D:\git\SDKs-NFT-Maker-PRO\AdvPl\.env"
Local cProjectID := "36326"
Local cFileImg   := "C:\Users\sergi\OneDrive\1.DS2U\1_Contas\CrypTechArt\_Projetos\Plataforma NFT\Arquivos\Amostragem\Assets\1_Guitar\I\2.png"
Local cFileAudio := "C:\Users\sergi\OneDrive\1.DS2U\1_Contas\CrypTechArt\_Projetos\Plataforma NFT\Arquivos\Amostragem\Assets\1_Guitar\A\2.mp3"
Local aSubFiles  := {}
Local aMetaData  := {}
Local oNft       As Object

AADD( aSubFiles, cFileAudio )

// Metadata do NFT - Adiciona ou altera
AADD( aMetaData, { "color", "black" } )
AADD( aMetaData, { "teste", "addTeste" } )

oNft := NFTMakerPro():New( cfileCfg, cProjectID )
oNft:UploadNFT( cFileImg, aSubFiles, aMetaData )

Return 
```