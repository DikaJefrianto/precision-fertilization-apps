import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class LayananAI {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/tanah_model_4class.tflite');
      
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n').where((s) => s.isNotEmpty).toList();
      
      debugPrint("[AI Service] Model 4 Kelas & Label Berhasil Dimuat");
    } catch (e) {
      debugPrint("[AI Service] Gagal memuat model/label: $e");
    }
  }

  Future<Map<String, dynamic>> prediksiLengkap(File imageFile) async {
    if (_interpreter == null) await loadModel();
    if (_interpreter == null) throw Exception("Mesin AI gagal diinisialisasi");

    var imageBytes = imageFile.readAsBytesSync();
    var decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) throw Exception("Gambar tidak dapat terbaca");
    
    var resizedImage = img.copyResize(decodedImage, width: 224, height: 224);

    var input = List.generate(
        1,
        (index) => List.generate(
            224,
            (y) => List.generate(224, (x) {
                  var pixel = resizedImage.getPixel(x, y);
                  return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
                })));

    var output = List.filled(1 * 4, 0.0).reshape([1, 4]);

    _interpreter!.run(input, output);

    int resultIndex = 0;
    double maxScore = -1.0;
    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > maxScore) {
        maxScore = output[0][i];
        resultIndex = i;
      }
    }

    String label = _labels![resultIndex].trim();

    Map<String, double> hara = getHaraOtomatis(label);

    return {
      "label": label,
      "n": hara['n'],
      "p": hara['p'],
      "k": hara['k'],
      "confidence": "${(maxScore * 100).toStringAsFixed(2)}%"
    };
  }


  Map<String, double> getHaraOtomatis(String label) {
    switch (label) {
      case "Tanah Hitam":
        return {"n": 0.45, "p": 3.5, "k": 2.5}; 
      case "Tanah Merah":
        return {"n": 0.12, "p": 0.8, "k": 1.1}; 
      case "Tanah Aluvial":
        return {"n": 0.25, "p": 2.1, "k": 1.8}; 
      case "Tanah Laterit":
        return {"n": 0.18, "p": 1.2, "k": 1.4}; 
      default:
        return {"n": 0.10, "p": 0.5, "k": 0.5};
    }
  }
}