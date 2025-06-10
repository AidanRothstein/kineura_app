import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:ui';
import '../home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  
  // User data
  String _username = '';
  String _name = '';
  String _email = '';
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Animation Controllers
  late AnimationController _headerController;
  late AnimationController _contentController;
  late AnimationController _actionController;
  
  // Animations
  late Animation<double> _headerOpacityAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _contentOpacityAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _actionOpacityAnimation;
  late Animation<Offset> _actionSlideAnimation;
  
  // Design Constants
  static const double spacingXS = 8.0;
  static const double spacingS = 16.0;
  static const double spacingM = 24.0;
  static const double spacingL = 32.0;
  static const double spacingXL = 48.0;
  static const double borderRadius = 12.0;
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color primaryColorLight = Color(0xFF42A5F5);
  static const Color secondaryColor = Color(0xFF2D2D2D);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
    _startAnimations();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _actionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Header animations
    _headerOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeIn,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    // Content animations
    _contentOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    ));

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    // Action animations
    _actionOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _actionController,
      curve: Curves.easeIn,
    ));

    _actionSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _actionController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _contentController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _actionController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Check if user is signed in
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        setState(() {
          _errorMessage = 'User not signed in';
          _isLoading = false;
        });
        return;
      }

      // Get current user
      final user = await Amplify.Auth.getCurrentUser();
      _username = user.username;
      

      // Fetch user attributes
      final attributes = await Amplify.Auth.fetchUserAttributes();
      for (final attribute in attributes) {
        if (attribute.userAttributeKey == CognitoUserAttributeKey.email) {
          _email = attribute.value;
        }
        if (attribute.userAttributeKey == CognitoUserAttributeKey.name) {
          _name = attribute.value;
        }
        
      }

      setState(() {
        _isLoading = false;
      });
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      // Show confirmation dialog
      final shouldSignOut = await _showSignOutDialog();
      if (!shouldSignOut) return;

      await Amplify.Auth.signOut();
      
      if (mounted) {
        // Navigate to home screen and clear navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showSignOutDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SourceSans3',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            color: Colors.white70,
            fontFamily: 'SourceSans3',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'SourceSans3',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'SourceSans3',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return SlideTransition(
          position: _headerSlideAnimation,
          child: FadeTransition(
            opacity: _headerOpacityAnimation,
            child: Container(
              padding: const EdgeInsets.all(spacingL),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [primaryColor, primaryColorLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          offset: const Offset(0, 8),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: spacingM),
                  // Name
                  Text(
                    _name.isNotEmpty ? _name : 'Loading...',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'SourceSans3',
                      letterSpacing: 1.0,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: spacingXS),
                  // Email
                  Text(
                    _email.isNotEmpty ? _email : 'Loading email...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'SourceSans3',
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedContent() {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return SlideTransition(
          position: _contentSlideAnimation,
          child: FadeTransition(
            opacity: _contentOpacityAnimation,
            child: Column(
              children: [
                _buildSectionTitle('Profile Settings'),
                _buildGlassContainer([
                  _buildSettingsTile(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () => _showComingSoonDialog('Edit Profile'),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () => _showComingSoonDialog('Change Password'),
                  ),
                ]),
                const SizedBox(height: spacingL),
                _buildSectionTitle('App Settings'),
                _buildGlassContainer([
                  _buildSettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () => _showComingSoonDialog('Notifications'),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Theme',
                    subtitle: 'Dark mode (Active)',
                    onTap: () => _showComingSoonDialog('Theme Settings'),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Settings',
                    subtitle: 'Control your data and privacy',
                    onTap: () => _showComingSoonDialog('Privacy Settings'),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedActions() {
    return AnimatedBuilder(
      animation: _actionController,
      builder: (context, child) {
        return SlideTransition(
          position: _actionSlideAnimation,
          child: FadeTransition(
            opacity: _actionOpacityAnimation,
            child: Padding(
              padding: const EdgeInsets.all(spacingL),
              child: _buildSignOutButton(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: spacingL, vertical: spacingS),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            fontFamily: 'SourceSans3',
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer(List<Widget> children) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: spacingL),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: ClipRRect(  // Add this ClipRRect wrapper
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Column(children: children),
      ),
    ),
  );
}


  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(spacingS),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(spacingS),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: primaryColorLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'SourceSans3',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.7),
                        fontFamily: 'SourceSans3',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.1),
      height: 1,
      indent: spacingL,
      endIndent: spacingL,
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: _signOut,
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.red.shade300,
                  size: 20,
                ),
                const SizedBox(width: spacingXS),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade300,
                    fontFamily: 'SourceSans3',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: Text(
          feature,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'SourceSans3',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'This feature is coming soon!',
          style: TextStyle(
            color: Colors.white70,
            fontFamily: 'SourceSans3',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: primaryColor,
                fontFamily: 'SourceSans3',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: spacingM),
          Text(
            'Error Loading Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'SourceSans3',
            ),
          ),
          const SizedBox(height: spacingS),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontFamily: 'SourceSans3',
            ),
          ),
          const SizedBox(height: spacingL),
          ElevatedButton(
            onPressed: _loadUserData,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'SourceSans3',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: primaryColor,
          ),
          SizedBox(height: spacingM),
          Text(
            'Loading Profile...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontFamily: 'SourceSans3',
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/night_fb-bg.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0.25, 0.0),
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
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage.isNotEmpty
                    ? _buildErrorState()
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // Back Button
                            Padding(
                              padding: const EdgeInsets.all(spacingS),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(  // Change from BackdropFilter to ClipRRect
                                    borderRadius: BorderRadius.circular(12),
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
                              ),
                            ),

                            // Profile Header
                            _buildAnimatedHeader(),
                            const SizedBox(height: spacingL),
                            // Profile Content
                            _buildAnimatedContent(),
                            const SizedBox(height: spacingL),
                            // Actions
                            _buildAnimatedActions(),
                            const SizedBox(height: spacingL),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
