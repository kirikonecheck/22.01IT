cmake_minimum_required(VERSION 3.16)
project(Qt6DockerApp)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Widgets)

add_executable(qt6-app main.cpp)
target_link_libraries(qt6-app Qt6::Core Qt6::Widgets)