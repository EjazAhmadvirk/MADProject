import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _signupNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _loginPasswordVisible = false;
  bool _signupPasswordVisible = false;

  // Admin credentials saved in code only — NOT in Firebase!
  static const String _adminEmail = 'ejazahmadvirk091@gmail.com';
  static const String _adminPassword = 'Ejaz@Admin123!';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // Admin Login Dialog
  void _showAdminDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool passVisible = false;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.brown),
                SizedBox(width: 8),
                Text('Admin Login',
                    style: TextStyle(
                        color: Colors.brown,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Admin Email',
                    prefixIcon:
                    const Icon(Icons.email, color: Colors.brown),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Colors.brown, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: !passVisible,
                  decoration: InputDecoration(
                    hintText: 'Admin Password',
                    prefixIcon:
                    const Icon(Icons.lock, color: Colors.brown),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.brown,
                      ),
                      onPressed: () => setDialogState(
                              () => passVisible = !passVisible),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Colors.brown, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  String enteredEmail = emailController.text.trim();
                  String enteredPassword =
                  passwordController.text.trim();

                  if (enteredEmail == _adminEmail &&
                      enteredPassword == _adminPassword) {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/admin');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Wrong admin credentials!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Login',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  // Email Login
  Future<void> _login() async {
    String email = _loginEmailController.text.trim();
    String password = _loginPasswordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Please enter a valid email!', Colors.red);
      return;
    }
    if (password.isEmpty) {
      _showSnackBar('Please enter your password!', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showSnackBar('Login failed: ${e.toString()}', Colors.red);
    }
    setState(() => _isLoading = false);
  }

  // Email Signup
  Future<void> _signup() async {
    String name = _signupNameController.text.trim();
    String email = _signupEmailController.text.trim();
    String password = _signupPasswordController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Please enter your name!', Colors.red);
      return;
    }
    if (name.length < 3) {
      _showSnackBar('Name must be at least 3 characters!', Colors.red);
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Please enter a valid email!', Colors.red);
      return;
    }
    if (password.length < 8) {
      _showSnackBar('Password must be at least 8 characters!',
          Colors.red);
      return;
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      _showSnackBar(
          'Password must contain at least one capital letter!',
          Colors.red);
      return;
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      _showSnackBar('Password must contain at least one number!',
          Colors.red);
      return;
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      _showSnackBar(
          'Password must contain at least one special character!',
          Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'role': 'user',
        'createdAt': DateTime.now(),
      });

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showSnackBar('Signup failed: ${e.toString()}', Colors.red);
    }
    setState(() => _isLoading = false);
  }

  // Google Sign In
  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': userCredential.user!.displayName ?? 'User',
        'email': userCredential.user!.email,
        'role': 'user',
        'createdAt': DateTime.now(),
      }, SetOptions(merge: true));

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showSnackBar('Google Sign In failed: ${e.toString()}', Colors.red);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.book, size: 80, color: Colors.brown),
            const SizedBox(height: 10),
            const Text('Book Shop',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown)),
            const SizedBox(height: 30),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.brown.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.brown,
                tabs: const [
                  Tab(text: 'Login'),
                  Tab(text: 'Sign Up'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // LOGIN TAB
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration:
                          _inputDecoration('Email', Icons.email),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _loginPasswordController,
                          obscureText: !_loginPasswordVisible,
                          decoration: _inputDecoration(
                            'Password', Icons.lock,
                            suffix: IconButton(
                              icon: Icon(
                                _loginPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.brown,
                              ),
                              onPressed: () => setState(() =>
                              _loginPasswordVisible =
                              !_loginPasswordVisible),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Text('Login',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('OR',
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side:
                              const BorderSide(color: Colors.brown),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.g_mobiledata,
                                color: Colors.red, size: 28),
                            label: const Text('Sign in with Google',
                                style: TextStyle(color: Colors.brown)),
                            onPressed:
                            _isLoading ? null : _googleSignIn,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // SIGNUP TAB
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _signupNameController,
                          decoration:
                          _inputDecoration('Full Name', Icons.person),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _signupEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration:
                          _inputDecoration('Email', Icons.email),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _signupPasswordController,
                          obscureText: !_signupPasswordVisible,
                          decoration: _inputDecoration(
                            'Password', Icons.lock,
                            suffix: IconButton(
                              icon: Icon(
                                _signupPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.brown,
                              ),
                              onPressed: () => setState(() =>
                              _signupPasswordVisible =
                              !_signupPasswordVisible),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.brown.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.brown.shade200),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Password must have:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                              SizedBox(height: 4),
                              Text('• At least 8 characters',
                                  style: TextStyle(fontSize: 11)),
                              Text('• At least one capital letter (A-Z)',
                                  style: TextStyle(fontSize: 11)),
                              Text('• At least one number (0-9)',
                                  style: TextStyle(fontSize: 11)),
                              Text(
                                  '• At least one special character (!@#\$...)',
                                  style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isLoading ? null : _signup,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Text('Sign Up',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('OR',
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side:
                              const BorderSide(color: Colors.brown),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.g_mobiledata,
                                color: Colors.red, size: 28),
                            label: const Text('Sign up with Google',
                                style: TextStyle(color: Colors.brown)),
                            onPressed:
                            _isLoading ? null : _googleSignIn,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Admin Login Button at bottom
            const Divider(),
            TextButton.icon(
              onPressed: _showAdminDialog,
              icon: const Icon(Icons.admin_panel_settings,
                  color: Colors.brown),
              label: const Text(
                'Login as Admin',
                style: TextStyle(
                    color: Colors.brown, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.brown),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.brown, width: 2),
      ),
    );
  }
}