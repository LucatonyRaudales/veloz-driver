import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/credit_card.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;

class SettingsController extends ControllerMVC {
  CreditCard creditCard = new CreditCard();
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;

  SettingsController() {
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void update(User user) async {
    user.deviceToken = null;
    repository.update(user).then((value) {
      setState(() {
        //this.favorite = value;
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).profile_settings_updated_successfully),
      ));
    });
  }

  void updateCreditCard(CreditCard creditCard) {
    repository.setCreditCard(creditCard).then((value) {
      setState(() {});
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).payment_settings_updated_successfully),
      ));
    });
  }

  void listenForUser() async {
    creditCard = await repository.getCreditCard();
    setState(() {});
  }

  Future<void> refreshSettings() async {
    creditCard = new CreditCard();
  }

  void changeStatus(User user, bool status)async{
    repository.updateStatus(user, status).then((value) {
      //setState(() {});
      if(value){
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Estado actualizado'),
      ));
      }else{
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Error al actualizar, intenta de nuevo'),
      ));
      }
    });
  }
}
