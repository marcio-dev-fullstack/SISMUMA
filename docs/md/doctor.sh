#!/bin/bash

# =============================================================================
# Script de Diagnóstico de Ambiente - SEMARH Fiscaliza
#
# Versão: 1.0
# Autor: MÁRCIO
#
# Uso: ./doctor.sh
#
# Este script verifica a saúde do ambiente de desenvolvimento Docker,
# checando o status dos contêineres, a conexão com o banco de dados
# e as permissões de pastas críticas.
# =============================================================================

# --- Configuração de Shell ---
set -e

# --- Configuração de Cores e Log ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem Cor

log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ FALHA: $1${NC}"; }
log_info() { echo -e "${YELLOW}▶ $1${NC}"; }
log_header() { echo -e "\n${BLUE}--- $1 ---${NC}"; }

# --- Variáveis ---
REQUIRED_SERVICES=("app" "db" "redis")
declare -a FAILED_CHECKS=()

# --- Funções de Verificação ---

check_container_status() {
    log_header "1. VERIFICANDO STATUS DOS CONTÊINERES"
    local all_ok=true
    for service in "${REQUIRED_SERVICES[@]}"; do
        log_info "Verificando serviço '$service'..."
        # Verifica se o contêiner está rodando
        if ! docker-compose ps | grep -q "${service}" | grep -q "running"; then
            log_error "O contêiner para o serviço '$service' não está rodando ou não existe."
            all_ok=false
        else
            log_success "Serviço '$service' está online."
        fi
    done
    if [ "$all_ok" = false ]; then
        FAILED_CHECKS+=("Status dos Contêineres")
        log_error "Um ou mais contêineres essenciais não estão rodando. Tente executar './gerenciar.sh' e selecionar a opção 'Iniciar Ambiente'."
        exit 1 # Aborta o script se os contêineres não estiverem de pé
    fi
}

check_db_connection() {
    log_header "2. VERIFICANDO CONEXÃO COM O BANCO DE DADOS"
    log_info "Tentando conectar ao PostgreSQL dentro do contêiner 'app'..."
    if docker-compose exec -T app php artisan db:show &> /dev/null; then
        log_success "Conexão com o banco de dados estabelecida com sucesso."
    else
        log_error "Não foi possível conectar ao banco de dados a partir da aplicação."
        log_info "Possíveis causas: credenciais incorretas no .env, serviço 'db' não iniciou completamente ou problemas de rede Docker."
        FAILED_CHECKS+=("Conexão com o Banco de Dados")
    fi
}

check_folder_permissions() {
    log_header "3. VERIFICANDO PERMISSÕES DE PASTAS"
    local all_ok=true
    for folder in "storage" "bootstrap/cache"; do
        log_info "Verificando permissões da pasta '$folder'..."
        # Executa 'stat' dentro do contêiner para obter o dono (user:group)
        local owner_group
        owner_group=$(docker-compose exec -T app stat -c "%U:%G" "/var/www/html/$folder")

        if [ "$owner_group" == "www-data:www-data" ]; then
            log_success "A pasta '$folder' pertence ao usuário 'www-data:www-data'."
        else
            log_error "A pasta '$folder' pertence a '$owner_group', mas deveria ser 'www-data:www-data'."
            all_ok=false
        fi
    done
    if [ "$all_ok" = false ]; then
        FAILED_CHECKS+=("Permissões de Pastas")
        log_info "Para corrigir, execute o script de instalação novamente: ./install.sh"
    fi
}

# --- Início do Script ---
clear
echo "================================================="
echo "  Diagnóstico do Ambiente - SEMARH Fiscaliza"
echo "================================================="

check_container_status
check_db_connection
check_folder_permissions

log_header "RESULTADO DO DIAGNÓSTICO"

if [ ${#FAILED_CHECKS[@]} -eq 0 ]; then
    log_success "Todos os testes passaram! Seu ambiente parece estar saudável."
else
    log_error "Foram encontradas falhas nos seguintes itens:"
    for check in "${FAILED_CHECKS[@]}"; do
        echo -e "  - $check"
    done
fi
echo