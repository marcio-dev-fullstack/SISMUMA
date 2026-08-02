# 🌳 SISMUMA Sistema Municipal de Meio Ambiente 1.0

![Laravel](https://img.shields.io/badge/Laravel-12.x-FF2D20?style=for-the-badge&logo=laravel)
![PHP](https://img.shields.io/badge/PHP-8.3-777BB4?style=for-the-badge&logo=php)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker)
![Livewire](https://img.shields.io/badge/Livewire-3.x-4E56A6?style=for-the-badge&logo=livewire)

O **SISMUMA Sistema Municipal de Meio Ambiente 1.0** é um sistema integrado e moderno para gestão e fiscalização ambiental, projetado para secretarias municipais de meio ambiente. Ele digitaliza e otimiza processos, desde o licenciamento até a fiscalização em campo, utilizando tecnologias de ponta para garantir eficiência, transparência e segurança.

---

## ✨ Funcionalidades Principais

- **Licenciamento Ambiental Digital:** Fluxo completo para Licenças Prévias (LP), de Instalação (LI) e de Operação (LO).
- **Fiscalização Inteligente:** Aplicativo mobile para agentes em campo com operação offline, geolocalização e geração de autos digitais.
- **Portal do Cidadão:** Permite que cidadãos e empresas solicitem licenças, acompanhem processos e registrem denúncias.
- **Assistentes de IA:** Módulos de Inteligência Artificial (`IA Analista`, `IA Fiscal`, `IA Jurídica`) para apoiar na tomada de decisão.
- **Business Intelligence (BI):** Dashboards interativos para gestores monitorarem indicadores ambientais e de desempenho (ESG).
- **Geoprocessamento:** Integração com camadas de mapas (MapBiomas, INPE) e um GeoServer para análise espacial.
- **Segurança e Auditoria:** Uso de Blockchain para registrar um histórico imutável das principais ações do sistema, garantindo a integridade dos dados.

---

## 🛠️ Arquitetura e Tecnologia

O sistema é construído sobre uma stack de tecnologia robusta e escalável, pensada para alta performance e manutenibilidade.

**Tecnologias Utilizadas:**

- **Backend:** Laravel 12 (PHP 8.3)
- **Frontend:** Blade, Livewire 3 e Alpine.js
- **Banco de Dados:** PostgreSQL 16 com extensão PostGIS
- **Filas e Cache:** Redis
- **Servidor GIS:** GeoServer
- **Containerização:** Docker e Docker Compose

### Diagramas da Arquitetura

Para uma visão aprofundada da arquitetura, fluxos de dados e modelo de banco de dados, consulte nosso documento de diagramas. Eles foram criados com o modelo C4 e Mermaid.

➡️ **Acessar Diagramas da Arquitetura**

---

## 🚀 Começando

A maneira mais rápida e recomendada de configurar o ambiente de desenvolvimento é utilizando **Docker**, que garante um ambiente padronizado e isolado.

### Instalação com Docker (Recomendado)

Este método encapsula todos os serviços necessários (PHP, Nginx, PostgreSQL, Redis) em contêineres.

> **Pré-requisitos:** Git, Docker e Docker Compose.

Para instruções detalhadas, siga o manual de instalação com Docker:

➡️ **Manual de Instalação com Docker**

### Instalação Manual

Se você prefere configurar o ambiente localmente sem o Docker, ou está em um ambiente que não o suporta, siga o guia de instalação manual.

> **Pré-requisitos:** Git, PHP 8.3+, Composer, PostgreSQL 14+ (com PostGIS), Node.js.

➡️ **Manual de Instalação Manual**

---

## 💻 Ambiente de Desenvolvimento

Este projeto está configurado para oferecer uma ótima experiência de desenvolvimento no **Visual Studio Code**.

### Extensões Recomendadas

Ao abrir o projeto no VS Code, você receberá uma notificação para instalar as extensões recomendadas, que incluem ferramentas para PHP, Laravel, Docker, Livewire e muito mais. A lista completa está no arquivo `.vscode/extensions.json`.

### Configurações do Workspace

O arquivo `.vscode/settings.json` padroniza algumas configurações, como o uso do `Git Bash` como terminal padrão no Windows, para garantir a compatibilidade dos scripts do projeto.

---

## 🤝 Como Contribuir

Agradecemos o interesse em contribuir com o SEMARH Fiscaliza! Para garantir um processo de contribuição tranquilo e padronizado, pedimos que você leia nosso guia de contribuição.

➡️ **Acessar o Guia de Contribuição (`CONTRIBUTING.md`)**

---

## 📄 Licença

Este projeto é distribuído sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

> Este projeto é um protótipo e um portfólio de desenvolvimento. A implementação de algumas funcionalidades, como a integração real com Blockchain e APIs governamentais, é simulada.
