import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Launch Price Predictor',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: LaunchPredictionForm(),
    );
  }
}
class LaunchPredictionForm extends StatefulWidget {
  @override
  _LaunchPredictionFormState createState() => _LaunchPredictionFormState();
}
class _LaunchPredictionFormState extends State<LaunchPredictionForm> {
  final _formKey = GlobalKey<FormState>();

  int? year;
  String? organisation;
  String? rocketStatus;
  String? missionStatus;
  String? country;

  final organisations = [
    "AEB", "AMBA", "ASI", "Arianespace", "Armée de l'Air",
    "Blue Origin", "Boeing", "CASC", "CASIC", "CECLES", "CNES", "Douglas",
    "EER", "ESA", "Eurockot", "ExPace", "Exos", "General Dynamics",
    "IAI", "ILS", "IRGC", "ISA", "ISAS", "ISRO", "JAXA", "KARI", "KCST",
    "Khrunichev", "Kosmotras", "Land Launch", "Landspace", "Lockheed", "MHI",
    "MITT", "Martin Marietta", "NASA", "Northrop", "OKB-586", "OneSpace",
    "RAE", "RVSN USSR", "Rocket Lab", "Roscosmos", "SRC", "Sandia",
    "Sea Launch", "SpaceX", "Starsem", "ULA", "US Air Force", "US Navy",
    "UT", "VKS RF", "Virgin Orbit", "Yuzhmash", "i-Space"
  ];
  final rocketStatuses = ['StatusActive', 'StatusRetired'];
  final missionStatuses = [
    'Failure', 'Partial Failure', 'Prelaunch Failure', 'Success'
  ];
  final countries =[
    "Australia", "Barents Sea", "Brazil", "China", "France",
    "Gran Canaria", "India", "Iran", "Israel", "Japan",
    "Kazakhstan", "Kenya", "New Mexico", "New Zealand",
    "North Korea", "Pacific Missile Range Facility",
    "Pacific Ocean", "Russia", "Shahrud Missile Test Site",
    "South Korea", "USA", "Yellow Sea"
  ];

  String? prediction;
  List<String> predictionHistory = [];

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final url = Uri.parse('https://satprediction.onrender.com/predict');

    final body = jsonEncode({
      'Year': year,
      'Organisation': organisation,
      'Rocket_Status': rocketStatus,
      'Mission_Status': missionStatus,
      'Country': country,
    });

    setState(() => prediction = "Loading...");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final price = data['predicted_price_million_usd'];
        final roundedPrice = double.parse(price.toString()).toStringAsFixed(5);
        final newPrediction = "Predicted Price: $roundedPrice million USD";

        setState(() {
          prediction = newPrediction;
          predictionHistory.insert(0, newPrediction); // add to top of history
        });
      } else {
        setState(() {
          prediction = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        prediction = 'Request failed: $e';
      });
    }
  }

  void clearHistory() {
    setState(() {
      predictionHistory.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/space.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D0D2B).withOpacity(0.6),  // 60% opacity
                  Color(0xFF1E1E3F).withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '🚀 Launch Price Predictor',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          _buildCardField(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Year',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Enter year';
                                final y = int.tryParse(val);
                                if (y == null || y < 1950 || y > 2100) {
                                  return 'Year must be 1950-2100';
                                }
                                return null;
                              },
                              onSaved: (val) => year = int.parse(val!),
                            ),
                          ),
                          _buildCardField(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Organisation',
                                prefixIcon: Icon(Icons.apartment),
                              ),
                              items: organisations
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              validator: (val) => val == null ? 'Select organisation' : null,
                              onChanged: (val) => organisation = val,
                              onSaved: (val) => organisation = val,
                            ),
                          ),
                          _buildCardField(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Rocket Status',
                                prefixIcon: Icon(Icons.rocket_launch),
                              ),
                              items: rocketStatuses
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              validator: (val) => val == null ? 'Select rocket status' : null,
                              onChanged: (val) => rocketStatus = val,
                              onSaved: (val) => rocketStatus = val,
                            ),
                          ),
                          _buildCardField(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Mission Status',
                                prefixIcon: Icon(Icons.flag),
                              ),
                              items: missionStatuses
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              validator: (val) => val == null ? 'Select mission status' : null,
                              onChanged: (val) => missionStatus = val,
                              onSaved: (val) => missionStatus = val,
                            ),
                          ),
                          _buildCardField(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Country',
                                prefixIcon: Icon(Icons.public),
                              ),
                              items: countries
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              validator: (val) => val == null ? 'Select country' : null,
                              onChanged: (val) => country = val,
                              onSaved: (val) => country = val,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              elevation: 6,
                            ),
                            child: const Text(
                              'Predict',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (prediction != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.deepPurple),
                              ),
                              child: Text(
                                prediction!,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          if (predictionHistory.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Prediction History',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: clearHistory,
                                  child: const Text('Clear History'),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.deepPurple),
                              ),
                              constraints: BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: predictionHistory.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      predictionHistory[index],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardField({required Widget child}) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: child,
      ),
    );
  }
}
