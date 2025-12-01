# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Default Mode (dev or prod)
MODE ?= dev

# Default Service for shell commands
SERVICE ?= backend

# Extra arguments passed to commands
ARGS ?=

# Define Compose Files based on MODE
ifeq ($(MODE), prod)
	COMPOSE_FILE := docker/compose.production.yaml
	COMPOSE_PROJECT_NAME := myapp_prod
else
	# CHANGED: Now points to docker folder
	COMPOSE_FILE := docker/compose.development.yaml
	COMPOSE_PROJECT_NAME := myapp_dev
endif

# Base Docker Compose Command
COMPOSE := docker compose -f $(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME)

# Color codes for Help Message
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: help up down build logs restart shell ps \
		dev-up dev-down dev-build dev-logs dev-restart dev-shell dev-ps \
		prod-up prod-down prod-build prod-logs prod-restart \
		backend-build backend-install backend-type-check backend-dev \
		backend-shell gateway-shell mongo-shell \
		db-reset db-backup clean clean-all clean-volumes status health

# ==============================================================================
# HELP
# ==============================================================================
help:
	@echo ""
	@echo "${YELLOW}Docker Services:${RESET}"
	@echo "  ${GREEN}up${RESET}             - Start services (use: make up ARGS='backend' or make up MODE=prod)"
	@echo "  ${GREEN}down${RESET}           - Stop services (use: make down MODE=prod)"
	@echo "  ${GREEN}build${RESET}          - Build containers (use: make build ARGS='--no-cache')"
	@echo "  ${GREEN}logs${RESET}           - View logs (use: make logs SERVICE=gateway MODE=prod)"
	@echo "  ${GREEN}restart${RESET}        - Restart services (use: make restart ARGS='mongodb')"
	@echo "  ${GREEN}shell${RESET}          - Open shell (use: make shell SERVICE=gateway)"
	@echo "  ${GREEN}ps${RESET}             - Show running containers"
	@echo ""
	@echo "${YELLOW}Convenience Aliases (Development):${RESET}"
	@echo "  ${GREEN}dev-up${RESET}         - Alias: Start development environment"
	@echo "  ${GREEN}dev-down${RESET}       - Alias: Stop development environment"
	@echo "  ${GREEN}dev-build${RESET}      - Alias: Build development containers"
	@echo "  ${GREEN}dev-logs${RESET}       - Alias: View development logs"
	@echo "  ${GREEN}dev-restart${RESET}    - Alias: Restart development services"
	@echo "  ${GREEN}dev-shell${RESET}      - Alias: Open shell in backend container"
	@echo "  ${GREEN}dev-ps${RESET}         - Alias: Show running development containers"
	@echo "  ${GREEN}backend-shell${RESET}  - Alias: Open shell in backend container"
	@echo "  ${GREEN}gateway-shell${RESET}  - Alias: Open shell in gateway container"
	@echo "  ${GREEN}mongo-shell${RESET}    - Open MongoDB shell (inside mongodb container)"
	@echo ""
	@echo "${YELLOW}Convenience Aliases (Production):${RESET}"
	@echo "  ${GREEN}prod-up${RESET}        - Alias: Start production environment"
	@echo "  ${GREEN}prod-down${RESET}      - Alias: Stop production environment"
	@echo "  ${GREEN}prod-build${RESET}     - Alias: Build production containers"
	@echo "  ${GREEN}prod-logs${RESET}      - Alias: View production logs"
	@echo "  ${GREEN}prod-restart${RESET}   - Alias: Restart production services"
	@echo ""
	@echo "${YELLOW}Backend:${RESET}"
	@echo "  ${GREEN}backend-build${RESET}      - Build backend TypeScript (Local)"
	@echo "  ${GREEN}backend-install${RESET}    - Install backend dependencies (Local)"
	@echo "  ${GREEN}backend-type-check${RESET} - Type check backend code (Local)"
	@echo "  ${GREEN}backend-dev${RESET}        - Run backend in dev mode (Local)"
	@echo ""
	@echo "${YELLOW}Database:${RESET}"
	@echo "  ${GREEN}db-reset${RESET}       - Reset MongoDB database (WARNING: deletes all data)"
	@echo "  ${GREEN}db-backup${RESET}      - Backup MongoDB database (to ./dump)"
	@echo ""
	@echo "${YELLOW}Cleanup:${RESET}"
	@echo "  ${GREEN}clean${RESET}          - Remove containers and networks (Current MODE)"
	@echo "  ${GREEN}clean-all${RESET}      - Remove containers, networks, volumes, and images"
	@echo "  ${GREEN}clean-volumes${RESET}  - Remove all volumes"
	@echo ""
	@echo "${YELLOW}Utilities:${RESET}"
	@echo "  ${GREEN}status${RESET}         - Alias for ps"
	@echo "  ${GREEN}health${RESET}         - Check service health"
	@echo ""

