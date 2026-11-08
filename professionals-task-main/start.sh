#!/bin/bash

# Переходим в директорию, где лежит скрипт
cd "$(dirname "$0")"

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Запуск проекта ТОиР-Проф ===${NC}"

# Функция для корректного завершения процессов при нажатии Ctrl+C
cleanup() {
    echo -e "\n${BLUE}Остановка процессов...${NC}"
    kill $(jobs -p) 2>/dev/null
    exit
}
trap cleanup SIGINT SIGTERM

# 1. Запуск API (Backend)
echo -e "${GREEN}-> Запуск API на http://localhost:5080...${NC}"
dotnet run --project src/api &
API_PID=$!

# Ждем 3 секунды, чтобы API успело инициализироваться
sleep 3

# 2. Запуск Web-клиента (Frontend)
echo -e "${GREEN}-> Запуск Web-клиента на http://localhost:5071...${NC}"
cd src/web

# Проверяем, установлены ли зависимости (папка node_modules)
if [ ! -d "node_modules" ]; then
    echo "Установка npm зависимостей (это может занять время)..."
    npm install
fi

npm run dev &
WEB_PID=$!

echo -e "\n${BLUE}=== Всё запущено! Для остановки нажмите Ctrl+C ===${NC}"

# Ожидаем завершения процессов
wait $API_PID $WEB_PID
