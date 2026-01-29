echo "Введите целое число:"
read number

if (( number % 2 == 0 )); then
    echo "Число $number является четным"
else
    echo "Число $number является нечетным"
fi