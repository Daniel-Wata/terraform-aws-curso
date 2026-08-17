# Aula 2 — VPC e Load Balancer público

Nesta aula a base da Aula 1 vira uma rede funcional: uma VPC em duas zonas de disponibilidade, duas subnets públicas, duas privadas e um Application Load Balancer que responde pela internet com um HTML fixo. O state da stack principal continua no backend S3 criado anteriormente.

O resultado observável é o endpoint HTTP mostrado pelo output `alb_endpoint`. Ainda não há domínio, HTTPS, ECS, Django ou banco de dados.

## O caminho da requisição

Uma requisição chega ao ALB nas subnets públicas porque três peças trabalham juntas:

- o Internet Gateway conecta a VPC à internet;
- a tabela pública possui uma rota `0.0.0.0/0` para esse gateway;
- o Security Group do ALB permite entrada TCP na porta 80.

O listener HTTP devolve uma resposta fixa. Isso permite validar a rede antes de adicionar a aplicação nas próximas aulas. As subnets privadas têm tabela própria, mas nenhuma rota para a internet e nenhum NAT Gateway.

Na Aula 3, a resposta fixa continua servindo como prova isolada enquanto esta entrada ganha domínio, certificado ACM e HTTPS. O ECS entra somente na Aula 4.

## Arquivos principais

- [`network.tf`](network.tf): VPC, zonas de disponibilidade, subnets, Internet Gateway e tabelas de rota.
- [`security-groups.tf`](security-groups.tf): entrada HTTP pública para o ALB.
- [`alb.tf`](alb.tf): ALB externo e listener com resposta fixa.
- [`backend.tf`](backend.tf): backend S3 e lock nativo por arquivo.
- [`main.tf`](main.tf): versões, provider e tags padrão.
- [`variables.tf`](variables.tf): profile, região, projeto, ambiente e CIDR.
- [`outputs.tf`](outputs.tf): DNS e endpoint HTTP do ALB.
- [`bootstrap/main.tf`](bootstrap/main.tf): bucket usado pelo backend remoto.

## Pré-requisitos

- Terraform 1.10 ou superior;
- AWS CLI autenticada em uma conta pessoal;
- bucket do backend já criado pelo bootstrap da aula anterior;
- permissão para criar VPC, subnets, rotas, Security Group e ALB.

Revise os valores fixos de [`backend.tf`](backend.tf), principalmente bucket,
região e profile. O provider seleciona explicitamente o profile configurado no
código. Para conferir qual identidade esse profile resolve:

```bash
aws sts get-caller-identity --profile SEU_PROFILE
```

Crie o arquivo local do bootstrap a partir do exemplo:

```bash
cp bootstrap/terraform.tfvars.example bootstrap/terraform.tfvars
```

Para a stack principal, crie um `terraform.tfvars` local com os valores usados por [`variables.tf`](variables.tf):

```hcl
region       = "us-east-1"
profile      = "SEU_PROFILE"
project_name = "meu-projeto"
environment  = "dev"
cidr_block   = "10.0.0.0/16"
```

Os arquivos `*.tfvars` e `*.tfstate` são ignorados pelo [`.gitignore`](../.gitignore) e não devem ser versionados.

## Executar a stack principal

Com o bucket de state existente e os valores locais preenchidos:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
terraform output -raw alb_endpoint
```

Abra o endpoint exibido. A resposta `Rede pronta.` vem diretamente do listener do ALB.

## Custo e destruição

O ALB é cobrado por hora enquanto existir, mesmo sem tráfego. Ao terminar, destrua a stack a partir da pasta `Aula-2`:

```bash
terraform destroy
```

Isso remove a rede e o ALB desta aula, mas preserva o bucket de state que está na pasta `bootstrap`. Não execute `terraform destroy` dentro de `bootstrap`: nesse código o bucket usa `force_destroy = true`, portanto a exclusão pode apagar também os objetos e versões do state.

Depois do destroy, confirme que não restaram recursos cobrados. O endpoint é HTTP, aberto para demonstração; não o trate como configuração de produção.
