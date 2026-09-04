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

# Функция для проверки наличия команды с диагностикой
check_command() {
    local cmd=$1
    local install_msg=$2
    
    # Проверяем через command -v
    if command -v "$cmd" &> /dev/null; then
        return 0
    fi
    
    # Дополнительная проверка для Windows (Git Bash)
    if command -v "$cmd.exe" &> /dev/null; then
        return 0
    fi
    
    # Проверяем через which (альтернативный метод)
    if which "$cmd" &> /dev/null; then
        return 0
    fi
    
    echo -e "${RED}❌ Ошибка: $cmd не найден!${NC}"
    echo -e "${YELLOW}💡 $install_msg${NC}"
    
    # Показываем текущий PATH для диагностики
    echo -e "${YELLOW}🔍 Текущий PATH:${NC}"
    echo "$PATH" | tr ':' '\n' | head -5
    echo "..."
    
    return 1
}

# Проверка наличия curl
if ! check_command "curl" "Установите curl или добавьте его в PATH"; then
    echo -e "${YELLOW}📥 Для Windows: скачайте curl с https://curl.se/windows/${NC}"
    echo -e "${YELLOW}📥 Для Ubuntu/Debian: sudo apt-get install curl${NC}"
    echo -e "${YELLOW}📥 Для MacOS: brew install curl${NC}"
    exit 1
fi

# Проверка наличия jq
if ! check_command "jq" "Установите jq или добавьте его в PATH"; then
    echo -e "${YELLOW}📥 Для Windows: скачайте jq с https://stedolan.github.io/jq/download/${NC}"
    echo -e "${YELLOW}📥 Для Ubuntu/Debian: sudo apt-get install jq${NC}"
    echo -e "${YELLOW}📥 Для MacOS: brew install jq${NC}"
    exit 1
fi

# Проверка аргументов
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Ошибка: Укажите имя репозитория${NC}"
    echo -e "${YELLOW}💡 Пример: ./github-stats.sh tensorflow/tensorflow${NC}"
    echo -e "${YELLOW}💡 Или: sh github-stats.sh tensorflow/tensorflow${NC}"
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
echo -e "${BLUE}📎 URL: $API_URL${NC}"

# Используем curl с правильными параметрами для Windows
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows (Git Bash, Cygwin)
    RESPONSE=$(curl -s -k -w "\n%{http_code}" "$API_URL" 2>/dev/null)
else
    # Linux/Mac
    RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL" 2>/dev/null)
fi

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n -1)

# Проверка ответа API
if [ -z "$BODY" ] || [ "$BODY" = "null" ]; then
    echo -e "${RED}❌ Ошибка: Неверный ответ от API${NC}"
    echo -e "${YELLOW}💡 Проверьте подключение к интернету${NC}"
    exit 1
fi

# Проверка HTTP статуса
if [ "$HTTP_CODE" -eq 404 ]; then
    echo -e "${RED}❌ Ошибка: Репозиторий '$REPO' не найден${NC}"
    echo -e "${YELLOW}💡 Проверьте правильность имени (формат: пользователь/репозиторий)${NC}"
    exit 1
elif [ "$HTTP_CODE" -eq 403 ]; then
    echo -e "${RED}❌ Ошибка: Превышен лимит запросов к API (60 запросов в час)${NC}"
    echo -e "${YELLOW}💡 Попробуйте позже или используйте токен для аутентификации${NC}"
    echo -e "${YELLOW}💡 Токен можно получить здесь: https://github.com/settings/tokens${NC}"
    echo -e "${YELLOW}💡 Используйте: curl -H 'Authorization: token YOUR_TOKEN' $API_URL${NC}"
    exit 1
elif [ "$HTTP_CODE" -ne 200 ]; then
    echo -e "${RED}❌ Ошибка: API вернул код $HTTP_CODE${NC}"
    echo -e "${YELLOW}💡 Детали ошибки:${NC}"
    echo "$BODY" | head -5
    exit 1
fi

# Проверка, что ответ содержит валидный JSON
if ! echo "$BODY" | jq -e . >/dev/null 2>&1; then
    echo -e "${RED}❌ Ошибка: Получен невалидный JSON от API${NC}"
    echo -e "${YELLOW}💡 Ответ API (первые 100 символов):${NC}"
    echo "$BODY" | head -c 100
    echo "..."
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
REPO_URL=$(echo "$BODY" | jq -r '.html_url // ""')
CREATED=$(echo "$BODY" | jq -r '.created_at // ""')
PUSHED=$(echo "$BODY" | jq -r '.pushed_at // ""')

# Определение активности
if [ -n "$UPDATED" ] && [ "$UPDATED" != "null" ]; then
    # Пытаемся парсить дату (поддержка разных систем)
    if date --version 2>/dev/null | grep -q GNU; then
        # GNU date (Linux)
        UPDATED_SEC=$(date -d "$UPDATED" +%s 2>/dev/null)
    else
        # BSD date (MacOS)
        UPDATED_SEC=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$UPDATED" +%s 2>/dev/null)
    fi
    
    if [ -n "$UPDATED_SEC" ]; then
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
        ACTIVITY="${YELLOW}Неизвестно${NC} (не удалось определить дату)"
    fi
else
    ACTIVITY="${YELLOW}Неизвестно${NC}"
fi

# Вывод результатов
echo ""
echo -e "${BOLD}📦 Репозиторий:${NC} $NAME"
echo -e "${BOLD}📝 Описание:${NC} $DESCRIPTION"
if [ -n "$REPO_URL" ] && [ "$REPO_URL" != "null" ]; then
    echo -e "${BOLD}🔗 Ссылка:${NC} $REPO_URL"
fi
echo ""
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

if [ "$OPEN_ISSUES" -gt 0 ] 2>/dev/null; then
    PERCENT=$((ISSUES * 100 / OPEN_ISSUES))
    echo -e "📊 % открытых:    ${PERCENT}%"
fi

# Информация о создании и последнем пуше
if [ -n "$CREATED" ] && [ "$CREATED" != "null" ]; then
    CREATED_SHORT=$(echo "$CREATED" | cut -d'T' -f1)
    echo -e "📅 Создан:        $CREATED_SHORT"
fi

if [ -n "$PUSHED" ] && [ "$PUSHED" != "null" ]; then
    PUSHED_SHORT=$(echo "$PUSHED" | cut -d'T' -f1)
    echo -e "📤 Последний пуш: $PUSHED_SHORT"
fi

echo ""

# Если есть проблемы, даем советы
if [ $ISSUES -gt 100 ]; then
    echo -e "${YELLOW}💡 Совет: У репозитория много открытых issues ($ISSUES)${NC}"
fi

if [ $STARS -gt 10000 ]; then
    echo -e "${YELLOW}⭐ Популярный репозиторий! ($(printf "%'d" $STARS) звёзд)${NC}"
fi

echo -e "${CYAN}════════════════════════════════════════${NC}"