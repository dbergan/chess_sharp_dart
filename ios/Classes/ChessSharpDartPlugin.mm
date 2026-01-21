#import "ChessSharpDartPlugin.h"

// Declaration to access the symbol from bridge.cpp
extern "C" int stockfish_init(void);
extern "C" int stockfish_main(void);
extern "C" void stockfish_stdin_write(const char* command);
extern "C" const char* stockfish_stdout_read(void);

@implementation ChessSharpDartPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  // This code is never executed deeply, but referencing the symbols prevents 
  // the linker from stripping them when linking the static library.
  volatile auto f1 = &stockfish_init;
  volatile auto f2 = &stockfish_main;
  volatile auto f3 = &stockfish_stdin_write;
  volatile auto f4 = &stockfish_stdout_read;
  (void)f1;
  (void)f2;
  (void)f3;
  (void)f4;
}
@end
