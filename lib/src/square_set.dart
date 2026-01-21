export 'internal/square_set_vm.dart'
    if (dart.library.js_interop) 'internal/square_set_web.dart'
    if (dart.library.js) 'internal/square_set_web.dart'
    if (dart.library.html) 'internal/square_set_web.dart';
