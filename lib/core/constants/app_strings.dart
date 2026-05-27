/// FitTrack — Application string constants
///
/// All user-facing text is centralized here for consistency
/// and to simplify future internationalization (i18n).
library;

class AppStrings {
  AppStrings._();

  // ── App ───────────────────────────────────────────────────────────
  static const String appName = 'FitTrack';
  static const String appTagline = 'Everybody Can Train';

  // ── Splash ────────────────────────────────────────────────────────
  static const String getStarted = 'Get Started';

  // ── Onboarding ────────────────────────────────────────────────────
  static const String onboardingTitle1 = 'Get Burn';
  static const String onboardingDesc1 =
      "Let's keep burning, to achieve your goals, it hurts only temporarily, if you give up now you will be in pain forever";

  static const String onboardingTitle2 = 'Eat Well';
  static const String onboardingDesc2 =
      "Let's start a healthy lifestyle with us, we can determine your diet every day. Healthy eating is fun";

  static const String onboardingTitle3 = 'Improve Sleep\nQuality';
  static const String onboardingDesc3 =
      'Improve the quality of your sleep with us, good quality sleep can bring a good mood in the morning';

  static const String onboardingTitle4 = 'Track Your Goal';
  static const String onboardingDesc4 =
      "Don't worry if you have trouble determining your goals, we can help you determine your goals and track your goals";

  // ── Auth — Login ──────────────────────────────────────────────────
  static const String welcomeBack = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to continue your fitness journey';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String login = 'Login';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Don't have an account? ";
  static const String register = 'Register';

  // ── Auth — Registration ───────────────────────────────────────────
  static const String createAccount = 'Create Account';
  static const String registerSubtitle = 'Start your fitness journey today';
  static const String step1Title = 'Your Identity';
  static const String step2Title = 'Your Profile';
  static const String step3Title = 'Your Goal';

  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String confirmPassword = 'Confirm Password';
  static const String phoneNumber = 'Phone Number';
  static const String dateOfBirth = 'Date of Birth';
  static const String gender = 'Gender';
  static const String height = 'Height (cm)';
  static const String weight = 'Weight (kg)';
  static const String goalWeight = 'Goal Weight (kg)';
  static const String goalType = 'What is your goal?';

  static const String next = 'Next';
  static const String back = 'Back';
  static const String finish = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account? ';

  // ── Gender options ────────────────────────────────────────────────
  static const String male = 'Male';
  static const String female = 'Female';
  static const String other = 'Other';

  // ── Goal types ────────────────────────────────────────────────────
  static const String loseWeight = 'Lose Weight';
  static const String gainMuscle = 'Gain Muscle';
  static const String keepFit = 'Keep Fit';
  static const String improveSleep = 'Improve Sleep';

  // ── Navigation tabs ───────────────────────────────────────────────
  static const String homeTab = 'Home';
  static const String activityTab = 'Activity';
  static const String searchTab = 'Search';
  static const String cameraTab = 'Camera';
  static const String profileTab = 'Profile';

  // ── Validation messages ───────────────────────────────────────────
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidPhoneNumber = 'Please enter a valid phone number';
  static const String invalidNumber = 'Please enter a valid number';
  static const String loginFailed = 'Invalid email or password';
  static const String registrationFailed = 'Registration failed. Please try again.';
  static const String emailAlreadyExists = 'An account with this email already exists';

  // ── General ───────────────────────────────────────────────────────
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String confirm = 'Confirm';
}
