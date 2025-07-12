import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'package:weather_animation/weather_animation.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  FavouritesPageState createState() => FavouritesPageState();
}

class FavouritesPageState extends State<FavouritesPage> {
  @override
  void initState() {
    super.initState();
    // Trigger fade-in after build
    Future.delayed(const Duration(milliseconds: 5000), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  double _opacity = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Weather animation as the background
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const WrapperScene(
                  colors: [
                    Color(0xff283593),
                    Color(0xffff8a65),
                  ],
                  children: [
                    SunWidget(),
                    CloudWidget(),
                    WindWidget(),
                    RainWidget(),
                    SnowWidget(),
                  ],
                ),
                Center(
                  child: AnimatedOpacity(
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    opacity: _opacity,
                    child: Text(
                      'It’ll be really hot tomorrow!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Your custom weather message
        ],
      ),
    );
  }
}
