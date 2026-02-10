import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import 'pages/homePage.dart';
import 'pages/flightPage.dart';
import 'pages/hotelsPage.dart';
import 'pages/taxiPage.dart';
import 'pages/receiptPage.dart';
import 'pages/loginPage.dart';
import 'pages/registerPage.dart';
import 'pages/chat_bot_page.dart';
import 'providers/travelFormProvider.dart';
import 'providers/guestSelectorProvider.dart';
import 'providers/tabProvider.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TravelFormProvider()),
        ChangeNotifierProvider(create: (_) => TabProvider()),
        ChangeNotifierProvider(create: (_) => GuestSelectorProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DreamScape',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3765A3),
          primary: const Color(0xFF3765A3),
          secondary: const Color(0xFFD72660),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoggedIn) {
          return MainScreen();
        }
        return const LoginPage();
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final List<Widget> screens = [
    const HomePage(),
    const FlightPage(),
    const HotelsPage(),
    const TaxiPage(),
    const ReceiptPage(),
    const ChatBotPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<TabProvider>(
      builder: (context, tabProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: tabProvider.currentIndex,
            children: screens,
          ),
          floatingActionButton: tabProvider.currentIndex != 5
              ? FloatingActionButton(
                  onPressed: () {
                    tabProvider.setIndex(5);
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.chat, color: Colors.white),
                )
              : null,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.blue[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(.1),
                )
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 8,
                ),
                child: GNav(
                  rippleColor: Colors.grey[300]!,
                  hoverColor: Colors.grey[100]!,
                  gap: 8,
                  activeColor: Colors.white,
                  iconSize: 24,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: Colors.blue[300]!,
                  color: Colors.white,
                  selectedIndex: tabProvider.currentIndex,
                  onTabChange: tabProvider.setIndex,
                  tabs: const [
                    GButton(
                      icon: Icons.home,
                      text: 'Home',
                      margin: EdgeInsets.symmetric(horizontal: 5),
                    ),
                    GButton(
                      icon: Icons.flight,
                      text: 'Flights',
                      margin: EdgeInsets.symmetric(horizontal: 5),
                    ),
                    GButton(
                      icon: Icons.hotel,
                      text: 'Hotels',
                      margin: EdgeInsets.symmetric(horizontal: 5),
                    ),
                    GButton(
                      icon: Icons.local_taxi,
                      text: 'Taxis',
                      margin: EdgeInsets.symmetric(horizontal: 5),
                    ),
                    GButton(
                      icon: Icons.receipt,
                      text: 'Receipts',
                      margin: EdgeInsets.symmetric(horizontal: 5),
                    ),
                    GButton(
                      icon: Icons.chat,
                      text: 'Assistant',
                      margin: EdgeInsets.symmetric(horizontal: 5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
