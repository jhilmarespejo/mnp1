import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mnp1/screens/sync_screen.dart';
import 'package:mnp1/screens/login_screen.dart';
// import 'package:mnp1/screens/user_list_screen.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  VideoState createState() => VideoState();
}

class VideoState extends State<Splash> with SingleTickerProviderStateMixin {
  var _visible = true;

  late AnimationController animationController;
  late Animation<double> animation;

  startTime() async {
    var duration = const Duration(seconds: 2);
    return Timer(duration, navigationPage);
  }

  void navigationPage() {
      Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SyncScreen()));
      // MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   mainAxisSize: MainAxisSize.min,
          //   children: <Widget>[
          //     Padding(
          //         padding: const EdgeInsets.only(bottom: 30.0),
          //         child: Image.asset(
          //           'assets/escudo.png',
          //           height: 60.0,
          //           fit: BoxFit.scaleDown,
          //         ))
          //   ],
          // ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logo-dp-mnp.png',
                width: 250,
                // height:  350,
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_circle_right_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SyncScreen())
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
