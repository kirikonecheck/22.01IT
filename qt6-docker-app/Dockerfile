FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
# Устанавливаем всё необходимое для сборки и запуска Qt6 GUI
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    ninja-build \
    qt6-base-dev \
    qt6-base-dev-tools \
    libgl1-mesa-dev \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-shm0 \
    libxcb-sync1 \
    libxcb-xfixes0 \
    libxcb-xinerama0 \
    libxcb-cursor0 \
    libxcb-xkb1 \
    libxcb-util1 \
    libxkbcommon0 \
    libxkbcommon-x11-0 \
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-keysyms1-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    libxcb-xinerama0-dev \
    libxcb-cursor-dev \
    libxcb-xkb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    mesa-utils \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY CMakeLists.txt main.cpp ./
RUN cmake -B build -S . -G Ninja && \
    cmake --build build --parallel
ENV QT_QPA_PLATFORM=xcb
CMD ["./build/qt6-app"]