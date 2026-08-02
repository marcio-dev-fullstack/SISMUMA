#!/bin/bash

# =============================================================================
# Script de Submissão de Alterações - SEMARH Fiscaliza
#
# Versão: 1.0
# Autor: Márcio
#
# Uso: ./subir.sh
#
# Este script automatiza o processo de commit e push seguindo os padrões
# do Conventional Commits e as diretrizes de contribuição do projeto.
# =============================================================================

# --- Configuração de Shell ---
set -e # Sai imediatamente se um comando falhar.

# --- Configuração de Cores e Log ---
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem Cor

log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ ERRO: $1${NC}" >&2; exit 1; }
log_info() { echo -e "${YELLOW}▶ $1${NC}"; }
log_header() { echo -e "\n${BLUE}--- $1 ---${NC}"; }

# --- Funções de Qualidade de Código ---
run_quality_checks() {
    log_header "EXECUTANDO VERIFICAÇÕES DE QUALIDADE"
    
    log_info "Verificando estilo de código com Laravel Pint..."
    if ! ./vendor/bin/pint --test; then
        log_error "O Pint encontrou problemas de estilo. Corrija-os antes de continuar. Você pode rodar './vendor/bin/pint' para corrigir automaticamente."
    fi
    log_success "Código está no padrão do projeto."

    log_info "Analisando código com PHPStan..."
    if ! ./vendor/bin/phpstan analyse --memory-limit=2G; then
        log_error "O PHPStan encontrou erros. Corrija-os antes de continuar."
    fi
    log_success "Análise estática passou com sucesso."
}

# --- Início do Script ---
clear
echo "=================================================" && echo "  Assistente de Submissão Git - SEMARH Fiscaliza" && echo "================================================="
echo

# 1. Verificar se há alterações para commitar
if git diff-index --quiet HEAD --; then
    log_error "Nenhuma alteração encontrada para commitar. Faça suas alterações antes de rodar o script."
fi

# 1.5. Executar verificações de qualidade antes de continuar
run_quality_checks

