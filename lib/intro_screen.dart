import 'package:flutter/material.dart';
import 'signin.dart';
import 'signup.dart';
import 'home.dart';
class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int currentPage = 0;
  final PageController _pageController = PageController();

  // List of pages (replace with your actual data)
  final List<Map<String, String>> viewPage = [
    {
      'image': 'assets/welcome.png',
      'Title': 'Welcome to TinGo ',
      'desc': ''
    },
    {
      'image': 'assets/welcome.png',
      'Title': 'Stay Organized',
      'desc': 'Track your activities seamlessly.'
    },
    {
      'image': 'assets/welcome.png',
      'Title': 'Get Started Now',
      'desc': 'Sign up or sign in to get started!'
    },
    {
      'image': 'assets/welcome.png',
      'Title': 'Get Started Now',
      'desc': 'Sign up or sign in to get started!'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white12,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
Navigator.pushReplacementNamed(context, '/signin');
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 12,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  currentPage = page;
                });
              },
              itemCount: viewPage.length,
              itemBuilder: (context, index) {
                var pageData = viewPage[index];
                return Column(
                  children: [
                    const Spacer(),
                    Expanded(
                      flex: 4,
                      child: Transform.scale(
                        scale: 0.9,
                        child: Image.asset(pageData['image']!, height: 300),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            pageData['Title']!,
                            style: const TextStyle(
                              letterSpacing: 1.1,
                              wordSpacing: 2,
                              height: 1.4,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          pageData['desc']!,
                          style: const TextStyle(
                            wordSpacing: 2,
                            height: 1.4,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 20),
                Row(
                  children: List.generate(viewPage.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _pageController.jumpToPage(index);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4), // Add margin behind dots
                        child: CircleAvatar(
                          backgroundColor: (currentPage == index)
                              ? Colors.red
                              : Colors.grey,
                          radius: (currentPage == index) ? 6 : 3,
                        ),
                      ),
                    );
                  }),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (currentPage < viewPage.length - 1) {
                        currentPage++;
                        _pageController.animateToPage(
                          currentPage,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        // Navigate to login page after last page
Navigator.pushReplacementNamed(context, '/signin');
                      }
                    });
                  },
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red,
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
