import 'package:flutter/material.dart';
import 'package:phamijam/pages/login.dart';
import 'package:provider/provider.dart';
import '../controllers/user.dart';
import '../result.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  _registerPressed(String username, String password, String email) async {
    setState(() {
      _isLoading = true;
    });
    final response = await context.read<UserController>().register(
      username,
      password,
      email,
    );
    setState(() {
      _isLoading = false;
    });
    if (!mounted) return;
    switch (response) {
      case Ok():
        final snackBar = SnackBar(content: Text("Bruger oprettet!"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pop();
        return;
      case Err(message: final message):
        final snackBar = SnackBar(content: Text(message));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
    }
  }

  _gotoLogin() {
    Navigator.of(context).pop(MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    final containerWidth = width < 400 ? width * 0.95 : 350.0;
    final containerPadding = width < 400 ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFFdba43a),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: isPortrait ? height * 0.08 : 24.0,
                    ),
                    child: Container(
                      width: containerWidth,
                      padding: EdgeInsets.all(containerPadding),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: const Color(0xFFb5832e),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 8),
                          Image.asset(
                            "assets/images/p-trans.png",
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 18),
                          TextField(
                            controller: _usernameController,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Username',
                              hintStyle: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 15,
                              ),
                              filled: true,
                              fillColor: Color.fromARGB(32, 217, 213, 207),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white54,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 14),
                          TextField(
                            controller: _passwordController,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 15,
                              ),
                              filled: true,
                              fillColor: Color.fromARGB(32, 217, 213, 207),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white54,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 14),
                          TextField(
                            controller: _emailController,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 15,
                              ),
                              filled: true,
                              fillColor: Color.fromARGB(32, 217, 213, 207),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white54,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () => _registerPressed(
                                        _usernameController.text,
                                        _passwordController.text,
                                        _emailController.text,
                                      ),
                              style: ElevatedButton.styleFrom(
                                elevation: 3.0,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Color(0xFFdba43a),
                                foregroundColor: Colors.white,
                                textStyle: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                      : Text('Register'),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: _gotoLogin,
                            child: Text(
                              "Have an account? Click here!",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
