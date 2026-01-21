Pod::Spec.new do |s|
  s.name             = 'chess_sharp_dart'
  s.version          = '0.1.4'
  s.summary          = 'Chess♯ Engine'
  s.homepage         = 'https://chess-sharp.games'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'dbergan@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*.{h,m,mm,cpp,c}' # This catches bridge.cpp and engine_src
  s.exclude_files    = ['Classes/engine_src/main.cpp', 'Classes/engine_src/web_main.cpp']
  s.public_header_files = 'Classes/ChessSharpDartPlugin.h'
  
  s.platform         = :ios, '11.0'
  
  # Stockfish requires C++17 or higher
s.pod_target_xcconfig = { 
  'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
  'CLANG_CXX_LIBRARY' => 'libc++',
  'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) NNUE_EMBEDDING_OFF=1 NO_USERFAULTFD=1'
}
end