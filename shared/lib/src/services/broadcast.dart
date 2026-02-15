import "dart:io";

import "package:collection/collection.dart";
import "package:mdns_dart/mdns_dart.dart";
import "package:meta/meta.dart";

import "service.dart";

enum ServerType {
  server, pc, phone;

  static ServerType? tryParse(String name) => values.firstWhereOrNull((v) => v.name == name);
}

class ServerInfo {
  final InternetAddress address;
  final int port;
  final ServerType type;

  const ServerInfo({
    required this.address,
    required this.port,
    required this.type,
  });
}

class BroadcastServer extends Service {
  final int port;
  final ServerType type;
  final String? hostName;
  BroadcastServer({
    required this.port,
    required this.type,
    this.hostName,
  });

  MDNSServer? server;

  @override
  Future<void> init() async {
    final zone = await MDNSService.create(
      instance: Platform.localHostname,
      service: "tasks",
      hostName: hostName,
      port: port,
      txt: [type.name]
    );
    final config = MDNSServerConfig(zone: zone, logger: (message) { });
    server = MDNSServer(config);
    await server!.start();
  }

  Future<void> dispose() async {
    await server?.stop();
  }
}

class BroadcastClient {
  @visibleForTesting
  static Future<List<ServiceEntry>> mdnsLookup() async => [
    for (final interface in await NetworkInterface.list())
      ...await MDNSClient.discover(
        "tasks",
        wantUnicastResponse: true,
        timeout: const Duration(milliseconds: 250),
        networkInterface: interface,
      ),
  ];

  @visibleForTesting
  Future<List<ServiceEntry>> lookup() => mdnsLookup();

  Future<ServerInfo?> discover() async {
    final services = await lookup();
    final servers = <ServerInfo>[];
    for (final service in services) {
      if (service.host == Platform.localHostname) continue;
      final ip = service.addrV4;
      if (ip == null) continue;
      final type = ServerType.tryParse(service.info);
      if (type == null) continue;
      final info = ServerInfo(address: ip, port: service.port, type: type);
      servers.add(info);
    }
    servers.sortBy((s) => s.type.index);
    return servers.firstOrNull;
  }
}
