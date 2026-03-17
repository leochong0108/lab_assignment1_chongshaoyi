import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'services/image_service.dart';
import 'services/ai_service.dart';

class ResultScreen extends StatefulWidget {
  final int duration;
  final double budget;
  final int participants;
  final String destination;
  final String travelType;

  const ResultScreen({
    super.key,
    required this.duration,
    required this.budget,
    required this.participants,
    required this.destination,
    required this.travelType,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<Map<String, dynamic>> _recommendationFuture;
  late Future<Uint8List> _imageFuture;

  @override
  void initState() {
    super.initState();
    
    // Construct the prompt for the image generation
    final imagePrompt = 
        'A beautiful, high-quality, cinematic travel poster of ${widget.destination}. Style: modern, vibrant, professional travel advertising. Vibe: ${widget.travelType} travel experience, breathtaking scenery, no text.';

    _imageFuture = ImageGenerationService.generateImage(imagePrompt);

    _recommendationFuture = AiService.getTravelRecommendation(
      duration: widget.duration,
      budget: widget.budget,
      participants: widget.participants,
      destination: widget.destination,
      travelType: widget.travelType,
    );
  }

  Widget _buildItinerary(List<dynamic> itinerary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: itinerary.map((dayPlan) {
        final int day = dayPlan['day'];
        final List<dynamic> activities = dayPlan['activities'] ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day $day',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...activities.map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          activity.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Plan Result'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _recommendationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating your ideal travel experience...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final String title = data['title'] ?? 'Your Trip';
            final String summary = data['summary'] ?? '';
            final List<dynamic> itinerary = data['itinerary'] ?? [];
            final String budgetBreakdown = data['budgetBreakdown'] ?? '';
            final List<dynamic> tips = data['tips'] ?? [];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // AI Generated Image Poster
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      FutureBuilder<Uint8List>(
                        future: _imageFuture,
                        builder: (context, imageSnapshot) {
                          if (imageSnapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              height: 300,
                              width: double.infinity,
                              color: Colors.black12,
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          } else if (imageSnapshot.hasError) {
                            return Container(
                              height: 300,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                              ),
                            );
                          } else if (imageSnapshot.hasData) {
                            return Image.memory(
                              imageSnapshot.data!,
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                            );
                          } else {
                            return Container(
                              height: 300,
                              width: double.infinity,
                              color: Colors.grey[300],
                            );
                          }
                        },
                      ),
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black87, Colors.transparent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Summary
                        Text(
                          summary,
                          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 24),
                        
                        // Itinerary
                        const Text(
                          'Itinerary',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildItinerary(itinerary),
                        const SizedBox(height: 24),
                        
                        // Budget Breakdown
                        if (budgetBreakdown.isNotEmpty) ...[
                          const Text(
                            'Budget Breakdown',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                budgetBreakdown,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Tips
                        if (tips.isNotEmpty) ...[
                          const Text(
                            'Travel Tips',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: tips.map((tip) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.lightbulb_outline, size: 20, color: Colors.amber),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            tip.toString(),
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }
}
