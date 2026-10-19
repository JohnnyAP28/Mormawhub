# MormawHub

Interface de desenvolvimento com tema escuro, painel arrastável, minimização, perfil gráfico, checklist de evento e ferramentas de teste autorizadas para uma experiência Roblox que você controla.

## Arquivos

- `MormawHub.lua` — interface cliente. No Roblox Studio, use como `LocalScript` em `StarterPlayer > StarterPlayerScripts`.
- `MormawHubTestServer.server.lua` — endpoint server-side de teste. Coloque como `Script` em `ServerScriptService` da sua própria experiência.
- `Loader.example.lua` — exemplo de loader; os marcadores precisam ser configurados antes de uso.
- `README.md` — instalação, funções e limitações.

## Instalação de teste recomendada

1. Faça uma cópia de desenvolvimento da sua experiência no Roblox Studio.
2. Coloque `MormawHub.lua` como um `LocalScript` em `StarterPlayer > StarterPlayerScripts`.
3. Coloque `MormawHubTestServer.server.lua` como um `Script` em `ServerScriptService`.
4. Abra o script do servidor e configure `EXTRA_TESTER_USER_IDS` com os UserIds numéricos de testadores autorizados se a experiência for de grupo ou se outras contas precisarem testar. O dono de uma experiência pessoal é autorizado automaticamente.
5. Teste com **Test > Start** no Studio ou em um servidor privado. O script do servidor bloqueia os comandos fora do Studio/servidor privado e para contas que não estejam autorizadas.
6. Abra a aba **Testes**, ative o modo de teste e confira o texto de status para saber se o servidor autorizou a operação.

Exemplo de allowlist no script de servidor:

```lua
local EXTRA_TESTER_USER_IDS = {
    [123456789] = true, -- substitua pelo UserId real do seu testador
}
```

Não deixe um UserId de exemplo sem substituir. Não instale o script de servidor em experiências de terceiros.

## Funções atuais

### Interface e navegação

- Tema escuro e identificação MormawHub/Brasil.
- Painel arrastável com mouse/toque, redimensionado para caber na tela e adaptado à rotação do dispositivo.
- Abas com rolagem horizontal em telas estreitas.
- Minimizar para um ícone flutuante e botão para reabrir.
- Botão `×` para fechar; ao fechar ou executar o script novamente, o painel tenta restaurar a iluminação e os efeitos visuais alterados e desconectar ouvintes externos.
- **Ajustes > Tecla para minimizar:** toque no botão e pressione uma tecla do teclado. O padrão é `RightShift`. A escolha é local e vale enquanto a interface estiver aberta.
- **Ajustes > Recentralizar painel:** volta a janela para o centro da tela.

### Halloween / evento

O vídeo mostra um aviso de florada de borboletas com instruções para pegar uma rede e capturar borboletas na Floresta Encantada. O checklist foi ajustado para refletir essas etapas visíveis:

- verificar o aviso de início da florada;
- equipar a rede de captura;
- ir à Floresta Encantada;
- capturar borboletas durante a florada.

**Este checklist é manual.** Marcar uma linha não ativa o evento, não equipa a rede nem captura itens. Para implementar essas ações de verdade, é necessário integrar o código à lógica do jogo próprio (itens, missões e eventos do servidor). O vídeo sozinho não revela os nomes das funções internas, objetos ou RemoteEvents, então não seria correto inventá-los.

### Gráficos

- **ULTRA LEVE:** reduz sombras, pós-efeitos e tenta ocultar efeitos visuais compatíveis encontrados no cliente.
- **BAIXO:** iluminação simplificada.
- **MÉDIO:** perfil intermediário, preservando o estado original de cada pós-efeito em vez de ativar indiscriminadamente todos.
- **ALTO / REALISTA:** restaura valores de iluminação capturados na inicialização.
- **Atualizar captura de efeitos visuais:** inclui efeitos criados durante a sessão na referência de restauração; se a redução estiver ativa, aplica-a aos efeitos novos.
- **Céu totalmente escuro:** escurece a iluminação local e remove temporariamente objetos `Sky` encontrados em `Lighting`.
- **Reduzir partículas e efeitos animados:** alterna efeitos locais compatíveis.
- **Restaurar configurações guardadas:** tenta restaurar iluminação e efeitos registrados.

