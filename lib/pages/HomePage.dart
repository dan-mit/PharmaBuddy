import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pharmabuddy/models/notification_manager.dart';
import 'package:pharmabuddy/pages/DashboardPage.dart';
import 'package:pharmabuddy/pages/LocatePage.dart';
import 'package:pharmabuddy/pages/Schedulepage.dart';
import 'package:pharmabuddy/pages/SearchPage.dart';

class HomePage extends StatefulWidget {
  final NotificationManager notificationManager;

  const HomePage({Key? key, required this.notificationManager})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0; //Default index for page switching
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      DashboardPage(),
      SearchPage(),
      // Pass notificationManager to SchedulePage
      SchedulePage(notificationManager: widget.notificationManager),
      LocatePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex], //display page according to index
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.0),
        child: GNav(
          selectedIndex: selectedIndex,
          onTabChange: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          padding: EdgeInsets.all(16),
          tabBackgroundColor: Color.fromARGB(50, 158, 158, 158),
          gap: 8,
          textSize: 7,
          tabs: const [
            GButton(icon: Icons.home, text: 'Dashboard'),
            GButton(icon: Icons.search, text: 'Search'),
            GButton(icon: Icons.schedule, text: 'Schedule'),
            GButton(icon: Icons.pin_drop, text: 'Locate')
          ],
        ),
      ),
    );
  }
}
