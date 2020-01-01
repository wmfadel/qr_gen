import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_gen/pages/home_page.dart';
import 'package:qr_gen/providers/qr_provider.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => QRProvider(),
        )
      ],
      child: MaterialApp(
        title: 'QR-Gen',
        debugShowCheckedModeBanner: false,
        initialRoute: HomePage.routeName,
        routes: {
          HomePage.routeName: (context) => HomePage(),
        },
      ),
    );
  }
}
