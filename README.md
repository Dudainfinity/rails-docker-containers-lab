# rails-docker-containers-lab

Aplicação Ruby on Rails 8.1 totalmente containerizada com Docker e Docker Compose. Demonstra como montar um ambiente de desenvolvimento isolado, reproduzível e pronto para escalar — com banco de dados PostgreSQL 15, rede bridge dedicada e persistência de dados via volumes.

---

## Tecnologias

| Tecnologia | Versão |
|---|---|
| Ruby | 3.2 |
| Ruby on Rails | 8.1.3 |
| PostgreSQL | 15 |
| Docker | 24+ |
| Docker Compose | v2+ |
| Puma | 8.x |

---

## Arquitetura

```
Browser (localhost:3000)
        │
        ▼
┌─────────────────────┐        ┌──────────────────────┐
│     rails_app        │◄──────►│   rails_postgres_db  │
│  Rails 8.1 + Puma   │        │   PostgreSQL 15:5432  │
│     porta 3000       │        │   (rede interna)      │
└─────────────────────┘        └──────────────────────┘
        │                               │
        └───────────────────────────────┘
                  rails_network (bridge)
                         │
                  postgres_data (volume)
```

- **rails_app** — container da aplicação Rails, exposto na porta 3000
- **rails_postgres_db** — container PostgreSQL, acessível apenas pela rede interna
- **rails_network** — rede bridge isolada que conecta os dois containers por nome de serviço
- **postgres_data** — volume Docker que persiste os dados entre restarts

---

## Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) 24+
- [Docker Compose](https://docs.docker.com/compose/) v2+

Não é necessário ter Ruby, Rails ou PostgreSQL instalados localmente.

---

## Como rodar

### 1. Clonar o repositório

```bash
git clone https://github.com/Dudainfinity/rails-docker-containers-lab.git
cd rails-docker-containers-lab
```

### 2. Build e inicialização

```bash
docker compose up --build
```

O entrypoint cuida automaticamente de:
- Aguardar o PostgreSQL estar pronto
- Criar o banco e rodar as migrations (`db:prepare`)
- Iniciar o servidor Puma

### 3. Acessar a aplicação

```
http://localhost:3000
```

---

## Comandos úteis

```bash
# Subir em background
docker compose up -d

# Ver logs em tempo real
docker compose logs -f web

# Verificar containers em execução
docker compose ps

# Abrir console Rails dentro do container
docker compose exec web rails console

# Rodar migrations manualmente
docker compose exec web rails db:migrate

# Inspecionar a rede interna
docker network inspect rails_compose_rails_network

# Parar tudo
docker compose down

# Parar e remover volumes (apaga os dados do banco)
docker compose down -v
```

---

## Estrutura do projeto

```
.
├── app/
│   ├── controllers/
│   │   ├── pages_controller.rb     # Landing page
│   │   └── tasks_controller.rb     # CRUD de tarefas
│   ├── models/
│   │   └── task.rb
│   └── views/
│       ├── pages/index.html.erb    # Landing page
│       └── tasks/                  # Views CRUD
├── db/
│   └── migrate/
│       └── 20260506000000_create_tasks.rb
├── bin/
│   └── docker-entrypoint.sh        # Entrypoint com health check + migrations
├── Dockerfile
└── docker-compose.yml
```

---

## Variáveis de ambiente

Configuradas diretamente no `docker-compose.yml` para desenvolvimento:

| Variável | Valor |
|---|---|
| `DATABASE_URL` | `postgres://postgres:password@db:5432/rails_db` |
| `RAILS_ENV` | `development` |

---

## Features

- **Landing page** com animação de partículas em canvas, efeito de digitação e status em tempo real (versão Rails, Ruby, ambiente, conexão com banco)
- **CRUD de tarefas** — criar, listar, editar, marcar como concluída e remover
- **Health check** no container do PostgreSQL com `pg_isready`
- **Entrypoint** com retry automático antes de iniciar o servidor
- **Rede bridge isolada** — o banco não fica exposto externamente
- **Volume persistente** — dados do PostgreSQL sobrevivem a restarts

---

## Desenvolvido por

**Maria Eduarda** — [github.com/Dudainfinity](https://github.com/Dudainfinity)
