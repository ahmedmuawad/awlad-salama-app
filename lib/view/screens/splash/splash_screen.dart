import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/screens/auth/login_screen.dart';
import 'package:flutter_grocery/view/screens/menu/menu_screen.dart';
import 'package:flutter_grocery/view/screens/onboarding/on_boarding_screen.dart';
import 'package:flutter_grocery/view/screens/set_Language/language_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../data/model/response/config_model.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  StreamSubscription<ConnectivityResult> _onConnectivityChanged;
  LatLng currentPostion;
  List<Branches> _branches = [];
  bool _isAvailable;
  String index;

  @override
  void dispose() {
    _onConnectivityChanged.cancel();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
        print("Location permission denied");
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentPostion = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    bool _firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (!_firstTime) {
        bool isNotConnected = result != ConnectivityResult.wifi && result != ConnectivityResult.mobile;
        isNotConnected ? SizedBox() : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? getTranslated('no_connection', context) : getTranslated('connected', context),
            textAlign: TextAlign.center,
          ),
        ));
        if (!isNotConnected) {
          _route();
        }
      }
      _firstTime = false;
    });

    Provider.of<SplashProvider>(context, listen: false).initSharedData();
    Provider.of<CartProvider>(context, listen: false).getCartData();

    _getUserLocation(); // ✅ إعادة التفعيل هنا
    _route();
  }

  void _route() {
    Provider.of<SplashProvider>(context, listen: false).initConfig(context).then((bool isSuccess) {
      Timer(Duration(seconds: 3), () async {
        if (Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
          Provider.of<AuthProvider>(context, listen: false).updateToken();
          Navigator.of(context).pushNamedAndRemoveUntil(
              RouteHelper.set_lang, (route) => false,
              arguments: LanguageScreen(isFirst: false));
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => OnBoardingScreen(index: index)),
                  (route) => false);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _globalKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(Images.splash_animation, height: 130),
          SizedBox(height: 10),
          Image.asset(Images.app_logo,
              width: MediaQuery.of(context).size.width,
              height: 100,
              color: Theme.of(context).primaryColor),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
