#!/bin/bash
# Скрипт подсчитывает количество строк в указанном файле

echo "Введите путь к файлу:"
read filepath

if [ -f "$filepath" ]; then
    lines=$(wc -l < "$filepath")
    echo "Количество строк в файле '$filepath': $lines"
else
    echo "Ошибка: Файл не найден!"
fi