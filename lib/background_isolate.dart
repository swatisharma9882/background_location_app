// background_geolocation_isolate.dart

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'dart:isolate';
import 'package:geolocator/geolocator.dart';

geolocationIsolate(SendPort sendPort) async {
  await for (var position in Geolocator.getPositionStream()) {
    debugPrint("position $position");
    sendPort.send(position.toJson()); // Sending JSON representation of position
  }

  debugPrint("sendPort $sendPort");
}
