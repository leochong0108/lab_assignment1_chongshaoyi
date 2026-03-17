import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class ImageGenerationService {
  static const String apiKey = String.fromEnvironment('HF_API_KEY');
  static const String apiUrl =
      'https://router.huggingface.co/hf-inference/models/black-forest-labs/FLUX.1-schnell';

  static Future<Uint8List> generateImage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "inputs": prompt,
          "parameters": {
            "width": 512,
            "height": 768,
            "num_inference_steps": 50,
            "guidance_scale": 7.5,
          },
          "options": {"wait_for_model": true},
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception(
          'Failed to generate image: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('Error generating image: $e');
      rethrow;
    }
  }
}
