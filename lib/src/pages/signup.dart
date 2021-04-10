import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;

class SignUpWidget extends StatefulWidget {
  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends StateMVC<SignUpWidget> {
  UserController _con;

  _SignUpWidgetState() : super(UserController()) {
    _con = controller;
  }

  String value = "Medio de transporte";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          leading: new IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white), 
            onPressed: ()=>   Navigator.of(context).pushNamed('/Login')
          ),
          backgroundColor: Theme.of(context).accentColor,
          centerTitle: true,
          title: Text(
            '¡Registro!',
            //S.of(context).lets_start_with_register,
            style: Theme.of(context).textTheme.headline4.merge(TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            //alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              /*Positioned(
                top: 0,
                child: Container(
                  width: config.App(context).appWidth(100),
                  height: config.App(context).appHeight(29.5),
                  decoration: BoxDecoration(color: Theme.of(context).accentColor),
                ),
              ),
              Positioned(
                top: config.App(context).appHeight(29.5) - 140,
                child: Container(
                  width: config.App(context).appWidth(84),
                  height: config.App(context).appHeight(29.5),
                  child: Text(
                    S.of(context).lets_start_with_register,
                    style: Theme.of(context).textTheme.headline2.merge(TextStyle(color: Theme.of(context).primaryColor)),
                  ),
                ),
              ),*/Container(
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(10)), boxShadow: [
                    BoxShadow(
                      blurRadius: 50,
                      color: Theme.of(context).hintColor.withOpacity(0.2),
                    )
                  ]),
                  margin: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),
                  width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                  child: Form(
                    key: _con.loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          keyboardType: TextInputType.text,
                          onSaved: (input) => _con.user.name = input,
                          validator: (input) => input.length < 3 ? S.of(context).should_be_more_than_3_letters : null,
                          decoration: InputDecoration(
                            labelText: S.of(context).full_name,
                            labelStyle: TextStyle(color: Theme.of(context).accentColor),
                            contentPadding: EdgeInsets.all(12),
                            hintText: S.of(context).john_doe,
                            hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                            prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).accentColor),
                            border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          ),
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (input) => _con.user.email = input,
                          validator: (input) => !input.contains('@') ? S.of(context).should_be_a_valid_email : null,
                          decoration: InputDecoration(
                            labelText: S.of(context).email,
                            labelStyle: TextStyle(color: Theme.of(context).accentColor),
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'johndoe@gmail.com',
                            hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                            prefixIcon: Icon(Icons.alternate_email, color: Theme.of(context).accentColor),
                            border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          ),
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          obscureText: _con.hidePassword,
                          onSaved: (input) => _con.user.password = input,
                          validator: (input) => input.length < 6 ? S.of(context).should_be_more_than_6_letters : null,
                          decoration: InputDecoration(
                            labelText: S.of(context).password,
                            labelStyle: TextStyle(color: Theme.of(context).accentColor),
                            contentPadding: EdgeInsets.all(12),
                            hintText: '••••••••••••',
                            hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                            prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).accentColor),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _con.hidePassword = !_con.hidePassword;
                                });
                              },
                              color: Theme.of(context).focusColor,
                              icon: Icon(_con.hidePassword ? Icons.visibility : Icons.visibility_off),
                            ),
                            border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          child: Stack(
                            children: [
                              TextFormField(
                                initialValue: ' ',
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Transporte',
                                  labelStyle: TextStyle(color: Theme.of(context).accentColor),
                                  contentPadding: EdgeInsets.all(12),
                                  hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                                  prefixIcon: Icon(Icons.navigation_outlined, color: Theme.of(context).accentColor),
                                  border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                                ),
                              ),
                              Positioned(
                                left: 45.0,
                                right: 15.0,
                                top: 12.0,
                                bottom: 12.0,
                                child: Container(
                                  width: 400.0,
                                  height: 30.0,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      hint: Text(value
                                      // , style: TextStyle(color: Theme.of(context).accentColor)
                                      ),
                                      underline: SizedBox(),
                                      onChanged: (txt){
                                        setState(() {
                                          value = txt;
                                          _con.user.transport = txt;
                                        });
                                      },
                                      items: [
                                        DropdownMenuItem(
                                          value: 'Carro',
                                          child: Text('Carro'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Moto',
                                          child: Text('Moto'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Bicicleta',
                                          child: Text('Bicicleta'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          width: 500,
                          height: 180,
                          child: _con.image == null
                              ? InkWell(
                                onTap:(){
                                  showModalBottomSheet(context: context,
                                    builder: (BuildContext context) {
                                      return SafeArea(
                                        child: new Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            new ListTile(
                                              leading: new Icon(Icons.camera),
                                              title: new Text('Cámara'),
                                              onTap: () => _con.getImage(ImageSource.camera),
                                            ),
                                            new ListTile(
                                              leading: new Icon(Icons.image),
                                              title: new Text('Galería'),
                                              onTap: () => _con.getImage(ImageSource.gallery),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  );
                                },
                                child: new Container(
                                  color: Colors.grey[200],
                                  child: new Icon(Icons.add_a_photo, color: Colors.orange[900])
                                )
                              )
                              : InkWell(
                                onTap:(){
                                  showModalBottomSheet(context: context,
                                    builder: (BuildContext context) {
                                      return SafeArea(
                                        child: new Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            new ListTile(
                                              leading: new Icon(Icons.camera),
                                              title: new Text('Cámara'),
                                              onTap: () => _con.getImage(ImageSource.camera),
                                            ),
                                            new ListTile(
                                              leading: new Icon(Icons.image),
                                              title: new Text('Galería'),
                                              onTap: () => _con.getImage(ImageSource.gallery),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  );
                                },
                                child: new Container(
                                  color: Colors.grey[200],
                                  child: Image.file(_con.image)
                                )
                              ),
                        ),
                        SizedBox(height: 30),
                        BlockButtonWidget(
                          text: Text(
                            S.of(context).register,
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            _con.register();
                          },
                        ),
                        SizedBox(height: 25)
                      ],
                    ),
                  ),
                ),FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/Login');
                  },
                  textColor: Theme.of(context).hintColor,
                  child: Text(S.of(context).i_have_account_back_to_login),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
