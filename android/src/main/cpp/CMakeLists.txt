cmake_minimum_required(VERSION 3.10.2)

project(chess_sharp_dart)

# Add all your Stockfish source files
file(GLOB_RECURSE ENGINE_SOURCES "engine_src/*.cpp")

# We filter out main.cpp and web_main.cpp because they both contain "int main()".
# Android shared libraries use bridge.cpp as the entry point, not main().
list(FILTER ENGINE_SOURCES EXCLUDE REGEX ".*/main\\.cpp$")
list(FILTER ENGINE_SOURCES EXCLUDE REGEX ".*/web_main\\.cpp$")

add_definitions(-DNNUE_EMBEDDING_OFF)
add_definitions(-DNO_USERFAULTFD)
add_definitions(-DUSE_POPCNT=0)      # Prevents hardware-specific crashes
add_definitions(-DNO_SSE)           # Ensures compatibility with all mobile CPUs

add_library(chess_sharp_dart SHARED
            bridge.cpp
            ${ENGINE_SOURCES})

# Include the main engine directory AND any subdirectories 
# that contain headers used in #include "folder/file.h" statements
target_include_directories(chess_sharp_dart PRIVATE 
    engine_src
    engine_src/nnue     # Add this
    engine_src/syzygy   # Add this if you use tablebases
)

# Standard Stockfish usually needs these flags for performance
target_compile_options(chess_sharp_dart PRIVATE 
    -O3 
    -DNDEBUG 
    -fPIC
    -Wno-unused-value
)
