import 'package:flutter/material.dart';
import 'package:phamijam/pages/home.dart';
import 'package:phamijam/pages/user.dart';
import 'package:phamijam/pages/library.dart';
import 'package:phamijam/pages/create_playlist.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF121212),
      width: 150,
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Divider(
            color: Colors.white,
            thickness: 2.0,
            indent: 15.0,
            endIndent: 15.0,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Color.fromARGB(89, 88, 88, 88),
              minimumSize: Size(120, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Column(
              children: [Icon(Icons.home, color: Colors.white, size: 24)],
            ),
          ),
          Divider(
            color: Colors.white,
            thickness: 2.0,
            indent: 15.0,
            endIndent: 15.0,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => User()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Color.fromARGB(89, 88, 88, 88),
              minimumSize: Size(120, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Column(
              children: [Icon(Icons.person, color: Colors.white, size: 24)],
            ),
          ),
          Divider(
            color: Colors.white,
            thickness: 2.0,
            indent: 15.0,
            endIndent: 15.0,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Library()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Color.fromARGB(89, 88, 88, 88),
              minimumSize: Size(120, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.library_music, color: Colors.white, size: 24),
              ],
            ),
          ),
          Divider(
            color: Colors.white,
            thickness: 2.0,
            indent: 15.0,
            endIndent: 15.0,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePlaylist()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Color.fromARGB(89, 88, 88, 88),
              minimumSize: Size(120, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.playlist_add, color: Colors.white, size: 24),
              ],
            ),
          ),
          Divider(
            color: Colors.white,
            thickness: 2.0,
            indent: 15.0,
            endIndent: 15.0,
          ),
        ],
      ),
    );
  }
}
