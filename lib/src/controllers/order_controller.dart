import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';

class OrderController extends ControllerMVC {
  List<Order> orders = <Order>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  OrderController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForOrders({String message}) async {
    final Stream<Order> stream = await getOrders();
    stream.listen((Order _order) {
      setState(() {
        orders.add(_order);
      });
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

  void listenForOrdersHistory({String message}) async {
    final Stream<Order> stream = await getOrdersHistory();
    stream.listen((Order _order) {
      setState(() {
        orders.add(_order);
      });
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

  Future<void> refreshOrdersHistory() async {
    orders.clear();
    listenForOrdersHistory(message: S.of(context).order_refreshed_successfuly);
  }

  Future<void> refreshOrders() async {
    orders.clear();
    listenForOrders(message: S.of(context).order_refreshed_successfuly);
  }

   void doUpdateAvaible(bool _active) async { 


    updateAvaible(_active).then((value) {
//       if(!preparingTime){
      
//         //Navigator.of(context).pushNamed('/OrderEdit', arguments: RouteArgument(id: order.id));
//         Navigator.popAndPushNamed(context, '/OrderEdit', arguments: RouteArgument(id: order.id));
//         //Navigator.of(context).pushNamedAndRemoveUntil('/OrderEdit', ModalRoute.withName('/Pages'), arguments: RouteArgument(id: order.id));
//       }

//       if(_order.orderStatus.id == '5' && order.payment.method == 'Pay on Pickup'){
//          Navigator.of(context).pushNamedAndRemoveUntil('/Pages', (Route<dynamic> route) => false, arguments: RouteArgument(id: '1', statusOrder: '5'));
//       }else if(_order.orderStatus.id == '4' && order.payment.method == 'Cash on Delivery'){
//         Navigator.of(context).pushNamedAndRemoveUntil('/Pages', (Route<dynamic> route) => false, arguments: RouteArgument(id: '1', statusOrder: '4'));
//       }else if(_order.orderStatus.id == '3'){
//          Navigator.of(context).pushNamedAndRemoveUntil('/Pages', (Route<dynamic> route) => false, arguments: RouteArgument(id: '1', statusOrder: '3'));
//       }
// //      FocusScope.of(context).unfocus();
// //      setState(() {
// //        this.order.orderStatus.id = '5';
// //      });
//       scaffoldKey?.currentState?.showSnackBar(SnackBar(
//         content: Text(S.of(context).thisOrderUpdatedSuccessfully),
//       ));
    });
  }
}