# ==============================================================================
# DOCKER SERVICES
# ==============================================================================
up:
	@echo "Starting services in $(MODE) mode using $(COMPOSE_FILE)..."
	$(COMPOSE) up -d $(ARGS)

down:
	@echo "Stopping services in $(MODE) mode..."
	$(COMPOSE) down $(ARGS)

build:
	@echo "Building images in $(MODE) mode..."
	$(COMPOSE) build $(ARGS)

logs:
	$(COMPOSE) logs -f $(SERVICE)

restart:
	$(COMPOSE) restart $(ARGS)

shell:
	$(COMPOSE) exec $(SERVICE) /bin/sh

ps:
	$(COMPOSE) ps

# ==============================================================================
# CONVENIENCE ALIASES (DEVELOPMENT)
# ==============================================================================
dev-up:
	@make up MODE=dev

dev-down:
	@make down MODE=dev

dev-build:
	@make build MODE=dev

dev-logs:
	@make logs MODE=dev SERVICE=$(SERVICE)

dev-restart:
	@make restart MODE=dev

dev-shell:
	@make shell MODE=dev SERVICE=backend

dev-ps:
	@make ps MODE=dev

backend-shell:
	@make shell SERVICE=backend

gateway-shell:
	@make shell SERVICE=gateway

mongo-shell:
	# CHANGED: Service name updated to 'mongodb'
	$(COMPOSE) exec mongodb mongosh -u root -p root

# ==============================================================================
# CONVENIENCE ALIASES (PRODUCTION)
# ==============================================================================
prod-up:
	@make up MODE=prod

prod-down:
	@make down MODE=prod

prod-build:
	@make build MODE=prod

prod-logs:
	@make logs MODE=prod SERVICE=$(SERVICE)

prod-restart:
	@make restart MODE=prod

# ==============================================================================
# BACKEND (LOCAL NODE COMMANDS)
# ==============================================================================
backend-build:
	cd backend && npm run build

backend-install:
	cd backend && npm install

backend-type-check:
	cd backend && npm run type-check

backend-dev:
	cd backend && npm run dev

# ==============================================================================
# DATABASE
# ==============================================================================
db-reset:
	@echo "${YELLOW}WARNING: This will destroy all data in the database volume.${RESET}"
	@read -p "Are you sure? [y/N] " ans && [ $${ans:-N} = y ]
	$(COMPOSE) down -v
	# CHANGED: Service name updated to 'mongodb'
	$(COMPOSE) up -d mongodb

db-backup:
	@echo "Backing up database..."
	# CHANGED: Service name updated to 'mongodb'
	$(COMPOSE) exec mongodb mongodump --out /dump
	# Note: This assumes you have a volume mapped to /dump or you need to docker cp it out

# ==============================================================================
# CLEANUP
# ==============================================================================
clean:
	$(COMPOSE) down --remove-orphans

clean-all:
	docker system prune -a --volumes -f

clean-volumes:
	$(COMPOSE) down -v

# ==============================================================================
# UTILITIES
# ==============================================================================
status: ps

health:
	$(COMPOSE) ps --format "table {{.Service}}\t{{.State}}\t{{.Status}}"