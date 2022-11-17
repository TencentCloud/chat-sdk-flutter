import 'dart:ffi';
import 'package:ffi/ffi.dart';

class InitParams extends Struct {
  @Uint64()
  external int sdkAppID;

  external Pointer<Utf8> jsonSdkConfig;
}
