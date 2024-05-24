import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String locationText = 'Location updates will appear here';



  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Initialize the background fetch callbacks
  Future<void> initPlatformState() async {
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 5, // Minimum fetch interval in minutes
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ),
          (String taskId) async {
        // Fetch location updates using Geolocator
           await updateLocation();

        // setState(() {
        //   locationText =
        //   'Background Location: ${position.latitude}, ${position.longitude}';
        // });

        // Finish the background task
        BackgroundFetch.finish(taskId);
      },

    );
  }
  void     startBackgroundFetch() {
    // Trigger the background fetch manually when the button is clicked
    BackgroundFetch.start();
    debugPrint("locationText $locationText");
  }

  Future<void> updateLocation() async {
    debugPrint("location update");
    if (await Permission.location.isGranted) {
      debugPrint("Permission ${Permission.location.isGranted}");
      try {
        debugPrint("try");
        // Fetch location updates using Geolocator
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
        debugPrint("position $position");
        setState(() {
          locationText = 'Location: ${position.latitude}, ${position.longitude}';
        });
        debugPrint("locationText $locationText");
      } catch (e) {
        debugPrint('Error fetching location: $e');
        setState(() {
          locationText = 'Error fetching location';
        });
      }
    } else {
      // Request permission
      PermissionStatus status = await Permission.location.request();
      if (status.isGranted) {
        try {
          // Fetch location updates using Geolocator
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          setState(() {
            locationText = 'Location: ${position.latitude}, ${position.longitude}';
          });
          debugPrint("locationText $locationText");
        } catch (e) {
          debugPrint('Error fetching location: $e');
          setState(() {
            locationText = 'Error fetching location';
          });
        }
      } else if (status.isDenied) {
        debugPrint('Error fetching location: ${status.isDenied}');
      } else if (status.isPermanentlyDenied) {
        debugPrint('Error fetching location: ${status.isDenied}');
      }
    }

  }

  // Future<void> startBackgroundFetch() async {
  //   // Start a background fetch manually
  //   int status = await BackgroundFetch.start();
  //   debugPrint('status $status');
  //   if (status == BackgroundFetch.STATUS_AVAILABLE) {
  //     debugPrint('Background fetch started $locationText');
  //
  //   } else {
  //     debugPrint('Error starting background fetch');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Background Fetch Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              locationText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                updateLocation();
                startBackgroundFetch();
              },
              child: const Text('Update Location'),
            ),
          ],
        ),
      ),
    );
  }
}
