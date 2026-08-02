#!/bin/bash

# =============================================================================
# Painel de Gerenciamento de Ambiente Docker - SEMARH Fiscaliza
#
# IMPORTANTE: Este é um script Bash (.sh).
# Para executá-lo no Windows, você DEVE usar um terminal compatível, como:
#   - Git Bash (que vem com a instalação do Git for Windows)
#   - WSL (Windows Subsystem for Linux)
#
# Ele não funcionará no CMD ou PowerShell padrão.
# =============================================================================

# Cores para o terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Define a base do comando Docker Compose para incluir o arquivo de override.
# Isso garante que as configurações de desenvolvimento (como o Xdebug) sejam sempre aplicadas.
COMPOSE_COMMAND="docker-compose -f docker-compose.yml -f docker-compose.override.yml"


show_menu() {
    clear
    echo -e "${BLUE}=== SEMARH DESKTOP - Painel de Gerenciamento ===${NC}"
    echo ""
    echo "1) Iniciar Ambiente (Docker Up)"
    echo "2) Parar Ambiente (Docker Down)"
    echo "3) Reiniciar Ambiente"
    echo "4) Ver Logs da Aplicação"
    echo "5) Acessar Terminal do Container (Bash)"
    echo "6) Rodar Migrations (Artisan Migrate)"
    echo "7) Listar Rotas (Artisan Route List)"
    echo "q) Sair"
    echo ""
}

while true; do # Loop infinito
    show_menu
    read -p "Escolha uma opção: " opcao

    case $opcao in
        1)
            echo -e "${GREEN}Iniciando os contêineres...${NC}"
            $COMPOSE_COMMAND up -d --build --remove-orphans
            ;;
        2)
            echo -e "${RED}Parando e removendo os contêineres...${NC}"
            $COMPOSE_COMMAND down
            ;;
        3)
            echo -e "${BLUE}Reiniciando o ambiente...${NC}"
            $COMPOSE_COMMAND restart
            ;;
        4)
            echo -e "${BLUE}Exibindo logs (Pressione Ctrl+C para sair)...${NC}"
            $COMPOSE_COMMAND logs -f app
            ;;
        5)
            # Ajuste o nome do serviço 'app' se no seu docker-compose.yml for diferente (ex: 'web', 'laravel')
            echo -e "${GREEN}Entrando no container da aplicação...${NC}"
            $COMPOSE_COMMAND exec app bash
            ;;
        6)
            echo -e "${BLUE}Rodando as migrações do banco de dados...${NC}"
            $COMPOSE_COMMAND exec app php artisan migrate
            ;;
        7)
            echo -e "${BLUE}Listando rotas da aplicação...${NC}"
            $COMPOSE_COMMAND exec app php artisan route:list
            ;;
        [qQ])
            echo -e "${GREEN}Saindo...${NC}"
            break
            ;;
        *)
            echo -e "${RED}Opção inválida! Tente novamente.${NC}"
            ;;
    esac
    read -p "Pressione [Enter] para continuar..."
done