import 'package:flutter/material.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  String _selectedTravelType = 'Mid-Range';
  final List<String> _travelTypes = ['Budget', 'Mid-Range', 'Luxury'];

  @override
  void dispose() {
    _durationController.dispose();
    _budgetController.dispose();
    _participantsController.dispose();
    _destinationController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Navigate to Result Screen with collected parameters
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            apiKey: _apiKeyController.text,
            duration: int.parse(_durationController.text),
            budget: double.parse(_budgetController.text),
            participants: int.parse(_participantsController.text),
            destination: _destinationController.text,
            travelType: _selectedTravelType,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Planner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Configure your ideal trip',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // API Key
                TextFormField(
                  controller: _apiKeyController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Gemini API Key',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.key),
                    helperText: "Required for AI logic. Get it from Google AI Studio.",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'API Key is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Destination
                TextFormField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination of Choice',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a destination';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Trip Duration
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Trip Duration (days)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter trip duration';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Travel Budget
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Travel Budget (RM)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter travel budget';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Number of Participants
                TextFormField(
                  controller: _participantsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of Participants',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter number of participants';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Type of Travel
                DropdownButtonFormField<String>(
                  value: _selectedTravelType,
                  decoration: const InputDecoration(
                    labelText: 'Type of Travel',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flight_class),
                  ),
                  items: _travelTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTravelType = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Generate Travel Plan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
