# Aula 1 — State remoto e estrutura do projeto

Na Aula 0 o state ficou local de propósito. Agora criamos o bucket que vai guardar
essa memória na AWS, migramos o state para ele e organizamos a configuração para o
projeto crescer sem transformar o `main.tf` em um arquivo gigante.

## O problema do bootstrap

O bucket que guarda o state também é infraestrutura. Mas ele precisa existir antes de
o Terraform conseguir usá-lo como backend — o clássico problema do ovo e da galinha.

Por isso, [`bootstrap/main.tf`](bootstrap/main.tf) é um stack pequeno e separado, com
state local. Execute-o uma vez para criar o bucket de state. Depois, a configuração
principal usa esse bucket definido em [`backend.tf`](backend.tf).

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
# edite region, profile e state_bucket_name
terraform init
terraform apply
```

O nome do bucket precisa ser globalmente único na AWS. O arquivo `terraform.tfvars`
tem valores da sua conta e não deve ir para o Git.

## State remoto no S3

De volta à raiz da Aula 1, atualize o nome do bucket e o profile em
[`backend.tf`](backend.tf), se necessário. Backend é diferente de provider: ele diz
onde o Terraform guarda seu próprio state.

```bash
cd ..
terraform init
terraform plan
terraform apply
```

O backend S3 usa `use_lockfile = true`. Durante um `apply`, o Terraform cria um lock
para impedir duas escritas concorrentes no mesmo state. Isso substitui a tabela
DynamoDB que muitos tutoriais mais antigos usam para lock.

Os valores do backend são literais: não é possível usar `var.alguma_coisa` dentro do
bloco `backend`, porque ele é inicializado antes das variáveis serem avaliadas.

## Variáveis, locals e outputs

[`variables.tf`](variables.tf) concentra o que muda entre execuções: região, profile,
nome do projeto, ambiente e nome do bucket de state. A variável `environment` valida
os únicos valores permitidos: `dev` ou `prod`.

[`locals.tf`](locals.tf) concentra valores calculados. Nesta aula,
`local.name_prefix` combina `project_name` e `environment`, mantendo o padrão de nome
dos recursos em um único lugar.

[`outputs.tf`](outputs.tf) exibe valores úteis depois do `apply`, como o prefixo e o
nome do bucket criado. Outputs são a interface de um stack para pessoas, scripts ou
outros stacks.

Terraform lê todos os arquivos `.tf` do diretório como uma configuração só. Separar
em `main.tf`, `variables.tf`, `locals.tf`, `outputs.tf` e `backend.tf` é convenção para
as pessoas lerem melhor; não muda a ordem de execução.

## O que esta aula cria

Além do bucket de bootstrap, o stack principal cria um bucket de demonstração com o
nome formado por:

```text
<project_name>-<environment>-first
```

O bucket tem `force_destroy = true` para facilitar os testes. Use isso com cuidado:
ao destruir, os objetos que estiverem nele também são removidos.

## Destruir sem perder o state

Para zerar a conta, destrua primeiro a infraestrutura principal e só depois o
bootstrap:

```bash
terraform destroy
cd bootstrap
terraform destroy
```

Se o bucket de bootstrap for removido antes, o Terraform perde o state remoto de que
precisa para gerenciar a infraestrutura principal.

## Arquivos sensíveis

`terraform.tfstate` e `terraform.tfvars` podem guardar informações em texto puro.
Eles não vão para o Git; confira o [`.gitignore`](../.gitignore) na raiz. O arquivo
`.terraform.lock.hcl`, por outro lado, deve ser versionado para fixar as versões dos
providers usadas pelo projeto.
