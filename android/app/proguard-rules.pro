-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }

# Keep all classes in the geolocator package
-keep class com.baseflow.geolocator.** { *; }

# Keep all classes related to your isolates
-keep class com.example.location_project.background_geolocation_isolate.** { *; }

# Keep classes and methods used for reflection or dynamic loading
-keepclassmembers class * {
    @io.flutter.embedding.engine.dart.DartMethod
    <methods>;
}
