import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:carp_background_location/carp_background_location.dart';
import 'package:geolocator/geolocator.dart' as Geo;
import 'package:location/location.dart' as Loca;
//import 'package:carp_background_location/carp_background_location.dart';

import '../controllers/map_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/order.dart';
import '../models/route_argument.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//mport 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';





class CurrentMapWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  CurrentMapWidget({Key key, this.routeArgument, this.parentScaffoldKey}) : super(key: key);

  @override
  _CurrentMapWidgetState createState() => _CurrentMapWidgetState();
}

class _CurrentMapWidgetState extends StateMVC<CurrentMapWidget> {


  MapController _con;
  StreamSubscription _locationSubscription;
  Loca.Location _locationTracker = Loca.Location();
  Marker myMarker;
  Circle circle;
  GoogleMapController _controller;

static const String _isolateName = "LocatorIsolate";
ReceivePort port = ReceivePort();


  _CurrentMapWidgetState() : super(MapController()) {
    _con = controller;
  }
  
  @override
  
  void initState() {
    iniciar();
    super.initState();
  }

    void iniciar()async{
    _con.currentOrder = widget.routeArgument?.param as Order;
    if (_con.currentOrder?.deliveryAddress?.latitude != null) {
      // user select a restaurant
      print(_con.currentOrder.deliveryAddress.toMap().toString());
      await _con.getCustomerMarker(_con.currentOrder.deliveryAddress.latitude, _con.currentOrder.deliveryAddress.longitude);
      _con.getOrderLocation();
    }

    Geo.LocationPermission permisos = await Geo.Geolocator.checkPermission();
    if (permisos != Geo.LocationPermission.always) {
      await Geo.Geolocator.requestPermission();
      iniciar();
    } else {
      _con.getCurrentLocation();
    getCurrentLocation();
        }
  }
  
Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
}
static void callback(LocationDto locationDto) async {
  print('Calbback');
    final SendPort send = IsolateNameServer.lookupPortByName(_isolateName);
    send?.send(locationDto);
  }

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(19.293607, -99.703592),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/img/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  
  

  void updateMarkerAndCircle( newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    print('update Location');
    this.setState(() {
      _con.updateLocation( _con.currentOrder.id, latlng.latitude, latlng.longitude, newLocalData.heading, newLocalData.accuracy);
      _con.getDirectionStepsCustomer(latlng.latitude, latlng.longitude);
      myMarker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
          circle = Circle(
            circleId: CircleId("car"),
            radius: newLocalData.accuracy,
            zIndex: 1,
            strokeColor: Colors.blue,
            center: latlng,
            fillColor: Colors.blue.withAlpha(70)
          );
    });
  }

  Future<void> startLocationService(){
    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        //initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        autoStop: false,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 5,
            distanceFilter: 0,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Gula localizando',
                notificationMsg: 'Obteniendo tu posición',
                notificationBigMsg:
                    'Localización en segundo plano es requerido',
                notificationIcon: '',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
    return null;
}

  void getCurrentLocation() async {
    try {
      await  startLocationService();
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);
      port.listen((dynamic newLocalData) {
      if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(newLocalData.latitude, newLocalData.longitude),
              tilt: 0.0,
              zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
    });

      /*_locationSubscription = _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(newLocalData.latitude, newLocalData.longitude),
              tilt: 0.0,
              zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });*/

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }catch(err){
      print('Error $err');
    }
  }

  void goOut()async{
    await IsolateNameServer.removePortNameMapping(_isolateName);
    await BackgroundLocator.unRegisterLocationUpdate();
    port.close();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (_con.customerMarker == null) ?
        CircularLoadingWidget(height: 400)
        : GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(_con.currentOrder.deliveryAddress.latitude, _con.currentOrder.deliveryAddress.longitude),
              zoom: 14.4746,
            ),
            markers: Set.of((myMarker != null) ? [myMarker, _con.customerMarker] : [_con.customerMarker] ),
            circles: Set.of((circle != null) ? [circle] : []),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            polylines: _con.customerMarker != null ? _con.polylines : null

          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.arrow_back_outlined),
              onPressed: () {
                goOut();
              }
          ),
    );
  }
}
