#!/bin/bash
# Скрипт генерирует случайный пароль длиной 8 символов

password=$(tr -dc 'A-Za-z0-9!@#$%^&*()_+' < /dev/urandom 2>/dev/null | head -c 8)
echo "Сгенерированный пароль: $password"