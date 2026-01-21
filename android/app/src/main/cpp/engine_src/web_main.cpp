#include <iostream>
#include <vector>
#include <string>

#include "bitboard.h"
#include "endgame.h"
#include "position.h"
#include "psqt.h"
#include "search.h"
#include "syzygy/tbprobe.h"
#include "thread.h"
#include "tt.h"
#include "uci.h"
#include "piece.h"
#include "variant.h"
#include "xboard.h"

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#else
#define EMSCRIPTEN_KEEPALIVE
#endif

using namespace Stockfish;

// Global state for the web session
StateListPtr states;
Position pos;
std::vector<Move> banmoves;
bool initialized = false;

extern "C" {

EMSCRIPTEN_KEEPALIVE
void init_engine() {
  if (initialized) return;
  initialized = true;

  // std::cout << engine_info() << std::endl; // Do not print info on init, wait for uci command

  pieceMap.init();
  variants.init();
  const char* argv[] = { "stockfish" };
  CommandLine::init(1, (char**)argv);
  
  UCI::init(Options);
  Tune::init();
  
  // Default variant
  Options["UCI_Variant"].set_default("chess");
  PSQT::init(variants.find(Options["UCI_Variant"])->second);
  
  Bitboards::init();
  Position::init();
  Bitbases::init();
  Endgames::init();
  
  // Emscripten/Web specific: Threads setup
  // If compiled with pthreads, this will use the configured number.
  Threads.set(size_t(Options["Threads"]));
  
  Search::clear(); // After threads are up
  Eval::NNUE::init();

  // Initialize Position and States
  states = StateListPtr(new std::deque<StateInfo>(1));
  pos.set(variants.find(Options["UCI_Variant"])->second, variants.find(Options["UCI_Variant"])->second->startFen, false, &states->back(), Threads.main());

  // XBoard state machine
  XBoard::stateMachine = new XBoard::StateMachine(pos, states);
}

EMSCRIPTEN_KEEPALIVE
void uci_command(const char* cmd) {
    std::string command(cmd);
    UCI::execute_command(pos, states, command, banmoves);
}

} // extern "C"

int main(int argc, char* argv[]) {
    // Initialize the engine immediately
    init_engine();
    return 0;
}
