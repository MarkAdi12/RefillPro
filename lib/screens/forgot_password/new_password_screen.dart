import 'package:customer_frontend/screens/init_screen.dart';
import 'package:flutter/material.dart';
import 'package:customer_frontend/screens/login/sign_in_screen.dart';
import 'package:customer_frontend/services/auth_service.dart';

class NewPasswordScreen extends StatefulWidget {
  final bool fromForgotPassword;
  const NewPasswordScreen({super.key, required this.fromForgotPassword});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final PageController _pageController = PageController();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _obscureNewPassword = false;
  bool _obscureConfirmPassword = false;
  final AuthService _authService = AuthService();
  bool get fromForgotPassword => widget.fromForgotPassword;
  bool isLoading = false;
  String? errorMessage;
  final _formKey = GlobalKey<FormState>();

  // Password validation function
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least 1 capital letter';
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least 1 number';
    }
    return null;
  }

  void _nextPage() {
    if (tokenController.text.isEmpty) {
      setState(() {
        errorMessage = "Reset token is required.";
      });
      return;
    }

    setState(() => errorMessage = null);
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  Future<void> _resetPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    String token = tokenController.text;
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    // ✅ Frontend Validations
    if (token.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        errorMessage = "All fields are required.";
        isLoading = false;
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        errorMessage = "Password must be at least 6 characters.";
        isLoading = false;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        errorMessage = "Passwords do not match.";
        isLoading = false;
      });
      return; // Just stop execution, don't jump pages
    }

    final response =
        await _authService.confirmPassword(token, newPassword, confirmPassword);

    setState(() {
      isLoading = false;
      if (response != null) {
        print("API Response: $response");

        if (response.containsKey('error')) {
          errorMessage = response['error'];
          _pageController.jumpToPage(0);
        } else if (response.containsKey('token') &&
            response['token'] == ["Invalid or expired token."]) {
          errorMessage = "Invalid or expired token. Please try again.";
          tokenController.clear();
          _pageController.jumpToPage(0);
        } else {
          if (widget.fromForgotPassword) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const InitScreen()),
            );
          }
        }
      } else {
        errorMessage = "Invalid or Expired OTP. Please Try Again";
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    tokenController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fromForgotPassword ? "Reset Password" : "Change Password"),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildTokenScreen(),
          _buildNewPasswordScreen(),
        ],
      ),
    );
  }

  Widget _buildTokenScreen() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          const Text(
            "OTP Verification",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Subtitle
          const Text(
            "Enter the OTP that was sent to your registered email.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // OTP Input Field
          TextField(
            controller: tokenController,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              fontSize: 18,
            ),
            decoration: InputDecoration(
              labelText: "OTP",
              hintText: "Enter OTP",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          // Error Message (if any)
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),

          // "Next" Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Next", style: TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 12),

          // "Didn’t receive OTP?" + Resend Button
          Text(
            "Didn’t receive OTP?",
            style: TextStyle(color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          GestureDetector(
            onTap: () {}, // Function to resend OTP
            child: Text(
              "Resend",
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPasswordScreen() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              fromForgotPassword ? "Reset Password" : "Change Password",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              "Enter and confirm your new password below.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // New Password Input
            TextFormField(
              controller: newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: "New Password",
                hintText: "Enter your new password",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
              validator: _validatePassword, // ✅ Password validation
            ),
            const SizedBox(height: 16),

            // Confirm Password Input
            TextFormField(
              controller: confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                hintText: "Confirm your new password",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value != newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),

            // Error Message (if any)
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 20),
            // Reset Password Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _resetPassword();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
