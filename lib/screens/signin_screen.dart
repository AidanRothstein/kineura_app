import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:ui';
import 'dashboard_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen>
    with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  // Animation Controllers
  late AnimationController _formController;
  late AnimationController _titleController;
  late AnimationController _buttonController;

  // Animations
  late Animation<double> _titleOpacityAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _formOpacityAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _buttonOpacityAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  // Design Constants
  static const double spacingS = 16.0;
  static const double spacingM = 24.0;
  static const double spacingL = 32.0;
  static const double borderRadius = 12.0;
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color primaryColorLight = Color(0xFF42A5F5);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _formController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Title animations
    _titleOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeIn,
    ));

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOutCubic,
    ));

    // Form animations
    _formOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeIn,
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    ));

    // Button animations
    _buttonOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeIn,
    ));

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    _titleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _formController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_usernameController.text.trim().isEmpty || 
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are already signed in.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
        return;
      }

      final result = await Amplify.Auth.signIn(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result.isSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Sign-in incomplete. Please check your credentials.';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _titleController,
      builder: (context, child) {
        return SlideTransition(
          position: _titleSlideAnimation,
          child: FadeTransition(
            opacity: _titleOpacityAnimation,
            child: Column(
              children: [
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: 'SourceSans3',
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'SourceSans3',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedForm() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return SlideTransition(
          position: _formSlideAnimation,
          child: FadeTransition(
            opacity: _formOpacityAnimation,
            child: Column(
              children: [
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: spacingS),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'SourceSans3',
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontFamily: 'SourceSans3',
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: spacingS,
              vertical: spacingS,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton() {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return SlideTransition(
          position: _buttonSlideAnimation,
          child: FadeTransition(
            opacity: _buttonOpacityAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryColor, primaryColorLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(borderRadius),
                  onTap: _isLoading ? null : _signIn,
                  child: Container(
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'SourceSans3',
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(top: spacingS),
      padding: const EdgeInsets.all(spacingS),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade300,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 14,
                fontFamily: 'SourceSans3',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (same as home page)
          Image.asset(
            'assets/Rothstein-1RM_1622.JPG',
            fit: BoxFit.cover,
            alignment: Alignment(0.3, 0.0),
          ),
          
          // Enhanced Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          
          // Blur Effect Layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.08,
                  vertical: spacingL,
                ),
                child: Column(
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    
                    // Animated Title
                    _buildAnimatedTitle(),
                    
                    const SizedBox(height: spacingL * 2),
                    
                    // Glass Container with Form
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                        child: Container(
                          padding: const EdgeInsets.all(spacingL),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildAnimatedForm(),
                              _buildErrorMessage(),
                              const SizedBox(height: spacingL),
                              _buildAnimatedButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: spacingL),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
