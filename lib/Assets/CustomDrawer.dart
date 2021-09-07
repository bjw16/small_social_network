import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  // In the constructor, require a Todo
  CustomDrawer();

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create our UI
    return Drawer(
        child: ListView(
      children: [
        TextButton(onPressed: () {}, child: Text("Home")),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/friends");
            },
            child: Text("Friends")),
        TextButton(onPressed: () {}, child: Text("Settings"))
      ],
    ));
  }
}
