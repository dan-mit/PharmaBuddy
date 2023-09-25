import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        bottomNavigationBar: GNav(
          tabs: [
            GButton(icon: Icons.home),
            GButton(icon: Icons.search),
            GButton(icon: Icons.schedule),
            GButton(icon: Icons.pin_drop)
          ],
        ),
      );
    }
  }