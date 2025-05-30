import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'screens/generator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sable Sky',
        // theme: ThemeData(
        //   useMaterial3: true,
        //   colorScheme: ColorScheme(
        //     brightness: Brightness.light,
        //     primary: Color(0xFF202B41),
        //     onPrimary: Colors.white,
        //     secondary: Color(0xFF07111a),
        //     onSecondary: Colors.white,
        //     error: Color(0xFF202B41),
        //     onError: Color(0xFF202B41),
        //     surface: Colors.white,
        //     onSurface: Color(0xFF202B41),
        //   ),
        // ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      // case 1:
      //   page = const FavouritesPage();
      //   break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: page,
              ),
            ],
          ),
          // bottomNavigationBar: NavigationBar(
          //   onDestinationSelected: (int index) {
          //     setState(() {
          //       selectedIndex = index;
          //     });
          //   },
          //   indicatorColor: Theme.of(context).colorScheme.secondary,
          //   selectedIndex: selectedIndex,
          //   destinations: const <Widget>[
          //     NavigationDestination(
          //       selectedIcon: Icon(Icons.home),
          //       icon: Icon(Icons.home_outlined),
          //       label: 'Home',
          //     ),
          //     // NavigationDestination(
          //     //   selectedIcon: Icon(Icons.favorite),
          //     //   icon: Icon(Icons.favorite_border),
          //     //   label: 'Favorites',
          //     // ),
          //   ],
          // ),
        );
      },
    );
  }
}
