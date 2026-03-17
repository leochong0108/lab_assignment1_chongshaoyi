import 'package:firebase_ai/firebase_ai.dart';
import 'dart:convert';

class AiService {
  /// Generates personalized travel suggestion using Firebase Vertex AI.
  static Future<Map<String, dynamic>> getTravelRecommendation({
    required int duration,
    required double budget,
    required int participants,
    required String destination,
    required String travelType,
  }) async {
    // Model initialization through Firebase AI SDK
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash-lite',
      generationConfig: GenerationConfig(temperature: 0.7),
    );

    final prompt =
        '''
You are a professional travel planner. Please provide a personalized travel suggestion based on the following parameters:
- Destination: $destination
- Duration: $duration days
- Budget: RM $budget
- Number of Participants: $participants
- Type of Travel: $travelType

Return the response ONLY in valid JSON format. Do not use Markdown tags (e.g. ```json). The JSON should have the following exact structure:
{
  "title": "A catchy title for the trip",
  "summary": "A short brief about the trip",
  "itinerary": [
    {
      "day": 1,
      "activities": ["Activity 1", "Activity 2"]
    }
  ],
  "budgetBreakdown": "A short note on how the budget might be spent",
  "tips": ["Tip 1", "Tip 2"]
}
''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    if (response.text != null) {
      try {
        var cleanedText = response.text!.trim();
        if (cleanedText.startsWith('```json')) {
          cleanedText = cleanedText.substring(7);
        }
        if (cleanedText.endsWith('```')) {
          cleanedText = cleanedText.substring(0, cleanedText.length - 3);
        }

        final jsonResponse = jsonDecode(cleanedText.trim());
        return jsonResponse;
      } catch (e) {
        throw Exception(
          'Failed to parse AI response: $e\nOriginal Response: ${response.text}',
        );
      }
    } else {
      throw Exception('No response from AI.');
    }
  }
}
