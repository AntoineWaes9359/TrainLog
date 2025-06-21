import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TicketScannerService {
  final _textRecognizer = TextRecognizer();
  final _picker = ImagePicker();
  XFile? _image;
  final String _mistralApiKey =
      'DzgM4zsrQ3T1zpl4Iy6uEZ3MfaSFea28'; // À remplacer par votre clé API

  Future<String?> _callMistralAPI(String text) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.mistral.ai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_mistralApiKey',
        },
        body: jsonEncode({
          'model': 'mistral-tiny',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Tu es expert analyse de billets de train SNCF. Extrait les informations du texte fourni. Retourne UNIQUEMENT du JSON avec les champs suivants: departureStation, arrivalStation, trainNumber (en général 4 chiffres), trainType (en majuscule: TGV INOUI, TER, OUIGO, LYRIA, etc.), departureDateTime, arrivalDateTime, seatNumber (siège), carNumber (voiture), travelClass, ticketNumber(numero de dossier). Dates OLBIGATOIREMENT au format ISO 8601 (YYYY-MM-DDTHH:MM:SSZ), si pas de valeur, renvoyer null.'
            },
            {'role': 'user', 'content': 'Texte du billet: $text'}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('Erreur API Mistral: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de l\'appel à l\'API Mistral: $e');
      return null;
    }
  }

  Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
      return null;
    }
  }

  Future<String?> processImage(XFile image) async {
    try {
      // Convertir l'image pour MLKit
      final inputImage = InputImage.fromFile(File(image.path));

      // Effectuer l'OCR
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      // Utiliser l'API Mistral pour analyser le texte
      return await _callMistralAPI(recognizedText.text);
    } catch (e) {
      print('Erreur lors du traitement de l\'image: $e');
      return null;
    }
  }

  // Méthode pour afficher l'image scannée
  Widget displayScannedImage() {
    return _image == null
        ? const Text('Aucune image sélectionnée')
        : Image.file(File(_image!.path));
  }

  void dispose() {
    _textRecognizer.close();
  }
}
