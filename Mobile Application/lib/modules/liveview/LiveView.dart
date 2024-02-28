import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../shared/cubit/cubit.dart';

class LiveView extends StatefulWidget {
  final String ip;
  const LiveView({
    Key? key,
    required this.ip,
  }) : super(key: key);

  @override
  _LiveViewState createState() => _LiveViewState();
}

class _LiveViewState extends State<LiveView> {
  StreamController<Uint8List> _imageStreamController = StreamController<Uint8List>();
  List<Uint8List> _imageChunks = [];
  Uint8List? imageArray;

  // UDP setup
  var clientSocket;
  int counter=0, size=0;


  @override
  void initState() {
    super.initState();
    _setupSocket();
  }

  void _setupSocket() async {
    try {
      String? message="";
      final serverAddress = InternetAddress(widget.ip);
      const srcPort = 5011;
      const destPort = 8888;
      clientSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, srcPort);
      clientSocket.send('Start send'.codeUnits, serverAddress, destPort);
      clientSocket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram dg = clientSocket.receive()!;
          message = String.fromCharCodes(dg.data);

          if (counter==1) {
            size = bytesToInt(dg.data);
            // print('Received size: ${size}');
          }
          else if (message!="size" && message!='end') {
            _imageChunks.add(dg.data);
            clientSocket.send('ACK'.codeUnits, serverAddress, destPort);
          }

          // print('counter = ${counter}');
          counter++;

          if(message=="end") {
            Uint8List? image = _concatenateChunks();
            _imageStreamController.add(image);
            counter=0;
            // print('Received message: ${message}');
            _imageChunks.clear();
            clientSocket.send('Start send'.codeUnits, serverAddress, destPort);
          }

          // print('Received message datagram: ${dg.data}');
          // print('Received message: ${message}');
        }
      });

    } catch (e) {
      print('Error setting up socket: $e');
    }
  }

  int bytesToInt(List<int> bytes) {
    int value = 0;
    for (int i = 0; i < bytes.length; i++) {
      value += bytes[i] << (8 * (bytes.length - i - 1));
    }
    return value;
  }

  Uint8List _concatenateChunks() {
    int totalLength = _imageChunks.fold(0, (total, chunk) => total + chunk.length);
    // print("totalLength = ${totalLength}");
    Uint8List result = Uint8List(totalLength);
    int offset = 0;
    for (var chunk in _imageChunks) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
      // print("chunk.length = ${chunk.length}");
    }
    // print("result = ${result}");
    // print("result.length = ${result.length}");
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UDP Image Receiver'),
      ),
      body: Center(
        child: StreamBuilder<Uint8List>(
          stream: _imageStreamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.memory(snapshot.data!);
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      floatingActionButton: IconButton.filled(
        icon: const Icon(Icons.refresh),
        onPressed: _setupSocket,
      ),
    );
  }

  @override
  void dispose() {
    clientSocket?.close();
    super.dispose();
  }
}