import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _messageCodec = StandardMessageCodec();

ByteData byteDataEncode(String string) {
  final buffer = WriteBuffer();
  _messageCodec.writeValue(buffer, string);

  return buffer.done();
}

String byteDataDecode(ByteData byteData) {
  final buffer = ReadBuffer(byteData);

  return _messageCodec.readValue(buffer) !as String;
}
