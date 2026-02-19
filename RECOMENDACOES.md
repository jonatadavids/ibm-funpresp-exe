# Recomendações Técnicas

## 1. Segurança
- Reduzir gradualmente regras legadas do `sg_admin` (all ports, múltiplos /32).
- Manter SG dedicado para LB (`sg_lb`) separado de administração.
- Limitar acesso administrativo a VPN corporativa e jump hosts.
- Revisar se portas como `1433` e `8530` ainda são realmente necessárias.

## 2. Certificados
- Migrar gestão de certificados para IBM Secrets Manager/Certificate Manager.
- Documentar processo de renovação antes do vencimento.
- Validar cadeia completa e hostname wildcard (`*.funpresp.com.br`).

## 3. VPN
- Usar PSKs novas e fortes por conexão.
- Priorizar HA real (mínimo dois túneis ativos por operadora crítica).
- Padronizar CIDRs de política para evitar inconsistências.
- Validar DPD/keepalive no equipamento on-prem.

## 4. Resiliência
- Hoje há um único target no pool do LB (sem HA de aplicação).
- Evoluir para no mínimo 2 VSIs de app em zonas diferentes.
- Considerar backup/restore testado do volume de dados MariaDB.

## 5. Operação e Governança
- Adotar pipeline CI para `terraform fmt`, `validate`, `plan`.
- Usar backend remoto de state (ex.: COS + locking) para trabalho em equipe.
- Definir convenção de tags obrigatórias (ambiente, owner, criticidade, custo).
- Versionar mudanças via Pull Request com aprovação técnica.

## 6. Custo e Ciclo de Vida
- Para laboratório, desligar recursos opcionais (`lb_enabled`, `vpn_enabled`) quando não estiver testando.
- Executar `destroy` ao fim dos testes para evitar custo residual.
