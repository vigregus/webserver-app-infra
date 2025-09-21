# Makefile для управления тестовым приложением

.PHONY: help build run stop clean logs shell test dev-backend dev-frontend

# Переменные
BACKEND_DIR = app-backend
FRONTEND_DIR = app-frontend

# Помощь
help: ## Показать справку
	@echo "Доступные команды:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Docker команды
build: ## Собрать все контейнеры
	docker-compose build

run: ## Запустить все сервисы
	docker-compose up -d

stop: ## Остановить все сервисы
	docker-compose down

restart: ## Перезапустить все сервисы
	docker-compose restart

logs: ## Показать логи всех сервисов
	docker-compose logs -f

logs-backend: ## Показать логи бэкенда
	docker-compose logs -f backend

logs-frontend: ## Показать логи фронтенда
	docker-compose logs -f frontend

# Команды для разработки
dev-backend: ## Запустить бэкенд в режиме разработки
	cd $(BACKEND_DIR) && python -m venv venv && source venv/bin/activate && pip install -r requirements.txt && python main.py

dev-frontend: ## Запустить фронтенд в режиме разработки
	cd $(FRONTEND_DIR) && npm install && npm run dev

dev: ## Запустить оба сервиса в режиме разработки
	@echo "Запуск бэкенда в режиме разработки..."
	cd $(BACKEND_DIR) && python -m venv venv && source venv/bin/activate && pip install -r requirements.txt && python main.py &
	@echo "Запуск фронтенда в режиме разработки..."
	cd $(FRONTEND_DIR) && npm install && npm run dev

# Управление контейнерами
shell-backend: ## Подключиться к контейнеру бэкенда
	docker-compose exec backend /bin/bash

shell-frontend: ## Подключиться к контейнеру фронтенда
	docker-compose exec frontend /bin/sh

# Тестирование
test-backend: ## Запустить тесты бэкенда
	cd $(BACKEND_DIR) && python -m pytest

test-frontend: ## Запустить тесты фронтенда
	cd $(FRONTEND_DIR) && npm test

test: ## Запустить все тесты
	$(MAKE) test-backend
	$(MAKE) test-frontend

# Установка зависимостей
install-backend: ## Установить зависимости бэкенда
	cd $(BACKEND_DIR) && python -m venv venv && source venv/bin/activate && pip install -r requirements.txt

install-frontend: ## Установить зависимости фронтенда
	cd $(FRONTEND_DIR) && npm install

install: ## Установить все зависимости
	$(MAKE) install-backend
	$(MAKE) install-frontend

# Очистка
clean: ## Очистить все контейнеры и образы
	docker-compose down -v --rmi all
	docker system prune -f

clean-backend: ## Очистить бэкенд
	cd $(BACKEND_DIR) && rm -rf venv __pycache__ .pytest_cache

clean-frontend: ## Очистить фронтенд
	cd $(FRONTEND_DIR) && rm -rf node_modules dist .vite

clean-all: ## Полная очистка
	$(MAKE) clean
	$(MAKE) clean-backend
	$(MAKE) clean-frontend

# Проверка статуса
status: ## Показать статус сервисов
	docker-compose ps

health: ## Проверить здоровье сервисов
	@echo "Проверка бэкенда..."
	@curl -f http://localhost:8000/health || echo "Бэкенд недоступен"
	@echo "Проверка фронтенда..."
	@curl -f http://localhost:3000 || echo "Фронтенд недоступен"

# Быстрый старт
quick-start: install build run ## Быстрый старт: установка, сборка, запуск
	@echo "Приложение запущено!"
	@echo "Фронтенд: http://localhost:3000"
	@echo "Бэкенд: http://localhost:8000"
	@echo "API документация: http://localhost:8000/docs"

# Обновление
update: ## Обновить зависимости
	cd $(BACKEND_DIR) && source venv/bin/activate && pip install --upgrade -r requirements.txt
	cd $(FRONTEND_DIR) && npm update

# Линтинг
lint-backend: ## Линтинг бэкенда
	cd $(BACKEND_DIR) && source venv/bin/activate && python -m flake8 . --max-line-length=100

lint-frontend: ## Линтинг фронтенда
	cd $(FRONTEND_DIR) && npm run lint

lint: ## Линтинг всего проекта
	$(MAKE) lint-backend
	$(MAKE) lint-frontend
