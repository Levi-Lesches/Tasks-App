import "dart:async";
import "dart:io";
import "dart:typed_data";
import "package:collection/collection.dart";

extension on InternetAddress {
  String get firstOctet => address.split(".").first;
  InternetAddress get broadcast {
    final parts = rawAddress;
    parts[3] = 255;
    return InternetAddress.fromRawAddress(parts, type: InternetAddressType.IPv4);
  }
}

enum ServerType {
  server,
  pc,
  phone,
}

Future<Iterable<InternetAddress>> getAllAddresses() async =>
  (await NetworkInterface.list(type: InternetAddressType.IPv4))
  .expand((interface) => interface.addresses);

class BroadcastServer {
  static const port = 5002;
  static const response = "Tasks-App-Response";
  late final RawDatagramSocket socket;
  final ServerType type;
  BroadcastServer(this.type);

  Future<void> init() async {
    socket = await RawDatagramSocket.bind("0.0.0.0", port);
    socket.listen(onData);
  }

  Future<void> onData(RawSocketEvent event) async {
    final datagram = socket.receive();
    if (datagram == null) return;
    final contents = String.fromCharCodes(datagram.data);
    if (contents != BroadcastClient.requestString) return;
    final address = await getMatchingIp(datagram.address);
    final message = "$response ${address.address} ${type.index}";
    final buffer = Uint8List.fromList(message.codeUnits);
    socket.send(buffer, datagram.address, datagram.port);
  }

  Future<InternetAddress> getMatchingIp(InternetAddress other) async {
    final otherOctet = other.firstOctet;
    final addresses = await getAllAddresses();
    return addresses.firstWhere((address) => address.firstOctet == otherOctet);
  }
}


class BroadcastClient {
  static const requestString = "Tasks-App";
  static const port = 5003;

  late final RawDatagramSocket socket;

  Future<void> init() async {
    socket = await RawDatagramSocket.bind("0.0.0.0", port);
    if (Platform.isAndroid) socket.broadcastEnabled = true;
    socket.listen(onData);
  }

  Future<(InternetAddress, ServerType)?> broadcast() async {
    servers = [];
    final buffer = Uint8List.fromList(requestString.codeUnits);
    for (final address in await getAllAddresses()) {
      if (!address.address.startsWith("192")) continue;
      socket.send(buffer, address.broadcast, BroadcastServer.port);
    }
    const delay = Duration(milliseconds: 3000);
    await Future<void>.delayed(delay);
    final result = ServerType.values.map(  // choose highest priority server
      (serverType) => servers.firstWhereOrNull((tuple) => serverType == tuple.$2))
      .firstWhereOrNull((tuple) => tuple != null);
    return result;
  }

  void dispose() => socket.close();

  List<(InternetAddress, ServerType)> servers = [];

  Future<void> onData(RawSocketEvent event) async {
    final datagram = socket.receive();
    if (datagram == null) return;
    final message = String.fromCharCodes(datagram.data);
    final [response, ip, index] = message.split(" ");
    if (response != BroadcastServer.response) return;
    final allAddresses = await getAllAddresses();
    final result = InternetAddress(ip);
    final type = ServerType.values[int.parse(index)];
    if (allAddresses.contains(result)) return;
    servers.add( (result, type) );
  }
}
