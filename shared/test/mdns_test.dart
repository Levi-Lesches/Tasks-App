import "dart:io";

import "package:collection/collection.dart";
import "package:mdns_dart/mdns_dart.dart";
import "package:shared/services.dart";
import "package:test/test.dart";

void main() => group("[broadcast]", () {
  test("mDNS", () async {
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

  test("ServerType.tryParse", () {
    for (final type in ServerType.values) {
      final value = ServerType.tryParse(type.name);
      expect(value, type);
    }
    expect(ServerType.tryParse("blah blah blah"), isNull);
  });

  ServiceEntry newEntry({
    required int port,
    required String? address,
    String info = "blank",
    String? host,
  }) => ServiceEntry(
    name: "tasks",
    addrsV4: [
      if (address != null)
        InternetAddress(address),
    ],
    host: host ?? Platform.localHostname,
    info: info,
    infoFields: [info],
    port: port,
  );

  test("Can parse a valid ServiceEntry", () async {
    final entry = newEntry(
      port: 1234,
      address: "192.168.1.25",
      host: "DESKTOP-XXXXXXX",
      info: "pc",
    );
    final client = MockBroadcastClient([entry]);
    final server = await client.discover();
    expect(server, isNotNull); if (server == null) return;
    expect(server.address.address, "192.168.1.25");
    expect(server.port, 1234);
    expect(server.type, ServerType.pc);
  });

  test("Can reject invalid entries", () async {
    final entries = [
      newEntry(
        port: 1234,
        address: null,
        host: "DESKTOP-XXXXXXX",
        info: "pc",
      ),
      newEntry(
        port: 1234,
        address: "192.168.1.25",
        host: "DESKTOP-XXXXXXX",
        info: "blah blah blah",
      ),
    ];
    final client = MockBroadcastClient(entries);
    expect(await client.discover(), isNull);

    entries.add(newEntry(
      port: 1234,
      address: "192.168.1.25",
      host: "DESKTOP-XXXXXXX",
      info: "pc",
    ));
    final server = await client.discover();
    expect(server, isNotNull); if (server == null) return;
    expect(server.address.address, "192.168.1.25");
    expect(server.port, 1234);
    expect(server.type, ServerType.pc);
  });

  test("Can sift out its own entry", () async {
    final selfEntry = newEntry(
      port: 1234,
      address: "192.168.1.25",
      host: Platform.localHostname,
      info: "pc",
    );
    final client = MockBroadcastClient([selfEntry]);
    expect(await client.discover(), isNull);
  });

  test("Finds the highest-priority server", () async {
    final entries = [
      newEntry(
        port: 1234,
        address: "192.168.1.25",
        host: "DESKTOP-XXXXXXX",
        info: "pc",
      ),
      newEntry(
        port: 5678,
        address: "192.168.1.26",
        host: "DESKTOP-XXXXXXX",
        info: "server",
      ),
    ];
    final client = MockBroadcastClient(entries);
    final server = await client.discover();
    expect(server, isNotNull); if (server == null) return;
    expect(server.address.address, "192.168.1.26");
    expect(server.port, 5678);
    expect(server.type, ServerType.server);
  });
});

class MockBroadcastClient extends BroadcastClient {
  final List<ServiceEntry> entries;
  MockBroadcastClient(this.entries);

  @override
  Future<List<ServiceEntry>> lookup() async => entries;
}
