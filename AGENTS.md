# AGENTS.md

Leia este arquivo antes de cada tarefa e siga o fluxo abaixo.

## Branches

- `main` só muda depois que o usuário testa. Push e merge em `main` ficam com o usuário.
- `development` é a branch de entrega. Cada tarefa termina aqui.
- `tipo/tarefa` é a branch de trabalho, criada a partir de `development` atualizada.

Se `development` ainda não existir, crie a partir de `main`.

## Fluxo

1. Se a tarefa misturar assuntos ou o tipo não estiver claro, pergunte antes de abrir a issue.
2. Abra uma issue com `gh issue create`. Título curto, em português. No corpo: contexto, critérios de pronto e como testar.
3. Atualize `development` e crie o branch `tipo/tarefa-em-kebab-case`.
4. Faça só o que a issue pede.
5. Commit único, com o assunto igual ao nome do branch. No corpo, diga o porquê e inclua `Closes #<número>`.
6. Rode os testes do projeto, quando existirem. Se falharem, não faça o merge.
7. Faça merge `--no-ff` do branch em `development` e envie só `development` para o remoto.
8. Diga ao usuário o que testar. Ele testa `development` e, se estiver certo, leva para `main` com merge, sem squash.

`Closes #<número>` fecha a issue quando o commit chega em `main`. Durante o teste em `development`, a issue continua aberta.

## Nome

Minúsculas, hífens, sem acento. O prefixo é um tipo da tabela.

```text
fix/tela-de-listagem-de-exercicios-travada
```

`issue` não é um tipo. Uma tela travada entra como `fix`. O assunto do commit repete o nome do branch. Não misture tipos no mesmo commit.

## Tipos

| Prefixo | Significado | Quando utilizar |
| --- | --- | --- |
| feat | Feature | Adicionar uma nova funcionalidade |
| fix | Fix | Corrigir um bug |
| chore | Chore | Tarefas de manutenção que não alteram funcionalidades |
| docs | Documentation | Alterar documentação |
| style | Style | Formatação, espaços, ponto e vírgula etc. |
| refactor | Refactoring | Melhorar o código sem alterar seu comportamento |
| test | Tests | Adicionar ou modificar testes |
| perf | Performance | Melhorar desempenho |
| build | Build | Alterações no processo de build ou dependências |
| ci | Continuous Integration | Alterar pipelines e configurações de CI/CD |
| revert | Revert | Desfazer um commit anterior |

## Limites

- Uma issue, um branch, um commit, um merge em `development`.
- Não altere `main`.
- Não use force push, amend ou `--no-verify`.
- Não faça commit de segredo, `.env` ou credencial.
- Issues, commits e mensagens ao usuário ficam em português.
- Não abra pull request, a menos que o usuário peça. A entrega é o merge em `development`.
- Se o projeto ainda não tiver como rodar teste, registre isso na issue em vez de inventar um resultado.
