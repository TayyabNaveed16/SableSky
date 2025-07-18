import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'package:weather_animation/weather_animation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class TomorrowWeather extends StatefulWidget {
  const TomorrowWeather({super.key});

  @override
  TomorrowWeatherState createState() => TomorrowWeatherState();
}

class TomorrowWeatherState extends State<TomorrowWeather> {
  bool _hasLoggedForecast = false;
  String? mostFrequentWeather;

  void _logForecast(List forecast) {
    if (_hasLoggedForecast || forecast.length <= 1) return;

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowDateOnly =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    //counting occurrences of weather types for tomorrow
    final Map<String, int> weatherCount = {};

    for (int i = 0; i < forecast.length; i++) {
      final entry = forecast[i];
      final entryDate = entry.date;

      final entryDateOnly =
          DateTime(entryDate.year, entryDate.month, entryDate.day);

      if (entryDateOnly == tomorrowDateOnly) {
        final weather = entry.weatherMain?.toLowerCase() ?? 'unknown';
        weatherCount[weather] = (weatherCount[weather] ?? 0) + 1;
        debugPrint("Slot $i: Weather: $weather at Date: $entryDate");
      }
    }

    //Here we are determining the most frequent weather type for tomorrow
    int maxCount = 0;

    weatherCount.forEach((weather, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequentWeather = weather; // 👈 Save to class-level field
      }

      debugPrint("Most frequent weather for tomorrow: $weatherCount");

      // Force "rain" if it appears more than once
      if ((weatherCount['rain'] ?? 0) > 1) {
        mostFrequentWeather = 'rain';
      }
    });

    // final tomorrowWeather = forecast[0].weatherMain;
    // final tomorrowDate = forecast[0].date;

    // debugPrint("Tomorrow’s weather: $tomorrowWeather");
    // debugPrint("Tomorrow’s date: ${tomorrow.toIso8601String()}");
    // debugPrint("Tomorrow’s date from forecast: $tomorrowDate");

    _hasLoggedForecast = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final forecast = Provider.of<MyAppState>(context).forecast;

