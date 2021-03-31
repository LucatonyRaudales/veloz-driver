import 'dart:async';

import 'package:carp_background_location/carp_background_location.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';
import '../repository/settings_repository.dart' as sett;


enum LocationStatus { UNKNOWN, RUNNING, STOPPED }
class OrderDetailsController extends ControllerMVC {
  Order order;
  GlobalKey<ScaffoldState> scaffoldKey;
  LocationStatus status = LocationStatus.UNKNOWN;
  OrderDetailsController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  LocationManager locationManager = LocationManager.instance;
  Stream<LocationDto> dtoStream;
  StreamSubscription<LocationDto> dtoSubscription;
 

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
          try{
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
          }catch(e){
            print('no se puedo mi perebes:  $e');
          }
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

  Future<bool>checkLocationPermission() async {
    final access = await LocationPermissions().checkPermissionStatus();
    switch (access) {
      case PermissionStatus.unknown:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await LocationPermissions().requestPermissions(
          permissionLevel: LocationPermissionLevel.locationAlways,
        );
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
        break;
      case PermissionStatus.granted:
        return true;
        break;
      default:
        return false;
        break;
    }
  }

  void start() async {
    bool havePermission = await checkLocationPermission();
    if(havePermission){
      locationManager.interval = 3;
      locationManager.distanceFilter = 0;
      locationManager.notificationTitle = 'Gula eat';
      locationManager.notificationMsg = 'llevando ordern ${this.order.id}';
      dtoStream = locationManager.dtoStream;
      // Subscribe if it hasnt been done already
      if (dtoSubscription != null) {
        dtoSubscription.cancel();
      }
      dtoSubscription = dtoStream.listen((dynamic newLocalData)async{
        await sett.updateLocation( order.id, newLocalData.latitude, newLocalData.longitude, newLocalData.heading, newLocalData.accuracy);
        //_con.getDirectionStepsCustomer(newLocalData.latitude, newLocalData.longitude);
      });
      await locationManager.start();
      setState(() {
        status = LocationStatus.RUNNING;
      });
    }
  }

  void stop() async {
    setState(() {
      status = LocationStatus.STOPPED;
    });
    dtoSubscription.cancel();
    await locationManager.stop();
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
      stop();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).the_order_deliverd_successfully_to_client),
      ));
    });
  }
}
