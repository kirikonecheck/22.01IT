#!/bin/bash
# Скрипт запрашивает два числа и выводит их сумму

echo "Введите первое число:"
read num1
echo "Введите второе число:"
read num2

sum=$((num1 + num2))
echo "Сумма $num1 + $num2 = $sum"