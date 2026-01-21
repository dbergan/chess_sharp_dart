import 'engine_base.dart';
import 'engine_native.dart';
import 'engine_binary.dart';
import 'dart:io';

Sharpfish createEngine() {
  if (Platform.isAndroid || Platform.isIOS) {
    return EngineNative();
  } else {
    return EngineBinary();
  }
}
