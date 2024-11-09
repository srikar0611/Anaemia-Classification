import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  String _loggedInUser = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to validate the username
  bool _isUsernameValid(String username) {
    return username.length >= 4;
  }

  // Function to validate the password
  bool _isPasswordValid(String password) {
    String pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(password);
  }

  // Function to check login
  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Validate username and password
    if (!_isUsernameValid(username)) {
      Fluttertoast.showToast(msg: "Username must be at least 4 characters");
      return;
    }

    if (!_isPasswordValid(password)) {
      Fluttertoast.showToast(
          msg:
              "Password must contain at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPassword = prefs.getString(username);

    if (savedPassword != null && savedPassword == password) {
      Fluttertoast.showToast(msg: "Login successful. Welcome back!");
      setState(() {
        _loggedInUser = username;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientDetailsPage(username: _loggedInUser)),
      );
    } else if (savedPassword != null && savedPassword != password) {
      Fluttertoast.showToast(msg: "Incorrect password");
    } else {
      prefs.setString(username, password);
      Fluttertoast.showToast(msg: "New user registered. Welcome!");
      setState(() {
        _loggedInUser = username;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientDetailsPage(username: _loggedInUser)),
      );
    }
  }

  // Google sign-in logic
  Future<void> _loginWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account != null) {
      Fluttertoast.showToast(msg: "Logged in with Google: ${account.email}");
    }
  }

  // Facebook sign-in logic
  Future<void> _loginWithFacebook() async {
    final result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      final userData = await FacebookAuth.instance.getUserData();
      Fluttertoast.showToast(msg: "Logged in with Facebook: ${userData['email']}");
    }
  }

  // Twitter sign-in logic
  Future<void> _loginWithTwitter() async {
    final twitterLogin = TwitterLogin(
      apiKey: '<YOUR_API_KEY>',
      apiSecretKey: '<YOUR_API_SECRET>',
      redirectURI: '<YOUR_REDIRECT_URI>',
    );

    final result = await twitterLogin.login();
    if (result.status == TwitterLoginStatus.loggedIn) {
      Fluttertoast.showToast(msg: "Logged in with Twitter: ${result.user?.email}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              onPressed: _loginWithGoogle,
              label: const Text('Login with Google'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.facebook),
              onPressed: _loginWithFacebook,
              label: const Text('Login with Facebook'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              onPressed: _loginWithTwitter,
              label: const Text('Login with Twitter'),
            ),
          ],
        ),
      ),
    );
  }
}

class PatientDetailsPage extends StatefulWidget {
  final String username;

  const PatientDetailsPage({super.key, required this.username});

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  String _selectedGender = 'Male';
  File? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.red,
            onPressed: () {
              // Handle logout
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Patient Name'),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            DropdownButton<String>(
              value: _selectedGender,
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
                DropdownMenuItem(value: 'Transgender', child: Text('Transgender')),
                DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              },
            ),
            TextField(
              controller: _symptomsController,
              decoration: const InputDecoration(labelText: 'Symptoms'),
            ),
            const SizedBox(height: 16),
            _image == null
                ? const Text('No image selected.')
                : Image.file(_image!),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Image'),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle get results logic
                },
                child: const Text('Get Results'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
