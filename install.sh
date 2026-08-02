#!/bin/bash

# =============================================================================
# Script de Instalação Docker-First para SEMARH Fiscaliza (Robusto e Interativo)
#
# Versão: 3.0
# Autor: Gemini Code Assist (revisado)
#
# Melhorias:
# - Substitui 'sleep' por uma verificação de saúde ativa do banco de dados.
# - Adiciona interatividade para popular o banco (seeding).
# - Usa a sintaxe moderna 'docker compose' quando disponível.
# =============================================================================

# --- Configuração de Shell ---
# Sai imediatamente se um comando sair com um status diferente de zero.
set -e

# --- Configuração de Cores e Log ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem Cor

log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ ERRO: $1${NC}" >&2; }
log_info() { echo -e "${YELLOW}▶ $1${NC}"; }
log_header() { echo -e "\n${BLUE}--- $1 ---${NC}"; }

# --- Funções de Verificação ---
check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "Comando '$1' não encontrado. Por favor, instale-o e tente novamente."
        exit 1
    fi
}

# --- Função Auxiliar para Docker Compose ---
detect_compose_command() {
    if docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        COMPOSE_CMD="docker-compose"
    fi
}

# --- Início do Script ---
clear
echo "================================================="
echo "  Instalador Docker do SEMARH Fiscaliza (v3.0)"
echo "================================================="
echo

log_header "1. VERIFICAÇÃO DE DEPENDÊNCIAS"
log_info "Verificando dependências..."
check_command "git"
check_command "docker"
detect_compose_command
log_info "Usando o comando: '$COMPOSE_CMD'"
log_success "Todas as dependências foram encontradas e são compatíveis!"


log_header "2. CONFIGURAÇÃO DO AMBIENTE"
log_info "Configurando o arquivo de ambiente..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    log_success "Arquivo .env criado com sucesso."
else
    log_info "O arquivo .env já existe, pulando criação."
fi

log_info "O próximo passo irá construir e iniciar os contêineres Docker (build & up)."
log_info "VERIFIQUE SEU ARQUIVO .env: Certifique-se de que as variáveis DB_DATABASE, DB_USERNAME e DB_PASSWORD estão preenchidas."

if grep -qE "^DB_PASSWORD=('?secret'?|\"?secret\"?)$" .env || grep -q "^DB_PASSWORD=$" .env; then
    log_error "A senha padrão 'secret' ou uma senha vazia foi encontrada no .env. Por favor, edite o arquivo e defina uma senha segura."
    exit 1
fi

read -p "Pressione [Enter] para continuar..."

log_header "3. CONSTRUÇÃO E INICIALIZAÇÃO DOS CONTÊINERES"
log_info "Construindo e iniciando os contêineres Docker (pode levar vários minutos na primeira vez)..."
$COMPOSE_CMD up -d --build
log_success "Contêineres iniciados com sucesso."

log_header "4. AGUARDANDO O BANCO DE DADOS"
log_info "Aguardando o contêiner do banco de dados ficar pronto..."
retries=20
count=0
until $COMPOSE_CMD exec -T db pg_isready -U "${DB_USERNAME:-semarh_user}" -d "${DB_DATABASE:-semarh_db}" -q; do
    count=$((count + 1))
    if [ $count -ge $retries ]; then
        log_error "O banco de dados não ficou pronto após $retries tentativas. Verifique os logs do contêiner 'db'."
        $COMPOSE_CMD logs db
        exit 1
    fi
    log_info "Aguardando... (tentativa $count/$retries)"
    sleep 3
done
log_success "Banco de dados está pronto para aceitar conexões."

log_header "5. SETUP DA APLICAÇÃO"

# Função para executar comandos artisan de forma limpa
artisan() {
    $COMPOSE_CMD exec -T app php artisan "$@"
}

log_info "Ajustando permissões das pastas 'storage' e 'bootstrap/cache' dentro do contêiner..."
# Define o dono como 'www-data' e o grupo como 'www-data', e aplica permissões 775.
$COMPOSE_CMD exec -T app sh -c "chown -R www-data:www-data storage bootstrap/cache && chmod -R 775 storage bootstrap/cache"
log_success "Permissões ajustadas."

log_info "Gerando a chave da aplicação (APP_KEY)..."
artisan key:generate
log_success "Chave da aplicação gerada."

log_info "Executando as migrações do banco de dados..."
artisan migrate --force
log_success "Migrações concluídas."

read -p "Deseja popular o banco de dados com dados iniciais (db:seed)? [S/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ || $REPLY == "" ]]; then
    log_info "Populando o banco de dados com dados iniciais (seeding)..."
    artisan db:seed --force
    log_success "Banco de dados populado."
else
    log_info "Pulando o passo de popular o banco de dados."
fi

log_info "Criando o link simbólico de armazenamento..."
artisan storage:link
log_success "Link de armazenamento criado."

# --- Finalização ---
echo
echo "=========================================================="
log_success "Instalação Docker do SEMARH Fiscaliza concluída!"
echo "=========================================================="
echo
log_info "Próximos passos:"
log_info "1. A aplicação está rodando! Acesse em seu navegador: ${BLUE}http://localhost:8000${NC}"
log_info "2. Para gerenciar o ambiente (parar, ver logs, etc), use o painel:"
echo -e "   ${YELLOW}./gerenciar.sh${NC} (no Git Bash) ou ${YELLOW}./gerenciar.ps1${NC} (no PowerShell)"
echo

exit 0
