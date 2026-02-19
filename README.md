# IBM FUNPRESP EXE
Projeto Terraform para provisionar ambiente base do SEI na IBM Cloud VPC, com foco em paridade arquitetural com AWS e possibilidade de ciclo completo `create -> validate -> destroy`.

## Escopo
- VPC (`10.60.0.0/16`)
- Subnets (`app`, `db`, `public`)
- 3 instâncias VSI:
  - `sei` (aplicação)
  - `solr`
  - `mariadb`
- Volume de dados dedicado para MariaDB
- Security Groups (modelo administrativo + funcional)
- Public Gateway para saída de internet
- Load Balancer público com HTTPS (80 -> 443)
- VPN Site-to-Site com peers externos (CLICKNET/ALLREDE/NWI)
- Outputs principais para operação

## Estrutura de arquivos
- `provider.tf`: provider IBM e região
- `versions.tf`: versões Terraform/provider
- `variables.tf`: variáveis de entrada
- `local.tf`: convenções locais (nome/tags)
- `vpc.tf`: VPC
- `subnets.tf`: subnets
- `security.tf`: SGs e regras
- `instances.tf`: chave SSH, VSIs e volume do banco
- `connectivity.tf`: public gateway e attachments
- `lb.tf`: load balancer, listeners e pool
- `vpn.tf`: IKE/IPsec + VPN gateway + conexões
- `outputs.tf`: saídas para validação/operação
- `terraform.tfvars.example`: exemplo de parametrização
- `RECOMENDACOES.md`: recomendações de segurança/operação

## Pré-requisitos
- Terraform >= 1.0
- Conta IBM Cloud com permissões para VPC/Compute/LB/VPN/Secrets
- `IC_API_KEY` exportada no shell
- Chave SSH pública local (`.pub`)
- Certificado já importado no IBM Secrets Manager/Certificate Manager (CRN)

## Setup rápido
1. Clone o repositório.
2. Copie variáveis de exemplo:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
3. Preencha obrigatoriamente no `terraform.tfvars`:
   - `image_id_app`
   - `image_id_solr`
   - `image_id_db`
   - `lb_certificate_crn`
   - `vpn_preshared_keys` (PSKs novas)
4. Exporte API Key:
   ```bash
   export IC_API_KEY="<SUA_API_KEY>"
   ```
5. Rode:
   ```bash
   terraform init -upgrade
   terraform validate
   terraform plan -out tfplan
   terraform apply tfplan
   ```

## Destroy completo
```bash
terraform destroy -auto-approve
```

## Pontos importantes
- O certificado ACM da AWS **não** é reutilizado diretamente na IBM. Deve ser importado e referenciado por `CRN`.
- PSKs da VPN devem ser novas e únicas por peer.
- Valores `CHANGE_ME_*` devem ser substituídos antes de `apply`.
- Este projeto está em modo de paridade operacional com AWS e não no modo mais restritivo de segurança.

## Checklist antes de Apply
- [ ] IDs de imagem IBM válidos em `br-sao`
- [ ] `lb_certificate_crn` válido
- [ ] PSKs da VPN atualizadas
- [ ] CIDRs confirmados (`10.60.0.0/16` e `10.1.0.0/16`)
- [ ] Permissões da API Key confirmadas
- [ ] Revisão de regras SG permissivas (se produção)

## Entrega / Handover
Para compartilhar com outro time/pessoa:
- versionar esta pasta no Git
- **não** comitar `terraform.tfvars`
- incluir evidências de `plan` e outputs pós-apply
