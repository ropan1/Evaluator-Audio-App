cmake_minimum_required(VERSION 3.18.1)
project(mic_handler)

add_library(mic_handler SHARED
    ../../native/mic_handler.c
)

# miniaudio requires some math functions and Android's log library if used
target_link_libraries(mic_handler
    log
    m
)