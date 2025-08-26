import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/features/auth/cubit/auth_cubit.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _cityController = TextEditingController();
  
  
  bool _isLoading = false;
  bool _userExists = false;
  bool _emailChecked = false;
  bool _keepSignedIn = true;
  String _userEmail = '';
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailExists() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter an email address');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final methods = await _auth.fetchSignInMethodsForEmail(_emailController.text.trim());
      setState(() {
        _userExists = methods.isNotEmpty;
        _emailChecked = true;
        _userEmail = _emailController.text.trim();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error checking email: ${e.toString()}');
    }
  }

  Future<void> _signInUser() async {
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _userEmail,
        password: _passwordController.text,
      );
      
      _showSnackBar('Welcome back!');
      // Navigate to home page or handle successful login
      
    } catch (e) {
      _showSnackBar('Login failed: ${e.toString()}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _registerUser() async {
    if (_passwordController.text.isEmpty || 
        _firstNameController.text.isEmpty || 
        _cityController.text.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _userEmail,
        password: _passwordController.text,
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': _userEmail,
        'firstName': _firstNameController.text.trim(),
        'city': _cityController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('Account created successfully!');
      // Navigate to home page or handle successful registration
      
    } catch (e) {
      _showSnackBar('Registration failed: ${e.toString()}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _resetForm() {
    setState(() {
      _emailChecked = false;
      _userExists = false;
      _userEmail = '';
    });
    _emailController.clear();
    _passwordController.clear();
    _firstNameController.clear();
    _cityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Row(
          children: [
            // Left side - Features/Benefits
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(40),
                child: _buildFeatures()
              ),
            ),
            
            // Right side - Sign in form
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder:(context, state) {
                        if (state.status == AuthStatus.unknown || 
                            state.status == AuthStatus.unauthenticated) {
                          return _buildUnknownState(state);
                        } else if (state.status == AuthStatus.emailExists) {
                          return _buildEmailExistsState(state);
                        } else if (state.status == AuthStatus.emailNotFound) {
                          return _buildRegisterState(state);
                        } else {
                          return Text("You are logged in"); // Personal cabinet
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnknownState(state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWelcomeText("Sign in or create your account", false),
        const SizedBox(height: 16),

        // Email input
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'Email or mobile number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // Continue button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: state.isLoading 
              ? null 
              : () {
                context.read<AuthCubit>().checkEmail(_emailController.text.trim());
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
          ),
        ),

        _buildSocialMenu()
      ],
    );
  }

  Widget _buildEmailExistsState(state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBtnBack(),
        _buildWelcomeText("Welcome Back!", false),
        _buildEmailPasswordFields(true),
        _buildSignRegBtn(true, state),
        _buildSocialMenu()
      ]
    );
  }

  Widget _buildRegisterState(state) {
    return Column(
      children: [
        _buildBtnBack(),
        _buildWelcomeText("Create your account", false),
        _buildEmailPasswordFields(false),
        const SizedBox(height: 16),
        TextField(
          controller: _firstNameController,
          decoration: InputDecoration(
            hintText: 'First name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _cityController,
          decoration: InputDecoration(
            hintText: 'City',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _registerUser,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailPasswordFields(bool isUserExists) {
    return Column(
      children: [
        // User's email
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.email, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                _userEmail,
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Password field
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: isUserExists ? 'Enter your password' : 'Create a password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Choose Us?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 40),
        _buildFeatureItem(
          Icons.security,
          'Secure Account Protection',
          'Your data is protected with industry-standard encryption',
        ),
        const SizedBox(height: 24),
        _buildFeatureItem(
          Icons.verified_user,
          'Verified User Reviews',
          'Genuine reviews only from verified customers',
        ),
        const SizedBox(height: 24),
        _buildFeatureItem(
          Icons.local_shipping,
          'Fast & Reliable Delivery',
          'Quick delivery directly from trusted suppliers',
        ),
        const SizedBox(height: 24),
        _buildFeatureItem(
          Icons.support_agent,
          '24/7 Customer Support',
          'Easy returns and dedicated customer service',
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            ...List.generate(5, (index) => Icon(Icons.star, color: Colors.orange, size: 20)),
            const SizedBox(width: 8),
            Text('4.8', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text('Store Reviews', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green[700], size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String text, Color backgroundColor, Color textColor, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(text, style: TextStyle(color: textColor)),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildBtnBack() {
    return Row(
      children: [
        TextButton(
          onPressed: _resetForm,
          child: Text('← Back', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  Widget _buildWelcomeText(String text, bool isSmall) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isSmall? 14 : 24,
        fontWeight: isSmall? FontWeight.normal : FontWeight.bold,
        color: Colors.grey[800],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSocialMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Devider
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('or', style: TextStyle(color: Colors.grey[600])),
            ),
            Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 24),
        
        // Social login buttons
        _buildSocialButton(
          'Sign In with Google',
          Colors.white,
          Colors.black,
          Icons.g_mobiledata_outlined, // Using available icon as placeholder
          () {
            // Handle Google sign in
          },
        ),
        
        const SizedBox(height: 12),
        
        _buildSocialButton(
          'Sign In with Facebook',
          Color(0xFF1877F2),
          Colors.white,
          Icons.facebook,
          () {
            // Handle Facebook sign in
          },
        ),
        
        const SizedBox(height: 12),
        
        _buildSocialButton(
          'Sign In with Apple',
          Colors.black,
          Colors.white,
          Icons.apple,
          () {
            // Handle Apple sign in
          },
        ),       
      ],
    );
  }

  Widget _buildSignRegBtn(bool isUserExists, state) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: state.isLoading ? null : (isUserExists ? _signInUser : _registerUser),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              isUserExists ? 'Sign In' : 'Create Account',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
      ),
    );
  }





}