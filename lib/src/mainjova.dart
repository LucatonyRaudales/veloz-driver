import 'dart:async';

import '../src/helpers/socket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Timer timer;
  String name = "";


  SocketService socketService;
  @override
  void initState() {
      if (!socketService.isSendingLocation) {
        socketService.emit('notification', {'evento': 'Nuevo negocio'});
        sendingNotification();
        //this.playSong();
      }
    super.initState();
  }

  // void playSong() {
  //   AssetsAudioPlayer.newPlayer().open(
  //     Audio("audios/bell.mp3"),
  //     showNotification: true,
  //   );
  // }

  void sendingNotification() {
    print("Sending notification");
    socketService.isSendingLocation = true;
    timer = Timer(Duration(seconds: 5), () {
      setState(() {
        socketService.isSendingLocation = false;
        timer.cancel();
      });
    });
  }

  void onNewNotification() {
    //playSong();
    timer = Timer(Duration(seconds: 5), () {
      setState(() {
        socketService.isNewLocation = false;
        timer.cancel();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    socketService = Provider.of<SocketService>(context);
    if (socketService.isNewLocation) {
      onNewNotification();
    }
    return Scaffold(
      body: Center(
        child: socketService.isNewLocation
            ? newNotifationWidget()
            : socketService.isSendingLocation
                ? sendingWidget()
                : normalStateWidget(),
      ),
    );
  }

  Widget normalStateWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          decoration: InputDecoration(
              labelText: "Type your name", labelStyle: TextStyle()),
          onChanged: (value) {
            setState(() {
              this.name = value;
            });
          },
        ),
        FlatButton(
          onPressed: () {
            socketService.emit('notification', {'name': this.name});
            sendingNotification();
            //playSong();
          },
          child: Text("Shake your phone"),
        ),
      ],
    );
  }

  Widget newNotifationWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('images/bell2.gif'),
        Text("New notification from ${socketService.lng}"),
      ],
    );
  }

  Widget sendingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('images/bell2.gif'),
        Text("Sending notification"),
      ],
    );
  }
}