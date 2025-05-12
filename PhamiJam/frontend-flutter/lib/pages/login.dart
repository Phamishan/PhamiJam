import 'package:flutter/material.dart';
import 'package:phamijam/pages/register.dart';
import 'package:phamijam/pages/home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  void _gotoRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => Register()));
  }

  void _gotoHome() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFdba43a),
      body: Center(
        child: Container(
          width: 250,
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Color(0xFFb5832e),
          ),
          child: Column(
            children: [
              Column(
                children: [
                  Image.asset("assets/images/p-trans.png", scale: 5.0),

                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(
                          color: Colors.white.withAlpha(230),
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(16, 217, 213, 207),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Colors.white.withAlpha(230),
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(16, 217, 213, 207),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: true,
                    ),
                  ),

                  Padding(padding: EdgeInsets.all(2)),
                  ElevatedButton(
                    onPressed: _gotoHome,
                    style: ElevatedButton.styleFrom(elevation: 3.0),
                    child: Text('Sign in'),
                  ),

                  Padding(padding: EdgeInsets.all(2)),
                  Divider(
                    color: Colors.white,
                    thickness: 2.0,
                    indent: 15.0,
                    endIndent: 15.0,
                  ),

                  Text(
                    "Or sign in with:",
                    style: TextStyle(color: Colors.white),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => debugPrint("test"),
                        icon: ClipOval(
                          child: Image.asset(
                            "assets/images/google_icon.jpg",
                            scale: 30,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(padding: EdgeInsets.all(2)),
                  TextButton(
                    onPressed: _gotoRegister,
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(
                            text: "Don't have an account? Click here!",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
