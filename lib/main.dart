import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _heading = 0;
  late WeatherFactory wf;
  Weather? weather;
  Position? position;

  @override
  void initState() {
    super.initState();
    wf = WeatherFactory("8c98d6abba8789a0628c39cbc1ed2c8a");
    getWeather();
    magnetometerEvents.listen((MagnetometerEvent event) {
      if (mounted) {
        setState(() {
          _heading = _calculateHeading(event.x, event.y, event.z);
        });
      }
    });
  }

  Future<void> getWeather() async {
    final surePosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    position = surePosition;
    weather = await wf.currentWeatherByLocation(
        surePosition.latitude, surePosition.longitude);
    setState(() {});
  }

  double _getArrowAngle() {
    final windDir = weather?.windDegree ?? 0;
    return pi / 180 * windDir;
  }

  double _calculateHeading(double x, double y, double z) {
    double heading = -1 * atan2(y, x);
    if (heading < 0) {
      heading += 2 * pi;
    }
    return heading;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: weather == null || position == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${position?.latitude}, ${position?.longitude}, $weather',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Transform.rotate(
                    angle: _heading,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Transform.rotate(
                          angle: _getArrowAngle(),
                          child: Image.asset(
                            "assets/arrow.png",
                            width: 100.0,
                            height: 200.0,
                            color: Colors.blue,
                          ),
                        ),
                        Image.asset(
                          "assets/compass.png",
                          width: 300.0,
                          height: 300.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getWeather,
        tooltip: 'Increment',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
