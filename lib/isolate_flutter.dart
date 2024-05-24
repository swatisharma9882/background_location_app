// main.dart

import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_project/background_isolate.dart';
import 'package:permission_handler/permission_handler.dart';

class IsolateFlutterPage extends StatefulWidget {
  const IsolateFlutterPage({super.key});

  @override
  State<IsolateFlutterPage> createState() => _IsolateFlutterPageState();
}

class _IsolateFlutterPageState extends State<IsolateFlutterPage> {
  ReceivePort _receivePort = ReceivePort();
  List<Map<String, dynamic>> _geolocationUpdates = [];

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
    _receivePort.listen((dynamic data) {
      setState(() {
        _geolocationUpdates.add(data);
      });
    });
  }


  Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location services are denied.Attendance will not be marked.'),
          ),
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions. Attendance will not be marked.')));
    }
  }

   _startBackgroundIsolate() async {
     _showAlertDialog();

    final isolate = await FlutterIsolate.spawn(
       geolocationIsolate,

      _receivePort.sendPort,
    );
    debugPrint("isolate $isolate");
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog( // <-- SEE HERE
          title: const Text('Cancel booking'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure want to cancel booking?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Background Geolocation'),
        ),
        body: Column(children: [
          _geolocationUpdates.isEmpty
              ? const Text('Fetch loaction')
              : SizedBox(
            height: 300,
                child: ListView.builder(
                    itemCount: _geolocationUpdates.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            'Lat: ${_geolocationUpdates[index]['latitude']}'),
                        subtitle: Text(
                            'Long: ${_geolocationUpdates[index]['longitude']}'),
                      );
                    },
                  ),
              ),
          ElevatedButton(
            onPressed:()async  {

              await _startBackgroundIsolate();
              },
            child: const Text('Start Background Geolocation'),
          ),
        ]),
      ),
    );
  }
}
