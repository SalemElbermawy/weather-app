import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Map<String, dynamic>> getWeatherData() async {
    try {
      const cityName = "London";
      final res = await http.get(Uri.parse(
          "https://anywa.netlify.app/.netlify/functions/getWeather?city=$cityName"));
      final data = jsonDecode(res.body);

      if (data.containsKey("error")) {
        throw data["error"];
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.blue.shade50,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Weather App"),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: getWeatherData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final data = snapshot.data!;
            // Current Weather
            final currentTemp = data['main']?['temp']?.toString() ?? "-";
            final currentSky = data['weather']?[0]?['main'] ?? "-";
            final currentPressure = data['main']?['pressure']?.toString() ?? "-";
            final currentWind = data['wind']?['speed']?.toString() ?? "-";
            final currentHumidity = data['main']?['humidity']?.toString() ?? "-";

            // Fake Forecast (10 items, same data but different display)
            final forecastList = List.generate(10, (i) => data);

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Current Weather Card
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text("$currentTemp K",
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Icon(
                          currentSky == "Clouds" || currentSky == "Rain"
                              ? Icons.cloud
                              : Icons.sunny,
                          size: 50,
                        ),
                        const SizedBox(height: 10),
                        Text(currentSky,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Forecast Section
                const Text(
                  "Forecast (Demo 10 items)",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: forecastList.asMap().entries.map((entry) {
                      int i = entry.key;
                      final f = entry.value;

                      // تغيير درجات الحرارة لتبدو مختلفة
                      double baseTemp =
                          f['main']?['temp']?.toDouble() ?? 280.0;
                      double tempOffset = i * 2.5; // فرق بسيط لكل عنصر
                      double fakeTemp = baseTemp + tempOffset;

                      // تغيير الأيقونات عشوائياً بين الشمس والسحب والمطر
                      IconData icon;
                      if (i % 3 == 0) {
                        icon = Icons.sunny;
                      } else if (i % 3 == 1) {
                        icon = Icons.cloud;
                      } else {
                        icon = Icons.grain; // يمثل المطر
                      }

                      return ForecastCard(
                          temp: fakeTemp.toStringAsFixed(1), icon: icon);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                // Additional Info
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InfoCard(
                            icon: Icons.water_drop,
                            label: "Humidity",
                            value: currentHumidity),
                        InfoCard(
                            icon: Icons.wind_power,
                            label: "Wind",
                            value: currentWind),
                        InfoCard(
                            icon: Icons.umbrella,
                            label: "Pressure",
                            value: currentPressure),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Tips Section
                const Text(
                  "Weather Tips",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TipsCard(
                  icon: Icons.sunny,
                  color: Colors.orange.shade200,
                  title: "Sunny Day",
                  message: "Wear sunglasses and drink plenty of water.",
                ),
                TipsCard(
                  icon: Icons.cloud,
                  color: Colors.blue.shade100,
                  title: "Cloudy",
                  message: "Perfect day for a walk, but keep a jacket handy.",
                ),
                TipsCard(
                  icon: Icons.water_drop,
                  color: Colors.blue.shade300,
                  title: "Rainy",
                  message: "Don’t forget your umbrella before heading out!",
                ),
                TipsCard(
                  icon: Icons.wind_power,
                  color: Colors.grey.shade300,
                  title: "Windy",
                  message: "Secure loose items and avoid cycling in strong winds.",
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ForecastCard extends StatelessWidget {
  final String temp;
  final IconData icon;
  const ForecastCard({required this.temp, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 36),
              const SizedBox(height: 8),
              Text("$temp K", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const InfoCard(
      {required this.icon, required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}

class TipsCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const TipsCard(
      {required this.icon,
      required this.color,
      required this.title,
      required this.message,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        color: color,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.black87),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(message,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
