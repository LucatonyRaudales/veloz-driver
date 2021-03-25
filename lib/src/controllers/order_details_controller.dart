import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:deliveryboy/src/controllers/map_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:carp_background_location/carp_background_location.dart';
import 'package:geolocator/geolocator.dart' as Geo;
import 'package:location/location.dart' as Loca;
import '../../generated/l10n.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';


enum LocationStatus { UNKNOWN, RUNNING, STOPPED }
class OrderDetailsController extends ControllerMVC {
  Order order;
  GlobalKey<ScaffoldState> scaffoldKey;
  StreamSubscription locationSubscription;
  LocationStatus status = LocationStatus.UNKNOWN;
  Loca.Location _locationTracker = Loca.Location();
  OrderDetailsController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  MapController _con = MapController();


static const String _isolateName = "LocatorIsolate";
ReceivePort port = ReceivePort();

  void launchMap()async{
    try {
    print('--------------- Lanzandoa Map');
    final availableMaps = await MapLauncher.installedMaps;
    print(availableMaps[0].icon); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]
    //showAlert(mapsList: availableMaps);
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Selecciona la aplicación a usar'),
        content: Container(
    height: 150.0, // Change as per your requirement
    width: 300.0, // Change as per your requirement
    child: ListView.builder(
      shrinkWrap: true,
      itemCount:availableMaps.length, // availableMaps.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          child: ListTile(
          title: Text(availableMaps[index].mapName),
          trailing: new Icon(Icons.arrow_forward_ios),
        ),
        onTap:() async{
          getCurrentLocation();
          MapType type = availableMaps[index].mapType;
              if (await MapLauncher.isMapAvailable(type)) {
                await MapLauncher.showDirections(
                  mapType: type,
                destination: Coords(
                  order.deliveryAddress.latitude,
                  order.deliveryAddress.longitude,
                ),
                destinationTitle: order.user.name,
                originTitle: 'Yo',
                waypoints: []
                    .map((e) => Coords(e.latitude, e.longitude))
                    .toList(),
                directionsMode: DirectionsMode.driving,
              );
          };
          Navigator.pop(context);
        },
        );
      },
    ),
  ),
      );
    });
      
    } catch (e) {
      print('Error $e');
    }
  }
  
   void iniciar()async{

    Geo.LocationPermission permisos = await Geo.Geolocator.checkPermission();
    if (permisos != Geo.LocationPermission.always) {
      await Geo.Geolocator.requestPermission();
      iniciar();
    } else {
      //_con.getCurrentLocation();
    getCurrentLocation();
        }
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
            interval: 2,
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

      if(status == LocationStatus.UNKNOWN){
        setState((){
          status = LocationStatus.RUNNING;
        });
      }
      if (locationSubscription != null) {
        locationSubscription.cancel();
      }

      IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);
      port.listen((dynamic newLocalData) {
      _con.updateLocation( order.id, newLocalData.latitude, newLocalData.longitude, newLocalData.heading, newLocalData.accuracy);
      //_con.getDirectionStepsCustomer(newLocalData.latitude, newLocalData.longitude);
    });

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
    setState((){
        status = LocationStatus.UNKNOWN;
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    if (locationSubscription != null) {
      locationSubscription.cancel();
    }
    setState((){
        status = LocationStatus.UNKNOWN;
    });
    super.dispose();
  }


  void listenForOrder({String id, String message}) async {
    final Stream<Order> stream = await getOrder(id);
    stream.listen((Order _order) {
      setState(() => order = _order);
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshOrder() async {
    listenForOrder(id: order.id, message: S.of(context).order_refreshed_successfuly);
  }
  
  Future<void>  doDeliveredOrder(Order _order) async {
    deliveredOrder(_order).then((value) {
      setState(() {
        this.order.orderStatus.id = '5';
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).the_order_deliverd_successfully_to_client),
      ));
    });
  }
}
