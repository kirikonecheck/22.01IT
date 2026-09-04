#!/bin/bash
# Скрипт для анализа популярных репозиториев на GitHub

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Проверка наличия curl
if ! command -v curl &> /dev/null; then
    echo -e "${RED}❌ Ошибка: curl не установлен!${NC}"
    echo "Установите curl: sudo apt-get install curl (Ubuntu/Debian)"
    exit 1
fi

# Проверка наличия jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ Ошибка: jq не установлен!${NC}"
    echo "Установите jq: sudo apt-get install jq (Ubuntu/Debian)"
    exit 1
fi

# Проверка аргументов
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Ошибка: Укажите имя репозитория${NC}"
    echo "Пример: ./github-stats.sh tensorflow/tensorflow"
    exit 1
fi

REPO=$1
API_URL="https://api.github.com/repos/$REPO"

# Заголовок
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  ${BOLD}🚀 GitHub Repository Analyzer${NC}${CYAN}                ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Запрос к GitHub API
echo -e "${BLUE}📡 Запрос к GitHub API...${NC}"
RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL" 2>/dev/null)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n -1)

# Проверка ответа API
if [ -z "$BODY" ] || [ "$BODY" = "null" ]; then
    echo -e "${RED}❌ Ошибка: Неверный ответ от API${NC}"
    exit 1
fi

# Проверка HTTP статуса
if [ "$HTTP_CODE" -eq 404 ]; then
    echo -e "${RED}❌ Ошибка: Репозиторий '$REPO' не найден${NC}"
    exit 1
elif [ "$HTTP_CODE" -eq 403 ]; then
    echo -e "${RED}❌ Ошибка: Превышен лимит запросов к API${NC}"
    echo -e "${YELLOW}💡 Попробуйте позже или укажите токен для аутентификации${NC}"
    exit 1
elif [ "$HTTP_CODE" -ne 200 ]; then
    echo -e "${RED}❌ Ошибка: API вернул код $HTTP_CODE${NC}"
    exit 1
fi

# Парсинг данных
NAME=$(echo "$BODY" | jq -r '.full_name // "Неизвестно"')
STARS=$(echo "$BODY" | jq -r '.stargazers_count // 0')
FORKS=$(echo "$BODY" | jq -r '.forks_count // 0')
ISSUES=$(echo "$BODY" | jq -r '.open_issues_count // 0')
AUTHOR=$(echo "$BODY" | jq -r '.owner.login // "Неизвестно"')
UPDATED=$(echo "$BODY" | jq -r '.updated_at // ""')
DESCRIPTION=$(echo "$BODY" | jq -r '.description // "Нет описания"')

# Определение активности
if [ -n "$UPDATED" ]; then
    UPDATED_SEC=$(date -d "$UPDATED" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$UPDATED" +%s 2>/dev/null)
    NOW=$(date +%s)
    DIFF=$((NOW - UPDATED_SEC))
    
    if [ $DIFF -lt 86400 ]; then
        ACTIVITY="${GREEN}Высокая${NC} (обновлён менее дня назад)"
    elif [ $DIFF -lt 604800 ]; then
        ACTIVITY="${YELLOW}Средняя${NC} (обновлён менее недели назад)"
    else
        ACTIVITY="${RED}Низкая${NC} (обновлён более недели назад)"
    fi
else
    ACTIVITY="${YELLOW}Неизвестно${NC}"
fi

# Вывод результатов
echo -e "${BOLD}📦 Репозиторий:${NC} $NAME"
echo -e "${BOLD}📝 Описание:${NC} $DESCRIPTION"
echo -e "${YELLOW}⭐ Звёзды:       ${BOLD}$(printf "%'d" $STARS)${NC}  (⭐)"
echo -e "${GREEN}🔀 Форки:        ${BOLD}$(printf "%'d" $FORKS)${NC}   (🔀)"

# Цвет для issues
if [ $ISSUES -gt 100 ]; then
    echo -e "${RED}🐛 Open Issues:  ${BOLD}$(printf "%'d" $ISSUES)${NC}    (🐛) ${RED}⚠️ Много открытых issues!${NC}"
else
    echo -e "${YELLOW}🐛 Open Issues:  ${BOLD}$(printf "%'d" $ISSUES)${NC}    (🐛)"
fi

echo -e "${BLUE}👤 Автор:        ${BOLD}$AUTHOR${NC}"
echo -e "📊 Активность:   $ACTIVITY"
echo ""

# Дополнительная статистика
echo -e "${CYAN}📈 Дополнительная статистика:${NC}"
WATCHERS=$(echo "$BODY" | jq -r '.watchers_count // 0')
echo -e "👁️ Наблюдают:     $(printf "%'d" $WATCHERS)"

OPEN_ISSUES=$(echo "$BODY" | jq -r '.open_issues // 0')
echo -e "📋 Всего issues:  $(printf "%'d" $OPEN_ISSUES)"

if [ "$OPEN_ISSUES" -gt 0 ]; then
    PERCENT=$((ISSUES * 100 / OPEN_ISSUES))
    echo -e "📊 % открытых:    ${PERCENT}%"
fi