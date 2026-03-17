class ImageService {
  /// Generates a travel destination poster URL using Pollinations AI.
  static String generatePosterUrl({
    required String destination,
    required String travelType,
  }) {
    // Construct the prompt for the image generation
    final prompt =
        'A beautiful, high-quality, cinematic travel poster of $destination. Style: modern, vibrant, professional travel advertising. Vibe: $travelType travel experience, breathtaking scenery, no text.';

    // Encode the prompt for the URL
    final encodedPrompt = Uri.encodeComponent(prompt);

    // Return the URL for the generated image
    return 'https://image.pollinations.ai/prompt/$encodedPrompt?width=800&height=1200&nologo=true';
  }
}
