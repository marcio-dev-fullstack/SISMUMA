#!/bin/bash

# =============================================================================
# Script de Restauração de Backup Criptografado para PostgreSQL
#
# Versão: 1.0
# Autor: Gemini Code Assist
#
# Uso: ./restore.sh <caminho_para_o_arquivo.gpg>
#
# Este script restaura um backup de banco de dados criptografado para o
# contêiner Docker do PostgreSQL.
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
log_error() { echo -e "${RED}❌ ERRO: $1${NC}" >&2; }
log_info() { echo -e "${YELLOW}▶ $1${NC}"; }
log_header() { echo -e "\n${BLUE}--- $1 ---${NC}"; }

# --- Verificações Iniciais ---

if [ -z "$1" ]; then
    log_error "Uso: ./restore.sh <caminho_para_o_arquivo_de_backup.gpg>"
    exit 1
fi

ENCRYPTED_BACKUP_PATH=$1

if [ ! -f "$ENCRYPTED_BACKUP_PATH" ]; then
    log_error "O arquivo de backup '$ENCRYPTED_BACKUP_PATH' não foi encontrado."
    exit 1
fi

# Carrega variáveis do .env para obter as senhas
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    log_error "Arquivo .env não encontrado. Não é possível obter as senhas."
    exit 1
fi

if [ -z "$DB_BACKUP_PASSPHRASE" ]; then
    log_error "A variável DB_BACKUP_PASSPHRASE não está definida no seu arquivo .env."
    exit 1
fi

# --- Início do Script ---
clear
echo "================================================="
echo "  Restaurador de Backup - SEMARH Fiscaliza"
echo "================================================="
echo

log_header "AVISO DE SEGURANÇA"
log_info "Esta operação irá APAGAR TODOS OS DADOS do banco de dados '${DB_DATABASE}' e substituí-los pelo conteúdo do backup."
read -p "Você tem certeza que deseja continuar? (s/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    log_error "Restauração cancelada pelo usuário."
    exit 1
fi

log_header "1. DESCRIPTOGRAFANDO O BACKUP"
DECRYPTED_FILE_GZ="backup-decrypted.sql.gz"
gpg --batch --yes --decrypt --passphrase "$DB_BACKUP_PASSPHRASE" --output "$DECRYPTED_FILE_GZ" "$ENCRYPTED_BACKUP_PATH"
log_success "Backup descriptografado para: $DECRYPTED_FILE_GZ"

log_header "2. RESTAURANDO O BANCO DE DADOS"
log_info "Enviando o backup para o contêiner e iniciando a restauração..."
# Descompacta o arquivo e o envia (pipe) para o comando pg_restore dentro do contêiner 'db'
gunzip < "$DECRYPTED_FILE_GZ" | docker-compose exec -T db pg_restore -U "${DB_USERNAME}" -d "${DB_DATABASE}" --clean --if-exists

log_header "3. LIMPEZA"
rm "$DECRYPTED_FILE_GZ"
log_success "Arquivo de backup descriptografado removido."

echo
log_success "RESTAURAÇÃO CONCLUÍDA COM SUCESSO!"
echo

exit 0