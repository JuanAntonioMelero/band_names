import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  //vamos a hacer el socket privado, unico para esta clase
  late IO.Socket _socket;

  // para poder exportar el valor de _serverStatus y socket  a otra clase a traves de un get
  get serverStatus => _serverStatus;
  get socket => _socket;

  
  SocketService() {
    _initConfig();
  }
  void _initConfig() {
    _socket = IO.io('http://192.168.1.140:3000', {
      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();

      print('connect');
    });
    //  socket.onDisconnect((_) {
    //   _serverStatus = ServerStatus.Offline;
    //  notifyListeners();
    // });
    _socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
      print('disconnect');
    });
    //escuchar 'mensaje'
    _socket.on('nuevo-mensaje', (payload) {
      print('nuevo mensaje');
      print('nombre:' + payload['nombre']);
      print('mensaje:' + payload['mensaje']);
      //con containsKey controlamos si viene o no alguna propiedad
      print(
        payload.containsKey('mensaje2')
            ? payload['mensaje2']
            : 'no hay mensaje2',
      );
    });
  }
}
