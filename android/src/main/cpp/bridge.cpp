#include <string>
#include <thread>
#include <iostream>
#include <sstream>
#include <vector>
#include <deque>
#include <mutex>
#include <condition_variable>
#include <cstring>

#include "engine_src/uci.h"
#include "engine_src/piece.h"
#include "engine_src/variant.h"
#include "engine_src/psqt.h"
#include "engine_src/tt.h"
#include "engine_src/thread.h"
#include "engine_src/bitboard.h"
#include "engine_src/position.h"
#include "engine_src/endgame.h"
#include "engine_src/misc.h"

#if defined(_WIN32)
#define EXPORT __declspec(dllexport)
#else
#define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

// --- Input Queue (Dart to C++) ---
static std::deque<std::string> input_queue;
static std::mutex input_mutex;
static std::condition_variable input_cv;

class DartInBuf : public std::streambuf {
protected:
    virtual int underflow() override {
        std::unique_lock<std::mutex> lock(input_mutex);
        input_cv.wait(lock, [] { return !input_queue.empty(); });
        
        current_line = input_queue.front();
        input_queue.pop_front();
        
        setg(&current_line[0], &current_line[0], &current_line[0] + current_line.size());
        return static_cast<unsigned char>(*gptr());
    }
private:
    std::string current_line;
};

// --- Output Queue (C++ to Dart) ---
static std::deque<std::string> output_queue;
static std::mutex output_mutex;
static std::condition_variable output_cv;

class DartOutBuf : public std::streambuf {
protected:
    virtual int overflow(int c) override {
        if (c != EOF) {
            char ch = static_cast<char>(c);
            if (ch == '\n') {
                std::lock_guard<std::mutex> lock(output_mutex);
                output_queue.push_back(line_buffer);
                line_buffer.clear();
                output_cv.notify_one();
            } else {
                line_buffer += ch;
            }
        }
        return c;
    }
private:
    std::string line_buffer;
};

static DartInBuf g_dartInBuf;
static DartOutBuf g_dartOutBuf;
static std::streambuf* g_oldCinBuf = nullptr;
static std::streambuf* g_oldCoutBuf = nullptr;

EXPORT int stockfish_init() {
    // 1. Redirect I/O
    g_oldCinBuf = std::cin.rdbuf(&g_dartInBuf);
    g_oldCoutBuf = std::cout.rdbuf(&g_dartOutBuf);
    
    // 2. Initialize Engine Components
    Stockfish::pieceMap.init();
    Stockfish::variants.init();
    
    // Standard UCI options
    Stockfish::UCI::init(Stockfish::Options);

    auto it = Stockfish::variants.find("chess");
    if (it != Stockfish::variants.end()) {
        Stockfish::PSQT::init(it->second);
    }

    Stockfish::Bitboards::init();
    Stockfish::Position::init();
    Stockfish::Bitbases::init();
    Stockfish::Endgames::init();
    Stockfish::Threads.set(1); 
    Stockfish::TT.resize(16); 

    return 0;
}

EXPORT int stockfish_main() {
    int argc = 1;
    char* argv[] = {(char*)"stockfish", nullptr};
    
    // Start the UCI loop (this blocks until 'quit' is received)
    Stockfish::UCI::loop(argc, argv);
    
    return 0;
}

EXPORT void stockfish_stdin_write(const char* command) {
    if (command) {
        std::lock_guard<std::mutex> lock(input_mutex);
        input_queue.push_back(std::string(command));
        input_cv.notify_one();
    }
}

static char g_outputBuffer[8192];

EXPORT const char* stockfish_stdout_read() {
    std::unique_lock<std::mutex> lock(output_mutex);
    // Block until there is data to read
    output_cv.wait(lock, [] { return !output_queue.empty(); });
    
    std::string line = output_queue.front();
    output_queue.pop_front();
    
    // Return a newline-terminated string for the Dart side parser
    std::strncpy(g_outputBuffer, line.c_str(), sizeof(g_outputBuffer) - 2);
    std::strcat(g_outputBuffer, "\n");
    
    return g_outputBuffer;
}
