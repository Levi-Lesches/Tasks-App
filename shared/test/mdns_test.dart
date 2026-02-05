import "dart:io";

import "package:collection/collection.dart";
import "package:shared/services.dart";
import "package:test/test.dart";

void main() => test("mDNS", () async {
  final server = BroadcastServer(port: 5001, type: ServerType.pc);
  await server.init();
  final services = await BroadcastClient.mdnsLookup();
  final result = services.firstWhereOrNull((s) => s.host == Platform.localHostname);
  expect(result, isNotNull); if (result == null) return;

  final selfIPs = await InternetAddress.lookup(Platform.localHostname);
  final resultIP = result.addrV4;
  expect(resultIP, isNotNull); if (resultIP == null) return;
  expect(selfIPs, contains(resultIP));
  expect(result.port, 5001);
  expect(result.info, ServerType.pc.name);

  await server.dispose();
});
