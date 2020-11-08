import 'package:flutter/foundation.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;
  bool _newLocation = false;
  bool _isSendingLocation = false;
  String _lat = "";
  String _lng = "";


  String get lat => this._lat;
  String get lng => this._lng;
  bool get isSendingLocation => this._isSendingLocation;
  bool get isNewLocation => this._newLocation;
  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;


  set isSendingLocation(val) {
    this._isSendingLocation = val;
    notifyListeners();
  }

  set isNewLocation(val) {
    this._newLocation = val;
    notifyListeners();
  }

 

  SocketService() {
    print("constructor socket");
    _initConfig();
  }
 

  
  void _initConfig() {
    //https://gulaeats.com.mx/public/
    //_socket = IO.io(GlobalConfiguration().getString('base_url'), {
    _socket = IO.io("http://127.0.0.1:8000/", {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.on('connect', (_) {
      this._serverStatus = ServerStatus.Online;
      print('$_serverStatus');
      notifyListeners();
    });

    socket.on('disconnect', (_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket.on('send-location', (latlng) {
      print("$latlng");
      notifyListeners();
    });

    _socket.on('locationLat', (lat) {
      print("Nueva ubicación");
      this._lat = lat;
      this._newLocation = true;
      notifyListeners();
    });

     _socket.on('locationLng', (lng) {
      print("Nueva ubicación");
      this._lng = lng;
      this._newLocation = true;
      notifyListeners();
    });
  }
}