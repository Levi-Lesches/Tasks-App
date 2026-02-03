import "dart:io";

import "package:collection/collection.dart";
import "package:mdns_dart/mdns_dart.dart";

import "service.dart";

enum ServerType {
  server,
  pc,
  phone;

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
  final ServerInfo info;
  BroadcastServer(this.info);

  static Future<NetworkInterface?> getInterfaceFor(InternetAddress address) async {
    final interfaces = await NetworkInterface.list(includeLinkLocal: true, includeLoopback: true, type: InternetAddressType.IPv4);
    return interfaces
      .firstWhereOrNull((i) => i.addresses.contains(address));
  }

  MDNSServer? server;

  @override
  Future<void> init() async {
    final interface = await getInterfaceFor(info.address);
    if (interface == null) throw ArgumentError("Could not find a network interface for ${info.address}");
    final zone = await MDNSService.create(
      instance: "Tasks",
      service: "tasks",
      ips: [info.address],
      port: info.port,
      txt: [info.type.name]
    );
    final config = MDNSServerConfig(
      zone: zone,
      networkInterface: interface,
      logger: (message) { },
    );
    server = MDNSServer(config);
    await server!.start();
  }

  Future<void> dispose() async {
    await server?.stop();
  }
}

class BroadcastClient {
  static Future<ServerInfo?> discover() async {
    final services = await MDNSClient.discover(
      "tasks",
      wantUnicastResponse: true,
      timeout: const Duration(seconds: 1),
    );
    final servers = <ServerInfo>[];
    for (final service in services) {
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
