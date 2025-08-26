import 'package:flutter/material.dart';

class LoginRegisterForm extends StatefulWidget {
  const LoginRegisterForm({Key? key}) : super(key: key);

  @override
  State<LoginRegisterForm> createState() => _LoginRegisterFormState();
}

class _LoginRegisterFormState extends State<LoginRegisterForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  
  bool _isLogin = true; // true for login, false for register
  
  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _cityController = TextEditingController();
  
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.2, 0.0), // Slide further left with spacing
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    if (_isLogin) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _handleLogin() {
    if (_loginFormKey.currentState!.validate()) {
      // Handle login logic
      print('Login: ${_emailController.text}');
    }
  }

  void _handleRegister() {
    if (_registerFormKey.currentState!.validate()) {
      // Handle register logic
      print('Register: ${_emailController.text}, ${_firstNameController.text}');
    }
  }

  void _handleSocialLogin(String provider) {
    // Handle social login
    print('Login with $provider');
  }

  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: const [
          Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'or',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign in to your account',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          FlexibleTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          FlexibleTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 8),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          
          Center(
            child: TextButton(
              onPressed: _toggleForm,
              child: const Text(
                'Don\'t have an account? Sign up',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          _buildDivider(),

          _buildSocialButton(
            text: 'Continue with Google',
            icon: Icons.login,
            color: Colors.red,
            onPressed: () => _handleSocialLogin('Google'),
          ),
          
          _buildSocialButton(
            text: 'Continue with Facebook',
            icon: Icons.facebook,
            color: Colors.blue[800]!,
            onPressed: () => _handleSocialLogin('Facebook'),
          ),

          const SizedBox(height: 16),
          
          const Center(
            child: Text(
              'By signing in, you agree to our Terms of Service and Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join us today',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          FlexibleTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          FlexibleTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Create a password',
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          FlexibleTextField(
            controller: _firstNameController,
            label: 'First Name',
            hint: 'Enter your first name',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),

          FlexibleTextField(
            controller: _cityController,
            label: 'City',
            hint: 'Enter your city',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your city';
              }
              return null;
            },
          ),

          const SizedBox(height: 8),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          
          Center(
            child: TextButton(
              onPressed: _toggleForm,
              child: const Text(
                'Already have an account? Sign in',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          
          const Center(
            child: Text(
              'By registering, you are accepting our Terms of Service and Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Center(
          child: ClipRect(
            child: SizedBox(
              width: 400,
              child: Stack(
                children: [
                  // Login Form - slides to the left when switching to register
                  SlideTransition(
                    position: _slideAnimation,
                    child: SizedBox(
                      width: 400,
                      child: _buildLoginForm(),
                    ),
                  ),
                  // Register Form - slides from the right when switching from login
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.2, 0.0), // Start further right with spacing
                      end: Offset.zero, // End at center
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeInOut,
                    )),
                    child: SizedBox(
                      width: 400,
                      child: _buildRegisterForm(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FlexibleTextField extends StatefulWidget {
  const FlexibleTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.validator,
  }) : super(key: key);

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isPassword;
  final String? Function(String?)? validator;

  @override
  _FlexibleTextFieldState createState() => _FlexibleTextFieldState();
}

class _FlexibleTextFieldState extends State<FlexibleTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    // Initialize the obscureText state based on the isPassword property
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: widget.controller,
        // Use _obscureText for password fields, otherwise it's always false
        obscureText: _obscureText,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color.fromARGB(255, 255, 145, 0), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // Only show the suffixIcon if it's a password field
          suffixIcon: !widget.isPassword
              ? null
              : IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF999999),
                  ),
                  onPressed: () {
                    // This setState call only affects this one widget
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
        ),
      ),
    );
  }
}