    if (forecast != null && forecast.length > 1) {
      _logForecast(forecast);
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (mostFrequentWeather == "clear") ...[
                  const WrapperScene(
                    sizeCanvas: Size(350, 540),
                    isLeftCornerGradient: false,
                    colors: [
                      Color(0xFFD50000),
                      Color(0xFFFFD54F),
                    ],
                    children: [
                      SunWidget(
                        sunConfig: SunConfig(
                          width: 360,
                          blurSigma: 17,
                          blurStyle: BlurStyle.solid,
                          isLeftLocation: true,
                          coreColor: Color(0xFFF57C00),
                          midColor: Color(0xFFFFE759),
                          outColor: Color(0xFFFFA629),
                          animMidMill: 1500,
                          animOutMill: 1500,
                        ),
                      ),
                    ],
                  ),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 90.0),
                    child: Text(
                      'Bright day coming up!',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                  Positioned(
                    bottom: 130,
                    left: 10,
                    right: 10,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Lifestyle Tips",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              // Fade in once
                              .animate()
                              .fadeIn(
                                  duration: 1500.ms, curve: Curves.easeInOut)

                              // Then shimmer repeatedly
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .shimmer(
                                  duration: 2500.ms, color: Color(0xFFD50000)),
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white,
                                width: 1.8), // Outline border
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.wb_sunny_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Center(
                                          child: Text(
                                            "Vitamin D time",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.spa_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Text(
                                          "Mandatory SPF",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.local_drink_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Text(
                                          "Stay hydrated",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.directions_walk_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Text(
                                          "Morning walks",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 1500.ms, curve: Curves.easeInOut),
                      ],
                    ),
                  ),
                ] else if (mostFrequentWeather == "clouds") ...[
                  const WrapperScene(
                    sizeCanvas: Size(350, 540),
                    isLeftCornerGradient: true,
                    colors: [
                      Color(0xFF424242),
                      Color(0xFFCFD8DC),
                    ],
                    children: [
                      CloudWidget(
                        cloudConfig: CloudConfig(
                          size: 270,
                          color: Color(0xCCBDBDBD), // ~80% opacity of grey[400]
                          icon: IconData(63056, fontFamily: 'MaterialIcons'),
                          widgetCloud: null,
                          x: 119,
                          y: -50,
                          scaleBegin: 1,
                          scaleEnd: 1.1,
                          scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
                          slideX: 11,
                          slideY: 13,
                          slideDurMill: 4000,
                          slideCurve: Cubic(0.40, 0.00, 0.20, 1.00),
                        ),
                      ),
                      CloudWidget(
                        cloudConfig: CloudConfig(
                          size: 250,
                          color: Color(0x92FAFAFA), // ~57% opacity of grey[50]
                          icon: IconData(63056, fontFamily: 'MaterialIcons'),
                          widgetCloud: null,
                          x: 0,
                          y: 3,
                          scaleBegin: 1,
                          scaleEnd: 1.08,
                          scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
                          slideX: 20,
                          slideY: 0,
                          slideDurMill: 3000,
                          slideCurve: Cubic(0.40, 0.00, 0.20, 1.00),
                        ),
                      ),
                      CloudWidget(
                        cloudConfig: CloudConfig(
                          size: 160,
                          color: Color(0xB5FAFAFA), // ~71% opacity of grey[50]
                          icon: IconData(63056, fontFamily: 'MaterialIcons'),
                          widgetCloud: null,
                          x: 140,
                          y: 97,
                          scaleBegin: 1,
                          scaleEnd: 1.1,
                          scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
                          slideX: 20,
                          slideY: 4,
                          slideDurMill: 2000,
                          slideCurve: Cubic(0.40, 0.00, 0.20, 1.00),
                        ),
                      ),
                    ],
                  ),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 90.0),
                    child: Text(
                      'Looks like a cloudy day tomorrow!',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                  Positioned(
                    bottom: 130,
                    left: 10,
                    right: 10,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Lifestyle Tips",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              // Fade in once
                              .animate()
                              .fadeIn(
                                  duration: 1500.ms, curve: Curves.easeInOut)

                              // Then shimmer repeatedly
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .shimmer(
                                  duration: 2500.ms, color: Color(0xFF424242)),
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white,
                                width: 1.8), // Outline border
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.photo_camera,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Center(
                                          child: Text(
                                            "Snap-worthy skies",
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.directions_walk_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Text(
                                          "Great for walks",
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.menu_book_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Text(
                                          "Perfect for reading",
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.self_improvement_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Text(
                                          "Time to reflect",
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 1500.ms, curve: Curves.easeInOut),
                      ],
                    ),
                  ),
                ] else if (mostFrequentWeather == "rain") ...[
                  WrapperScene(
                    sizeCanvas: Size(350, 540),
                    isLeftCornerGradient: false,
                    colors: [
                      Color(0xff263238),
                      Color(0xff78909c),
                    ],
                    children: [
                      WindWidget(
                        windConfig: WindConfig(
                          width: 5,
                          y: 208,
                          windGap: 10,
                          blurSigma: 6,
                          color: Color.fromRGBO(96, 125, 139, 1),
                          slideXStart: 0,
                          slideXEnd: 350,
                          pauseStartMill: 50,
                          pauseEndMill: 6000,
                          slideDurMill: 1000,
                          blurStyle: BlurStyle.solid,
                        ),
                      ),
                      RainWidget(
                        rainConfig: RainConfig(
                          count: 40,
                          lengthDrop: 13,
                          widthDrop: 4,
                          color: Color.fromRGBO(120, 144, 156, 0.6),
                          isRoundedEndsDrop: true,
                          widgetRainDrop: null,
                          fallRangeMinDurMill: 500,
                          fallRangeMaxDurMill: 1500,
                          areaXStart: 41,
                          areaXEnd: 264,
                          areaYStart: 208,
                          areaYEnd: 620,
                          slideX: 2,
                          slideY: 0,
                          slideDurMill: 2000,
                          slideCurve: Cubic(0.40, 0.00, 0.20, 1.00),
                          fallCurve: Cubic(0.55, 0.09, 0.68, 0.53),
                          fadeCurve: Cubic(0.95, 0.05, 0.80, 0.04),
                        ),
                      ),
                      ThunderWidget(
                        thunderConfig: ThunderConfig(
                          thunderWidth: 11,
                          blurSigma: 28,
                          blurStyle: BlurStyle.solid,
                          color: Color.fromRGBO(255, 238, 88, 0.6),
                          flashStartMill: 50,
                          flashEndMill: 300,
                          pauseStartMill: 50,
                          pauseEndMill: 6000,
                          points: [Offset(110.0, 210.0), Offset(120.0, 240.0)],
                        ),
                      ),
                      CloudWidget(
                        cloudConfig: CloudConfig(
                          size: 250,
                          color: Color.fromRGBO(144, 164, 174, 0.68),
                          icon: IconData(63056, fontFamily: 'MaterialIcons'),
                          widgetCloud: null,
                          x: 20,
                          y: 3,
                          scaleBegin: 1,
                          scaleEnd: 1.08,
                          scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
                          slideX: 20,
                          slideY: 0,
                          slideDurMill: 3000,
                          slideCurve: Cubic(0.40, 0.00, 0.20, 1.00),
                        ),
                      ),
                      WindWidget(
                        windConfig: WindConfig(
                          width: 7,
                          y: 300,
                          windGap: 15,
                          blurSigma: 7,
                          color: Color.fromRGBO(96, 125, 139, 1),
                          slideXStart: 0,
                          slideXEnd: 350,
                          pauseStartMill: 50,
                          pauseEndMill: 6000,
                          slideDurMill: 1000,
                          blurStyle: BlurStyle.solid,
                        ),
                      ),
                      CloudWidget(
                        cloudConfig: CloudConfig(
                          size: 160,
                          color: Color.fromRGBO(96, 125, 139, 0.7),
                          icon: IconData(63056, fontFamily: 'MaterialIcons'),
                          widgetCloud: null,
                          x: 140,
                          y: 97,
                          scaleBegin: 1,
                          scaleEnd: 1.1,
                          scaleCurve: Cubic(0.40, 0.00, 0.20, 1.00),
                          slideX: 20,
                          slideY: 4,
                          slideDurMill: 2000,
                          slideCurve: Cubic(0.40, 0.00, 0.20, 1.00),
                        ),
                      ),
                    ],
                  ),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 90.0),
                    child: Text(
                      'Umbrellas up—wet skies ahead!',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                  Positioned(
                    bottom: 130,
                    left: 10,
                    right: 10,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Lifestyle Tips",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              // Fade in once
                              .animate()
                              .fadeIn(
                                  duration: 1500.ms, curve: Curves.easeInOut)

                              // Then shimmer repeatedly
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .shimmer(
                                  duration: 2500.ms, color: Color(0xff78909c)),
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white,
                                width: 1.8), // Outline border
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.fitness_center_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Center(
                                          child: Text(
                                            "Indoor workouts",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.minor_crash_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Text(
                                          "Drive slower",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.umbrella_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Text(
                                          "Umbrella's out",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.water_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Text(
                                          "Avoid puddles",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 1500.ms, curve: Curves.easeInOut),
                      ],
                    ),
                  ),
                ] else if (mostFrequentWeather == "snow") ...[
                  WrapperScene(
                    sizeCanvas: const Size(350, 540),
                    isLeftCornerGradient: true,
                    colors: const [
                      Color(0xff37474f),
                      Color(0xff546e7a),
                      Color(0xffbdbdbd),
                      Color(0xff90a4ae),
                      Color(0xff78909c),
                    ],
                    children: [
                      CloudWidget(
                        cloudConfig: CloudConfig(
                          size: 250,
                          color: const Color.fromRGBO(250, 250, 250, 0.6588),
                          icon: const IconData(63056,
                              fontFamily: 'MaterialIcons'),
                          widgetCloud: null,
                          x: 20,
                          y: 3,
                          scaleBegin: 1,
                          scaleEnd: 1.08,
                          scaleCurve: const Cubic(0.40, 0.00, 0.20, 1.00),
                          slideX: 20,
                          slideY: 0,
                          slideDurMill: 3000,
                          slideCurve: const Cubic(0.40, 0.00, 0.20, 1.00),
                        ),
                      ),
                      WindWidget(
                        windConfig: WindConfig(
                          width: 7,
                          y: 300,
                          windGap: 15,
                          blurSigma: 7,
                          color: const Color.fromRGBO(96, 125, 139, 1.0),
                          slideXStart: 0,
                          slideXEnd: 350,
                          pauseStartMill: 50,
                          pauseEndMill: 6000,
                          slideDurMill: 1000,
                          blurStyle: BlurStyle.solid,
                        ),
                      ),
                      SnowWidget(
                        snowConfig: SnowConfig(
                          count: 10,
                          size: 20,
                          color: const Color.fromRGBO(255, 255, 255, 0.702),
                          icon: const IconData(57399,
                              fontFamily: 'MaterialIcons'),
                          widgetSnowflake: null,
                          areaXStart: 21,
                          areaXEnd: 195,
                          areaYStart: 200,
                          areaYEnd: 540,
                          waveRangeMin: 20,
                          waveRangeMax: 70,
                          waveMinSec: 5,
                          waveMaxSec: 20,
                          waveCurve: const Cubic(0.45, 0.05, 0.55, 0.95),
                          fadeCurve: const Cubic(0.60, 0.04, 0.98, 0.34),
                          fallMinSec: 10,
                          fallMaxSec: 60,
                        ),
                      ),
                      CloudWidget(
                        cloudConfig: CloudConfig(
                          size: 160,
                          color: const Color.fromRGBO(250, 250, 250, 0.6588),
                          icon: const IconData(63056,
                              fontFamily: 'MaterialIcons'),
                          widgetCloud: null,
                          x: 140,
                          y: 97,
                          scaleBegin: 1,
                          scaleEnd: 1.1,
                          scaleCurve: const Cubic(0.40, 0.00, 0.20, 1.00),
                          slideX: 20,
                          slideY: 4,
                          slideDurMill: 2000,
                          slideCurve: const Cubic(0.40, 0.00, 0.20, 1.00),
                        ),
                      ),
                      SnowWidget(
                        snowConfig: SnowConfig(
                          count: 12,
                          size: 20,
                          color: const Color.fromRGBO(255, 255, 255, 0.702),
                          icon: const IconData(62742,
                              fontFamily: 'MaterialIcons'),
                          widgetSnowflake: null,
                          areaXStart: 90,
                          areaXEnd: 230,
                          areaYStart: 200,
                          areaYEnd: 540,
                          waveRangeMin: 20,
                          waveRangeMax: 110,
                          waveMinSec: 5,
                          waveMaxSec: 20,
                          waveCurve: const Cubic(0.45, 0.05, 0.55, 0.95),
                          fadeCurve: const Cubic(0.60, 0.04, 0.98, 0.34),
                          fallMinSec: 10,
                          fallMaxSec: 60,
                        ),
                      ),
                    ],
                  ),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 90.0),
                    child: Text(
                      'Coats on, snow\'s rolling in!',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                  Positioned(
                    bottom: 130,
                    left: 10,
                    right: 10,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Lifestyle Tips",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              // Fade in once
                              .animate()
                              .fadeIn(
                                  duration: 1500.ms, curve: Curves.easeInOut)

                              // Then shimmer repeatedly
                              .animate(
                                  onPlay: (controller) => controller.repeat())
                              .shimmer(
                                  duration: 2500.ms, color: Color(0xff546e7a)),
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white,
                                width: 1.8), // Outline border
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.emoji_food_beverage_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Center(
                                          child: Text(
                                            "Warm drinks",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.minor_crash_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Text(
                                          "Limit driving",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.thermostat_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Text(
                                          "Check heating",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 135,
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(127),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.self_improvement_sharp,
                                            color: Colors.white, size: 24),
                                        SizedBox(height: 5),
                                        Text(
                                          "Enjoy the quiet",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 1500.ms, curve: Curves.easeInOut),
                      ],
                    ),
                  ),
                ] else ...[
                  const Center(
                    child: Text(
                      'No forecast available',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
