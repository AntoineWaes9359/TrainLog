import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/add_trip_screen_v3.dart';

class MethodChannelService {
  static const MethodChannel _channel = MethodChannel('com.trainlog.app/image');

  void setupImageChannel(BuildContext context) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'processImage') {
        final imagePath = call.arguments as String;
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTripScreenV3(
                initialImagePath: imagePath,
              ),
            ),
          );
        }
      }
    });
  }

  Future<void> sendImageToNative(String imagePath) async {
    try {
      await _channel.invokeMethod('processImage', imagePath);
    } on PlatformException catch (e) {
      throw Exception('Erreur lors de l\'envoi de l\'image: ${e.message}');
    }
  }
}
