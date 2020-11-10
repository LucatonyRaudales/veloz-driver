import 'dart:async';
import 'dart:typed_data';
import '../controllers/map_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/order.dart';
import '../models/route_argument.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
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
  Location _locationTracker = Location();
  Marker myMarker;
  Circle circle;
  GoogleMapController _controller;



  _CurrentMapWidgetState() : super(MapController()) {
    _con = controller;
  }
  
  @override
  
  void initState() {
    _con.currentOrder = widget.routeArgument?.param as Order;
    if (_con.currentOrder?.deliveryAddress?.latitude != null) {
      // user select a restaurant
      print(_con.currentOrder.deliveryAddress.toMap().toString());
      _con.getCustomerMarker(_con.currentOrder.deliveryAddress.latitude, _con.currentOrder.deliveryAddress.longitude);
      _con.getOrderLocation();
    } else {
      _con.getCurrentLocation();
    }

    super.initState();
  }

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(19.293607, -99.703592),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/img/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  
  

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    
    this.setState(() {
      _con.updateLocation( _con.currentOrder.id, latlng.latitude, latlng.longitude);
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

  void getCurrentLocation() async {
    try {

      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription = _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
              bearing: 192.8334901395799,
              target: LatLng(newLocalData.latitude, newLocalData.longitude),
              tilt: 0.0,
              zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });

    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
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
              child: Icon(Icons.location_searching),
              onPressed: () {
                getCurrentLocation();
              }
          ),
    );
  }
}