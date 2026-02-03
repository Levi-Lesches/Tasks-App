import "dart:io";

import "package:shared/services.dart";
import "package:test/test.dart";

void main() => test("mDNS", () async {
  final info = ServerInfo(address: InternetAddress.loopbackIPv4, port: 5001, type: ServerType.pc);
  final server = BroadcastServer(info);
  await server.init();
  final result = await BroadcastClient.discover();
  expect(result, isNotNull);
  if (result == null) return;

  expect(result.address, InternetAddress.loopbackIPv4);
  expect(result.type, ServerType.pc);

  await server.dispose();
});
