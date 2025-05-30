import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailedAirQualityCard extends StatelessWidget {
  final int? aqi;

  const DetailedAirQualityCard({super.key, required this.aqi});

  @override
  Widget build(BuildContext context) {
    if (aqi == null) return SizedBox();

    String label = "Unknown";
    String message = "No data available";
    Color color = Colors.grey;

    switch (aqi!) {
      case 1:
        label = "Good";
        message = "Air quality is considered satisfactory.";
        color = Colors.green;
        break;
      case 2:
        label = "Fair";
        message =
            "Air quality is acceptable, but not ideal for some.";
        color = Colors.yellow;
        break;
      case 3:
        label = "Moderate";
        message = "Air quality is acceptable.";
        color = Colors.orange;
        break;
      case 4:
        label = "Poor";
        message = "Air quality is unhealthy for sensitive people.";
        color = const Color.fromARGB(255, 219, 77, 255);
        break;
      case 5:
        label = "Very Poor";
        message = "Air quality is dangerous for all people.";
        color = Colors.brown;
        break;
      default:
        label = "Unknown";
        message = "Unable to determine air quality.";
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(127),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).toInt()),
            blurRadius: 5,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Air Quality: ",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "$label ",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
          const SizedBox(height: 16),
          _buildAQIScaleBar(aqi!),
        ],
      ),
    );
  }

  Widget _buildAQIScaleBar(int aqi) {
    double scalePosition = ((aqi - 1) / 4) * 280;

    return SizedBox(
      height: 16,
      width: 300,
      child: Stack(
        children: [
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: const LinearGradient(colors: [
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.redAccent,
                Colors.purple,
                Colors.brown,
              ]),
            ),
          ),
          Positioned(
            left: scalePosition,
            top: -2,
            child: Icon(Icons.circle, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