Os perfis não alteram o controle global de qualidade gráfica do Roblox e não garantem uma quantidade específica de FPS. Efeitos criados depois da inicialização podem exigir nova captura.

### Player

Mostra nome, estado do personagem, Humanoid, vida, velocidade e disponibilidade da raiz do personagem. Vida e velocidade são atualizadas por eventos do Humanoid, e as conexões antigas são limpas quando o personagem muda. Não aplica mudanças de movimento por conta própria.

### Testes e métricas

- **FPS aproximado:** amostra de quadros por segundo do cliente.
- **Memória:** tenta ler o consumo de memória informado pelo Roblox.
- **Ping:** tenta ler a métrica de rede exposta pelo cliente; pode ficar indisponível.
- **Velocidade:** barra contínua de **0 a 100**, com atualização do valor selecionado. O valor escolhido antes da autorização é aplicado quando o servidor confirma o modo de teste.
- **Teleporte:** permite percorrer os destinos permitidos encontrados no mapa. O servidor valida o destino selecionado e executa o teleporte.
- **Voo experimental:** controle local; o analógico/controles de movimento cuidam do deslocamento horizontal, e botões de toque permitem subir/descer no celular. No teclado, use Espaço/Ctrl. Pode ser corrigido pelo servidor do jogo.
- **Aim de teste:** mira apenas NPCs da própria experiência que o desenvolvedor marcar com a tag `MormawAimTarget`, tem alcance de 250 studs e não mira outros jogadores. É controle local de câmera.
- **Animações:** tenta parar as tracks em execução no Animator do personagem local.

**Se aparecer “MormawHubTestRemote não foi encontrado”:** o script `MormawHubTestServer.server.lua` não está rodando em `ServerScriptService` da experiência atual, ou o servidor ainda não reiniciou. A interface agora informa esse problema de forma centralizada para Modo de Teste, Speed e Teleport. Voo, Aim e parar animações podem ser testados localmente sem esse Remote; Speed autoritativo e Teleport precisam dele. O servidor valida ambiente, autorização, modo de teste, intervalo de velocidade (0–100) e destino. Por segurança, só autoriza no Studio ou em servidor privado e para o dono de uma experiência pessoal ou UserIds autorizados. Para teleporte, adicione `SpawnLocation` ao mapa ou uma peça chamada `TestSpawn` ou `MormawTestSpawn`.

### Teste de desempenho repetível

1. Anote FPS, memória e ping antes das alterações.
2. Mantenha mapa, câmera e quantidade de jogadores iguais.
3. Teste cada perfil gráfico por um intervalo semelhante.
4. Compare as medições; use o MicroProfiler e o Developer Console do Roblox Studio para uma análise mais precisa.
5. Para teste de movimento, confirme o resultado no servidor, não apenas na interface do cliente.

## Limitações

- O código da interface não contém a implementação interna do evento de borboletas; apenas o projeto da experiência pode fornecer a integração correta.
- O checklist não salva progresso nem sincroniza com a conta.
- FPS, memória e ping são métricas aproximadas e dependem do que o cliente expõe.
- O voo e a parada de animações são controles locais de teste; o jogo pode reiniciar animações ou corrigir movimento. O aim só reconhece NPCs marcados com `MormawAimTarget`.
- A barra de velocidade e o teleporte dependem da instalação do script server-side e de uma conta autorizada.
- Não há promessa de FPS fixo, desbloqueio de FPS ou remoção universal de efeitos.
- Use os scripts de teste somente em uma experiência que você controla/autorizou.
