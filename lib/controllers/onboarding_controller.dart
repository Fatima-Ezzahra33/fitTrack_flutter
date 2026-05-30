/// FitTrack : Onboarding controller
///
/// Manages the onboarding flow: page navigation, progress tracking,
/// and marking onboarding as complete via PreferencesService.
library;
import 'package:flutter/material.dart';

import '../models/onboarding_page_model.dart';
import '../services/preferences_service.dart';

class OnboardingController extends ChangeNotifier {
  final PreferencesService _prefsService;
  final PageController pageController = PageController();

  int _currentPage = 0;
  final List<OnboardingPage> _pages = OnboardingPage.defaultPages;

  OnboardingController({required this._prefsService});

  /// The list of onboarding pages.
  List<OnboardingPage> get pages => _pages;

  /// Current page index (0-based).
  int get currentPage => _currentPage;

  /// Total number of pages.
  int get totalPages => _pages.length;

  /// Progress as a fraction (0.0 to 1.0).
  double get progress => (_currentPage + 1) / _pages.length;

  /// Whether we're on the last page.
  bool get isLastPage => _currentPage == _pages.length - 1;

  /// Whether onboarding has been completed in a previous session.
  bool get isOnboardingComplete => !_prefsService.isFirstLaunch();

  /// Called when the PageView page changes (e.g. via swipe).
  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  /// Advance to the next page, or complete if on the last page.
  Future<void> nextPage() async {
    if (isLastPage) {
      await completeOnboarding();
    } else {
      _currentPage++;
      pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  /// Go back to the previous page.
  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  /// Mark onboarding as complete and persist the flag.
  Future<void> completeOnboarding() async {
    await _prefsService.setFirstLaunchComplete();
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