# 2. Verificar e/ou criar a branch de trabalho
log_header "VERIFICANDO BRANCH DE TRABALHO"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$CURRENT_BRANCH" == "main" ] || [ "$CURRENT_BRANCH" == "master" ]; then
    log_info "Você está na branch principal ($CURRENT_BRANCH). Vamos criar uma nova branch para o seu trabalho."
    
    # Tipo da branch
    echo "Selecione o tipo da nova branch:"
    select BRANCH_TYPE in "feature" "bugfix" "docs" "refactor" "style" "test" "chore"; do
        if [ -n "$BRANCH_TYPE" ]; then
            break
        else
            echo "Opção inválida."
        fi
    done

    # Nome da branch
    read -p "Digite um nome curto para a branch (ex: login-gov-br): " BRANCH_NAME

    # Formata o nome para ser URL-friendly (minúsculas, hífens)
    BRANCH_NAME=$(echo "$BRANCH_NAME" | iconv -t ascii//TRANSLIT | sed -r s/[~\^]+//g | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z)
    
    if [ -z "$BRANCH_NAME" ]; then
        log_error "O nome da branch não pode ser vazio ou conter apenas caracteres especiais."
    fi
    
    NEW_BRANCH_NAME="$BRANCH_TYPE/$BRANCH_NAME"
    
    log_info "Criando e mudando para a nova branch: $NEW_BRANCH_NAME"
    git checkout -b "$NEW_BRANCH_NAME"
    CURRENT_BRANCH=$NEW_BRANCH_NAME
    log_success "Pronto! Agora trabalhando na branch '$CURRENT_BRANCH'."
else
    log_info "Continuando o trabalho na branch existente: $CURRENT_BRANCH"
fi

# 3. Coletar informações para o commit (Conventional Commits)
log_header "CONSTRUINDO A MENSAGEM DE COMMIT"

# Tipo do commit
echo "Selecione o tipo de commit:"
select COMMIT_TYPE in "feat: Nova funcionalidade" "fix: Correção de bug" "docs: Documentação" "style: Formatação de código" "refactor: Refatoração" "test: Adição ou correção de testes" "chore: Tarefas de build, etc."; do
    if [ -n "$COMMIT_TYPE" ]; then
        COMMIT_TYPE=$(echo "$COMMIT_TYPE" | cut -d':' -f1)
        break
    else
        echo "Opção inválida."
    fi
done

# Escopo do commit (opcional)
read -p "Escopo (ex: auth, processos, deploy - opcional): " COMMIT_SCOPE

# Assunto do commit
read -p "Assunto (descrição curta e imperativa): " COMMIT_SUBJECT
if [ -z "$COMMIT_SUBJECT" ]; then
    log_error "O assunto do commit não pode estar vazio."
fi

# Construir a mensagem de commit
if [ -n "$COMMIT_SCOPE" ]; then
    COMMIT_MESSAGE="$COMMIT_TYPE($COMMIT_SCOPE): $COMMIT_SUBJECT"
else
    COMMIT_MESSAGE="$COMMIT_TYPE: $COMMIT_SUBJECT"
fi

log_info "Mensagem de commit gerada: $COMMIT_MESSAGE"

# 4. Executar os comandos Git
log_header "EXECUTANDO COMANDOS GIT"

log_info "Adicionando todos os arquivos modificados (git add .)..."
git add .
log_success "Arquivos adicionados."

log_info "Realizando o commit..."
git commit -m "$COMMIT_MESSAGE"
log_success "Commit realizado com sucesso."

log_header "ATUALIZANDO BRANCH E ENVIANDO"

# Detecta o remote principal (upstream ou origin)
if git remote | grep -q '^upstream$'; then
    MAIN_REMOTE="upstream"
else
    log_info "Remote 'upstream' não encontrado. Usando 'origin' como principal."
    MAIN_REMOTE="origin"
fi

log_info "Buscando as últimas alterações de '$MAIN_REMOTE/main'..."
git fetch $MAIN_REMOTE main

echo "Como você deseja integrar as alterações da 'main' na sua branch?"
echo "(Rebase é o recomendado pelo projeto para manter o histórico linear)"

select UPDATE_STRATEGY in "Rebase (Recomendado)" "Merge"; do
    if [ -n "$UPDATE_STRATEGY" ]; then
        break
    else
        echo "Opção inválida."
    fi
done

if [[ "$UPDATE_STRATEGY" == "Rebase"* ]]; then
    log_info "Executando rebase com '$MAIN_REMOTE/main'..."
    if ! git rebase "$MAIN_REMOTE/main"; then
        log_error "Conflito durante o rebase. Resolva os conflitos e depois execute 'git rebase --continue'. Para abortar, use 'git rebase --abort'."
    fi
    log_success "Rebase concluído."
    log_info "Enviando alterações para 'origin/$CURRENT_BRANCH'..."
    # Usa --force-with-lease se a branch já existir no remoto, senão faz um push normal com -u
    if git ls-remote --exit-code --heads origin "$CURRENT_BRANCH" > /dev/null; then
        git push --force-with-lease origin "$CURRENT_BRANCH"
    else
        git push -u origin "$CURRENT_BRANCH"
    fi
else
    log_info "Executando merge com '$MAIN_REMOTE/main'..."
    git merge "$MAIN_REMOTE/main"
    log_success "Merge concluído."
    log_info "Enviando alterações para 'origin/$CURRENT_BRANCH'..."
    git push -u origin "$CURRENT_BRANCH"
fi
log_success "Push realizado com sucesso!"

# --- Finalização ---
echo
log_header "CRIANDO PULL REQUEST"

# Função para extrair a URL base do repositório (funciona com SSH e HTTPS)
get_repo_url() {
    local remote_url
    remote_url=$(git config --get remote.origin.url)
    if [[ $remote_url == git@* ]]; then
        # Converte git@github.com:user/repo.git para https://github.com/user/repo
        echo "$remote_url" | sed -e 's/:/\//' -e 's/git@/https:///' -e 's/\.git$//'
    elif [[ $remote_url == https://* ]]; then
        # Remove o .git do final, se existir
        echo "$remote_url" | sed -e 's/\.git$//'
    else
        log_error "Não foi possível determinar a URL do repositório a partir do remote 'origin'."
        return 1
    fi
}

REPO_BASE_URL=$(get_repo_url)
PR_URL="$REPO_BASE_URL/pull/new/$CURRENT_BRANCH"

log_success "Tudo pronto para criar o Pull Request!"
echo -e "Use o link abaixo:"
echo -e "${BLUE}$PR_URL${NC}"
echo ""

read -p "Deseja abrir o link no navegador agora? [S/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ || $REPLY == "" ]]; then
    # Tenta abrir o link de forma cross-platform
    if command -v xdg-open &> /dev/null; then # Linux
        xdg-open "$PR_URL"
    elif command -v open &> /dev/null; then # macOS
        open "$PR_URL"
    elif command -v start &> /dev/null; then # Windows
        start "$PR_URL"
    else
        log_error "Não foi encontrado um comando para abrir o navegador. Copie o link manualmente."
    fi
fi

exit 0