# 🚀 Тестовое приложение

Полнофункциональное веб-приложение с React фронтендом и Python FastAPI бэкендом для управления пользователями.

## 📁 Структура проекта

```
minicube/
├── app-backend/              # Python FastAPI бэкенд
│   ├── main.py              # Основное приложение
│   ├── requirements.txt     # Python зависимости
│   └── Dockerfile          # Docker конфигурация
├── app-frontend/             # React TypeScript фронтенд
│   ├── src/                 # Исходный код React
│   │   ├── components/      # React компоненты
│   │   ├── hooks/          # Кастомные хуки
│   │   ├── api/            # API клиент
│   │   └── types/          # TypeScript типы
│   ├── public/             # Статические файлы
│   ├── package.json        # Node.js зависимости
│   ├── Dockerfile          # Docker конфигурация
│   └── nginx.conf          # Nginx конфигурация
├── docker-compose.yml       # Оркестрация сервисов
├── Makefile                # Удобные команды
└── README.md               # Документация
```

## 🛠️ Технологии

### Backend
- **Python 3.11** - основной язык
- **FastAPI** - веб-фреймворк
- **Uvicorn** - ASGI сервер
- **Pydantic** - валидация данных
- **CORS** - поддержка кросс-доменных запросов

### Frontend
- **React 18** - UI библиотека
- **TypeScript** - типизация
- **Vite** - сборщик и dev сервер
- **Axios** - HTTP клиент
- **CSS3** - стилизация

### DevOps
- **Docker** - контейнеризация
- **Docker Compose** - оркестрация
- **Nginx** - веб-сервер для фронтенда
- **Make** - автоматизация

## 🚀 Быстрый старт

### 1. Клонирование и установка
```bash
# Клонировать репозиторий
git clone <repository-url>
cd minicube

# Быстрый старт (установка + сборка + запуск)
make quick-start
```

### 2. Ручная установка
```bash
# Установить зависимости
make install

# Собрать контейнеры
make build

# Запустить приложение
make run
```

### 3. Проверка работы
- **Фронтенд**: http://localhost:3000
- **Бэкенд**: http://localhost:8000
- **API документация**: http://localhost:8000/docs

## 📋 Доступные команды

### Основные команды
```bash
make help           # Показать справку
make quick-start    # Быстрый старт
make build          # Собрать контейнеры
make run            # Запустить сервисы
make stop           # Остановить сервисы
make restart        # Перезапустить сервисы
make status         # Показать статус
make health         # Проверить здоровье
```

### Разработка
```bash
make dev            # Запуск в режиме разработки
make dev-backend    # Только бэкенд (локально)
make dev-frontend   # Только фронтенд (локально)
make install        # Установить зависимости
make update         # Обновить зависимости
```

### Логи и отладка
```bash
make logs           # Логи всех сервисов
make logs-backend   # Логи бэкенда
make logs-frontend  # Логи фронтенда
make shell-backend  # Подключиться к бэкенду
make shell-frontend # Подключиться к фронтенду
```

### Тестирование и качество
```bash
make test           # Запустить все тесты
make test-backend   # Тесты бэкенда
make test-frontend  # Тесты фронтенда
make lint           # Линтинг всего проекта
make lint-backend   # Линтинг бэкенда
make lint-frontend  # Линтинг фронтенда
```

### Очистка
```bash
make clean          # Очистить контейнеры
make clean-backend  # Очистить бэкенд
make clean-frontend # Очистить фронтенд
make clean-all      # Полная очистка
```

## 🔧 API Endpoints

### Пользователи
- `GET /api/users` - получить всех пользователей
- `GET /api/users/{id}` - получить пользователя по ID
- `POST /api/users` - создать пользователя
- `PUT /api/users/{id}` - обновить пользователя
- `DELETE /api/users/{id}` - удалить пользователя

### Статистика
- `GET /api/stats` - получить статистику пользователей

### Система
- `GET /` - корневой эндпоинт
- `GET /health` - проверка здоровья

## 📊 Функциональность

### Фронтенд
- ✅ **Список пользователей** - просмотр всех пользователей
- ✅ **Создание пользователя** - форма добавления
- ✅ **Редактирование** - изменение данных пользователя
- ✅ **Удаление** - удаление с подтверждением
- ✅ **Статистика** - возрастные группы и средний возраст
- ✅ **Валидация** - проверка данных на клиенте
- ✅ **Обработка ошибок** - показ ошибок API
- ✅ **Адаптивный дизайн** - работа на мобильных устройствах

### Бэкенд
- ✅ **RESTful API** - стандартные HTTP методы
- ✅ **Валидация данных** - Pydantic модели
- ✅ **CORS поддержка** - работа с фронтендом
- ✅ **Автодокументация** - Swagger UI
- ✅ **Обработка ошибок** - детальные сообщения
- ✅ **Статистика** - аналитика пользователей

## 🐳 Docker

### Сборка
```bash
# Собрать все сервисы
docker-compose build

# Собрать конкретный сервис
docker-compose build backend
docker-compose build frontend
```

### Запуск
```bash
# Запустить в фоне
docker-compose up -d

# Запустить с логами
docker-compose up

# Запустить конкретный сервис
docker-compose up backend
```

### Остановка
```bash
# Остановить сервисы
docker-compose down

# Остановить с удалением volumes
docker-compose down -v
```

## 🔍 Разработка

### Локальная разработка бэкенда
```bash
cd app-backend
python -m venv venv
source venv/bin/activate  # Linux/Mac
# или
venv\Scripts\activate     # Windows
pip install -r requirements.txt
python main.py
```

### Локальная разработка фронтенда
```bash
cd app-frontend
npm install
npm run dev
```

### Настройка переменных окружения
Создайте `.env` файл в `app-frontend/`:
```env
VITE_API_URL=http://localhost:8000
```

## 🧪 Тестирование

### Бэкенд тесты
```bash
cd app-backend
source venv/bin/activate
pip install pytest
pytest
```

### Фронтенд тесты
```bash
cd app-frontend
npm install
npm test
```

## 📝 Линтинг

### Python (flake8)
```bash
cd app-backend
pip install flake8
flake8 . --max-line-length=100
```

### TypeScript/React (ESLint)
```bash
cd app-frontend
npm run lint
```

## 🚨 Troubleshooting

### Проблемы с Docker
```bash
# Проверить статус контейнеров
docker-compose ps

# Посмотреть логи
docker-compose logs backend
docker-compose logs frontend

# Пересобрать контейнеры
docker-compose down
docker-compose build --no-cache
docker-compose up
```

### Проблемы с портами
Если порты 3000 или 8000 заняты:
```bash
# Изменить порты в docker-compose.yml
ports:
  - "3001:80"  # фронтенд
  - "8001:8000"  # бэкенд
```

### Проблемы с зависимостями
```bash
# Очистить и переустановить
make clean-all
make install
make build
```

## 📚 Дополнительные ресурсы

- [FastAPI документация](https://fastapi.tiangolo.com/)
- [React документация](https://react.dev/)
- [TypeScript документация](https://www.typescriptlang.org/)
- [Docker документация](https://docs.docker.com/)
- [Vite документация](https://vitejs.dev/)

## 🤝 Участие в разработке

1. Форкните репозиторий
2. Создайте ветку для новой функции
3. Внесите изменения
4. Добавьте тесты
5. Создайте Pull Request

## 📄 Лицензия

MIT License - см. файл LICENSE для деталей.

---

**Создано с ❤️ для демонстрации современных веб-технологий**