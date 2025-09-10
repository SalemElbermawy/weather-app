import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
String cityName = "London";

final res = await http.get(
  Uri.parse(
    "https://anywa.netlify.app/.netlify/functions/getWeather?city=$cityName",
  ),
);
final data = jsonDecode(res.body);
if (data["cod"].toString() != "200") {
  throw "An unexpected error";
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
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.blue.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.lightBlue.shade400,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 4,
          titleTextStyle: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),

      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Weather_APP",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  getCurrentWeather();
                });
              },
              icon: Icon(Icons.refresh),
            ),
          ],
        ),

        body: FutureBuilder(
          future: getCurrentWeather(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator.adaptive());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final data = snapshot.data!;
            final usage = data['list'][0];

            final currentTemp = usage["main"]["temp"];
            final currentSky = usage["weather"][0]["main"];
            final currentPressure = usage['main']['pressure'];
            final currentWindSpeed = usage['wind']['speed'];
            final currentHumidity = usage['main']['humidity'];

            return ListView(
              children: [
                /// Card: Current Weather
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              children: [
                                Text(
                                  "$currentTemp K",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Icon(
                                  currentSky == 'Clouds' || currentSky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 43,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  currentSky,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Weather Forecast",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(height: 20),

                /// Forecast Cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < 5; i++)
                        Series(
                          time: DateFormat.j().format(
                            DateTime.parse(
                              data['list'][i + 1]["dt_txt"].toString(),
                            ),
                          ),
                          temp: data['list'][i + 1]['main']['temp'].toString(),
                          icon:
                              data["list"][i + 1]['weather'][0]['main'] == "Rain" ||
                                      data["list"][i + 1]['weather'][0]['main'] == "Clouds"
                                  ? Icons.cloud
                                  : Icons.sunny,
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Additional Information",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      LastSeries(
                        icon: Icons.water_drop,
                        type: "Humidity",
                        value: currentHumidity.toString(),
                      ),
                      LastSeries(
                        icon: Icons.wind_power,
                        type: "Wind Speed",
                        value: currentWindSpeed.toString(),
                      ),
                      LastSeries(
                        icon: Icons.umbrella,
                        type: "Pressure",
                        value: currentPressure.toString(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Weather Tips",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),

                /// New Tips Section
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

/// Forecast Card
class Series extends StatelessWidget {
  final String time;
  final String temp;
  final dynamic icon;
  const Series({
    required this.time,
    required this.icon,
    required this.temp,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
          child: Column(
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Icon(icon, size: 40),
              SizedBox(height: 10),
              Text("$temp°F", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extra Info Card
class LastSeries extends StatelessWidget {
  final IconData icon;
  final String type;
  final String value;
  const LastSeries({
    required this.icon,
    required this.type,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(9),
      width: 200,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Icon(icon, size: 32),
            SizedBox(height: 10),
            Text(
              type,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Weather Tips Card
class TipsCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const TipsCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Card(
        color: color,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.black87),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(fontSize: 18, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
