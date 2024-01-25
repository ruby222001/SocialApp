import 'package:app/components/components/list_in_drawer.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
    final void Function()? onSignout;

  const MyDrawer({super.key,
  required this.onProfileTap,
  required this.onSignout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const DrawerHeader(child: Icon(Icons.person,
              color:Colors.white,
              size: 64,),
              ),
              MyListTile2(
                icon: Icons.home, 
                text: 'Home',
                onTap: () =>  Navigator.pop(context),
              ),
              MyListTile2(
                icon: Icons.person, 
                text: 'Profile', 
                   onTap:onProfileTap,
              ),
            ],
          ),
Padding(
  padding: const EdgeInsets.only(bottom: 25),
  child: MyListTile2(icon: Icons.logout,
   text: "Logout",
    onTap: onSignout,
    ),
), 
      ],
      ),
    );
  }
}
