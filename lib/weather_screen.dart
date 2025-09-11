import 'dart:convert';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Berlin';
      String openWeatherAPIKey = dotenv.env['API_ID'] ?? '';

      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (data['cod'].toString() != '200') {
        throw 'An unexpected error occurred: ${data['message'] ?? data['cod']}';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  double kelvinToFahrenheit(num k) {
    return (k - 273.15) * 9 / 5 + 32;
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  Color _getTextColor(Color bgColor) {
    return ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final list = data['list'] as List<dynamic>;
          if (list.isEmpty) {
            return const Center(child: Text('No forecast data'));
          }

          final currentWeatherData = list[0] as Map<String, dynamic>;

          final currentTempNum = (currentWeatherData['main']['temp'] as num);
          final currentTemp =
              "${kelvinToFahrenheit(currentTempNum).toStringAsFixed(1)} °F";
          final rawSky = (currentWeatherData['weather'][0]['main'] as String);
          final currentSky = rawSky;
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];

          
          final int hourlyCount = min(10, list.length - 1);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentTemp,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Icon(
                              currentSky.toLowerCase().contains('cloud') ||
                                      currentSky.toLowerCase().contains('rain')
                                  ? Icons.cloud
                                  : Icons.wb_sunny,
                              size: 70,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentSky,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    'Hourly Forecast',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),

                  
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      itemCount: hourlyCount,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      itemBuilder: (context, index) {
                        final hourlyForecast =
                            list[index + 1] as Map<String, dynamic>;
                        final hourlySky =
                            (hourlyForecast['weather'][0]['main'] as String);
                        final hourlyTempNum =
                            (hourlyForecast['main']['temp'] as num);
                        final hourlyTemp =
                            "${kelvinToFahrenheit(hourlyTempNum).toStringAsFixed(1)} °F";
                        final time = DateTime.parse(
                          hourlyForecast['dt_txt'] as String,
                        );
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: HourlyForecastItem(
                            time: DateFormat('h a').format(time),
                            temperature: hourlyTemp,
                            icon: hourlySky.toLowerCase().contains('cloud') ||
                                    hourlySky.toLowerCase().contains('rain')
                                ? Icons.cloud
                                : Icons.wb_sunny,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoCard(
                        bgColor: Colors.blue[100]!,
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: "$currentHumidity%",
                      ),
                      _buildInfoCard(
                        bgColor: Colors.blue[200]!,
                        icon: Icons.air,
                        label: 'Wind',
                        value: "$currentWindSpeed m/s",
                      ),
                      _buildInfoCard(
                        bgColor: Colors.blue[300]!,
                        icon: Icons.speed,
                        label: 'Pressure',
                        value: "$currentPressure hPa",
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    'Weather Tips',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildTipCard(
                    color: Colors.yellow[200]!,
                    icon: Icons.wb_sunny,
                    iconColor: Colors.orange,
                    title: "Sunny Day",
                    text:
                        "It is a bright sunny day. Wear sunglasses, apply sunscreen, and drink plenty of water to stay hydrated. Avoid going outside during peak afternoon hours, and wear light clothes.",
                  ),
                  const SizedBox(height: 15),

                  _buildTipCard(
                    color: Colors.blue[700]!, 
                    icon: Icons.umbrella,
                    iconColor: Colors.white,
                    title: "Rainy Day",
                    text:
                        "Rain is expected. Carry an umbrella or a raincoat to stay dry. Roads may be slippery, so be cautious while walking or driving. Avoid flood-prone areas, and wear waterproof shoes if possible.",
                  ),
                  const SizedBox(height: 15),

                  _buildTipCard(
                    color: Colors.grey[300]!,
                    icon: Icons.air,
                    iconColor: Colors.grey[800]!,
                    title: "Windy Day",
                    text:
                        "Strong winds are blowing today. Secure any loose outdoor items such as furniture or plants. Be careful when driving, especially on highways. If cycling or walking, be cautious of sudden gusts.",
                  ),
                  const SizedBox(height: 15),

                  _buildTipCard(
                    color: Colors.indigo[700]!, 
                    icon: Icons.ac_unit,
                    iconColor: Colors.white,
                    title: "Snowy Day",
                    text:
                        "Snowfall is expected today. Wear warm clothing, gloves, and boots. Drive slowly on icy roads and avoid unnecessary travel to stay safe.",
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required Color bgColor,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final textColor = _getTextColor(bgColor);

    return Card(
      color: bgColor,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: textColor),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard({
    required Color color,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String text,
  }) {
    final textColor = _getTextColor(color);

    return Card(
      color: color,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: iconColor),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(fontSize: 16, height: 1.4, color: textColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
