#include <QApplication>
#include <QWidget>
#include <QVBoxLayout>
#include <QLabel>
#include <QPushButton>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    // Создаём главное окно
    QWidget window;
    window.setFixedSize(400, 200);
    window.setWindowTitle("Фиксированное окно с кнопкой");
    // Создаём вертикальный layout
    QVBoxLayout *layout = new QVBoxLayout(&window);
    // Добавляем текстовую метку
    QLabel *label = new QLabel("Привет из Docker-контейнера с Qt6!");
    label->setAlignment(Qt::AlignCenter);
    layout->addWidget(label);
    // Добавляем кнопку
    QPushButton *button = new QPushButton("Нажми меня");
    button->setFixedSize(120, 30); // необязательно: фиксированный размер кнопки
    layout->addWidget(button, 0, Qt::AlignCenter); // выравнивание по центру
    // Показываем окно
    window.show();
    return app.exec();
}