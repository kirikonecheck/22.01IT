#!/bin/bash
# Скрипт создает структуру папок для веб-проекта

echo "Введите название проекта:"
read project_name

mkdir -p "$project_name/css" "$project_name/js"
touch "$project_name/index.html"
touch "$project_name/css/style.css"
touch "$project_name/js/script.js"

echo "Структура проекта '$project_name' создана:"
tree "$project_name" 2>/dev/null || find "$project_name" -type f -o -type d | sort