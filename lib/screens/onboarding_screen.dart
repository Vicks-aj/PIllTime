import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Never Miss a Dose",
      description:
          "Set smart reminders for all your medications and get notified at the perfect time.",
      imagePath: "assets/images/onboarding_1.jpg", // Your custom image
      icon: Icons.medication, // Fallback icon
    ),
    OnboardingPage(
      title: "Track Your Health",
      description:
          "Monitor your medication adherence with detailed progress tracking and insights.",
      imagePath: "assets/images/onboarding_2.jpg", // Your custom image
      icon: Icons.analytics, // Fallback icon
    ),
    OnboardingPage(
      title: "Stay Organized",
      description:
          "Manage multiple medications with ease using our intuitive scheduling system.",
      imagePath: "assets/images/onboarding_3.jpg", // Your custom image
      icon: Icons.schedule, // Fallback icon
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E3A8A), // Primary blue background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Bottom navigation area
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'SKIP',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      // Next/Get Started button
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentPage == _pages.length - 1
                              ? Color(0xFF10B981)
                              : Colors.white,
                          foregroundColor: _currentPage == _pages.length - 1
                              ? Colors.white
                              : Color(0xFF1E3A8A),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentPage == _pages.length - 1
                                  ? 'GET STARTED'
                                  : 'NEXT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            if (_currentPage < _pages.length - 1) ...[
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch, // Stretch children horizontally
      children: [
        // Image section - now acts as the "card" with all four rounded corners
        Container(
          margin: EdgeInsets.fromLTRB(
              24, 24, 24, 0), // Margin from screen edges, no bottom margin
          decoration: BoxDecoration(
            color: Colors.white, // White background for the image area
            borderRadius:
                BorderRadius.circular(24), // Rounded corners on ALL four sides
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            // Clip the image to match the container's rounded corners
            borderRadius:
                BorderRadius.circular(24), // Rounded corners on ALL four sides
            child: _buildImageWidget(page), // Image fills this container
          ),
        ),

        SizedBox(
            height: 32), // Space between the image block and the title text

        // Title text - outside the image block, on the blue background
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 32.0), // Add horizontal padding for text
          child: Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Text color is white
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: 12), // Space between title and description

        // Description text - outside the image block, on the blue background
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 32.0), // Add horizontal padding for text
          child: Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white
                  .withOpacity(0.8), // Text color is white with opacity
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(OnboardingPage page) {
    // This widget now only focuses on providing the image or fallback icon
    // The clipping and container properties are handled by the parent in _buildPage
    Widget imageOrFallback = Image.asset(
      page.imagePath,
      fit: BoxFit.cover, // Ensure image covers the allocated space
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackIcon(page.icon);
      },
    );

    return Container(
      height: 350, // Increased height for the image section to make it larger
      width: double.infinity, // Take full width of its parent (the white card)
      color:
          Color(0xFF1E3A8A).withOpacity(0.1), // Background for fallback/loading
      child: imageOrFallback,
    );
  }

  Widget _buildFallbackIcon(IconData icon) {
    return Center(
      // Center the icon within its container
      child: Icon(
        icon,
        size: 80,
        color: Color(0xFF1E3A8A),
      ),
    );
  }

  Future<bool> _checkImageExists(String imagePath) async {
    try {
      // Try to load the image to check if it exists
      await AssetImage(imagePath).resolve(ImageConfiguration());
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Colors.white
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon; // Fallback icon

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
  });
}
