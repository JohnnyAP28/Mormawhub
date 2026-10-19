# MormawHub — GitHub Starter

Projeto inicial do MormawHub com interface escura, identificação brasileira, minimização por ícone flutuante e controles locais de desempenho.

## Arquivos

- `MormawHub.lua` — script principal.
- `Loader.example.lua` — modelo do carregador remoto.
- `README.md` — instruções de publicação e limitações.

## Publicar no GitHub

1. Crie um repositório novo no GitHub, por exemplo `MormawHub`.
2. Envie `MormawHub.lua` para a raiz do repositório.
3. Abra o arquivo no GitHub e clique em **Raw**.
4. Copie o endereço `raw.githubusercontent.com` gerado pelo GitHub.
5. Atualize a URL no arquivo `Loader.example.lua` com seu usuário e repositório reais.

O arquivo principal e as instruções podem ser atualizados diretamente no repositório. O loader de exemplo ainda usa um marcador e precisa ser ajustado antes de ser usado.

## Carregador de exemplo

Depois de publicar o arquivo e substituir os marcadores pelos dados reais:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/SEU_USUARIO/MormawHub/main/MormawHub.lua"))()
```

Esse formato exige um ambiente que permita `loadstring` e requisições HTTP. Para desenvolvimento oficial no Roblox Studio, prefira colocar o conteúdo como um `LocalScript` em `StarterPlayer > StarterPlayerScripts`.

## Atualização — checklist do Halloween

A interface agora tem quatro abas: **Início**, **Halloween**, **Gráficos** e **Ajustes**.

- **Halloween:** checklist manual com nove etapas relacionadas ao evento, incluindo os quatro objetos da missão do Echo, Ghost Fisherman, Haunted Rod, Phantom Express/área Spectral e Candy Corn. Marque/desmarque cada etapa e acompanhe o progresso.
- **Ajustes:** zerar o checklist e mostrar/ocultar a dica do evento.
- **Gráficos:** mantém os controles anteriores de iluminação, sombras e efeitos locais.
- **Início:** resumo das seções.
- O painel continua arrastável, minimizável e fechável, com botão flutuante para reabrir.

**Limites:** o checklist é apenas um rastreador manual local; não confirma objetivos no jogo, não salva progresso entre execuções e não se sincroniza com a conta Roblox. As funções de farm automático, roubo automático, coleta automática, voo, teleporte e alteração de velocidade para obter vantagem em experiências de terceiros não foram adicionadas. Mecânicas de gameplay devem ser implementadas e testadas no próprio jogo do desenvolvedor, com validação no servidor.

## O que funciona nesta versão

- Interface com nome MormawHub e bandeira brasileira.
- Minimizar esconde a janela e deixa apenas o botão flutuante; tocar nele reabre.
- Botão `×` fecha a interface.
- Painel arrastável por mouse/toque.
- Perfil local de gráficos reduzidos: desativa sombras globais, efeitos de pós-processamento, ajusta brilho e neblina.
- Opção de restaurar valores de iluminação capturados quando o script iniciou.

## Limitações importantes

- As configurações de iluminação/efeitos não controlam todos os gráficos internos do Roblox nem garantem aumento específico de FPS.
- Não existe um limitador de FPS real nesta versão.
- As ações de farm, roubo, coleta e teleporte não estão implementadas. Não use este projeto para automatizar ou interferir em jogos de terceiros. Para essas mecânicas, implemente a lógica no seu próprio jogo e valide ações no servidor.
- O script pode não restaurar efeitos que sejam criados depois de sua inicialização.
