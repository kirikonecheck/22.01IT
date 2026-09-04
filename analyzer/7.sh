#!/bin/bash
# Скрипт ищет файлы по расширению в текущей директории

echo "Введите расширение файлов (например, txt, sh, md):"
read extension

echo "Поиск файлов с расширением .$extension в текущей директории:"
echo "----------------------------------------"
find . -maxdepth 1 -type f -name "*.$extension" 2>/dev/null | while read file; do
    echo "📄 $(basename "$file")"
done
echo "----------------------------------------"
count=$(find . -maxdepth 1 -type f -name "*.$extension" 2>/dev/null | wc -l)
echo "Найдено файлов: $count"