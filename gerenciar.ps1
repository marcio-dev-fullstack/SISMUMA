<#
.SYNOPSIS
    Painel de Gerenciamento de Ambiente Docker - SEMARH Fiscaliza (Versão PowerShell Robusta)
.DESCRIPTION
    Este script fornece um menu interativo para gerenciar os contêineres Docker do projeto
    SEMARH Fiscaliza diretamente do PowerShell no Windows.
.NOTES
    Autor: Gemini Code Assist
    Versão: 2.0
    Melhorias:
    - Detecta e usa 'docker compose' (v2) ou 'docker-compose' (v1).
    - Utiliza o arquivo 'docker-compose.override.yml' para garantir o ambiente de desenvolvimento.
    - Adiciona novas opções de gerenciamento (rebuild, cache, seed, rotas).
    - Mostra o status dos contêineres no menu.
#>

# --- Configuração Inicial ---
$ErrorActionPreference = "Stop" # Para o script em caso de erro

# --- Detecção do Comando Docker Compose ---
# Define os arquivos a serem usados, incluindo o override para desenvolvimento.
$ComposeFiles = "-f docker-compose.yml -f docker-compose.override.yml"
$ComposeCommand = "docker-compose" # Padrão para v1

try {
    # Tenta executar o comando da v2. Se funcionar, usa-o.
    Invoke-Expression "docker compose version" | Out-Null
    $ComposeCommand = "docker compose"
}
catch {
    # Se falhar, continua usando o padrão 'docker-compose' (v1).
    Write-Host "Usando docker-compose (v1). Considere atualizar o Docker Desktop para a versão mais recente." -ForegroundColor Yellow
}

# --- Funções Auxiliares ---

function Get-ContainerStatus {
    # Verifica se o contêiner 'app' está rodando
    $status = Invoke-Expression "$ComposeCommand $ComposeFiles ps -q app"
    if ($status) {
        return "(Rodando)"
    }
    else {
        return "(Parado)"
    }
}

function Show-Menu {
    Clear-Host
    $status = Get-ContainerStatus
    Write-Host "=== SEMARH DESKTOP - Painel de Gerenciamento (PowerShell) $status ===" -ForegroundColor Blue
    Write-Host ""
    Write-Host " 1) Iniciar Ambiente (Up)"
    Write-Host " 2) Parar Ambiente (Down)"
    Write-Host " 3) Reiniciar Ambiente (Restart)"
    Write-Host " 4) Reconstruir Ambiente (Down + Up --build)"
    Write-Host "--------------------------------------------"
    Write-Host " 5) Ver Logs da Aplicação (Logs)"
    Write-Host " 6) Acessar Terminal do Contêiner (Bash)"
    Write-Host "--------------------------------------------"
    Write-Host " 7) Rodar Migrations (Migrate)"
    Write-Host " 8) Rodar Seeders (Seed)"
    Write-Host " 9) Limpar Caches (Optimize:clear)"
    Write-Host "10) Limpar Cache da Aplicação (Cache:clear)"
    Write-Host "11) Listar Rotas (Route:list)"
    Write-Host "--------------------------------------------"
    Write-Host "q) Sair"
    Write-Host ""
}

# Função para executar comandos Artisan de forma limpa
function Artisan {
    param($command)
    Write-Host "Executando: php artisan $command ..." -ForegroundColor Cyan
    Invoke-Expression "$ComposeCommand $ComposeFiles exec app php artisan $command"
}

while ($true) {
    Show-Menu
    $opcao = Read-Host "Escolha uma opção e pressione Enter"

    switch ($opcao) {
        "1" {
            Write-Host "Iniciando os contêineres..." -ForegroundColor Green
            Invoke-Expression "$ComposeCommand $ComposeFiles up -d"
            Read-Host "Pressione Enter para continuar..."
        }
        "2" {
            Write-Host "Parando e removendo os contêineres..." -ForegroundColor Red
            Invoke-Expression "$ComposeCommand $ComposeFiles down"
            Read-Host "Pressione Enter para continuar..."
        }
        "3" {
            Write-Host "Reiniciando os contêineres..." -ForegroundColor Cyan
            Invoke-Expression "$ComposeCommand $ComposeFiles restart"
            Read-Host "Pressione Enter para continuar..."
        }
        "4" {
            Write-Host "Parando e reconstruindo os contêineres..." -ForegroundColor Yellow
            Invoke-Expression "$ComposeCommand $ComposeFiles down"
            Invoke-Expression "$ComposeCommand $ComposeFiles up -d --build --remove-orphans"
            Read-Host "Pressione Enter para continuar..."
        }
        "5" {
            Write-Host "Exibindo logs (Pressione Ctrl+C para sair)..." -ForegroundColor Cyan
            # O -NoExit não funciona bem aqui, então o usuário precisa fechar a janela ou usar Ctrl+C
            Start-Process wt -ArgumentList "nt", "--", "powershell", "-Command", "$ComposeCommand $ComposeFiles logs -f app"
        }
        "6" {
            Write-Host "Entrando no contêiner da aplicação... Digite 'exit' para sair." -ForegroundColor Green
            # Abre um novo terminal (Windows Terminal) para uma melhor experiência
            Start-Process wt -ArgumentList "nt", "--", "powershell", "-Command", "$ComposeCommand $ComposeFiles exec app bash"
        }
        "7" {
            Artisan "migrate"
            Read-Host "Pressione Enter para continuar..."
        }
        "8" {
            Artisan "db:seed"
            Read-Host "Pressione Enter para continuar..."
        }
        "9" {
            Artisan "optimize:clear"
            Read-Host "Pressione Enter para continuar..."
        }
        "10" {
            Write-Host "Limpando o cache da aplicação..." -ForegroundColor Green
            Artisan "cache:clear"
            Read-Host "Pressione Enter para continuar..."
        }
        "10" {
            # Esta opção foi reenumerada para "11"
            Artisan "route:list"
            Read-Host "Pressione Enter para continuar..."
        }
        "q" {
            Write-Host "Saindo..." -ForegroundColor Green
            return
        }
        default {
            Write-Host "Opção inválida! Tente novamente." -ForegroundColor Red
            Read-Host "Pressione Enter para continuar..."
        }
    }
}