import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:pro_link/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _universityIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String _selectedRole = 'intern';
  PlatformFile? _selectedPhoto;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _universityIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<ApiService>().register(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole,
        universityId: _selectedRole == 'intern'
            ? _universityIdController.text.trim()
            : null,
        photo: _selectedPhoto,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your account is pending admin approval')),
      );
      Navigator.pop(context);
    } on Exception catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE4E7EC)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 32,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B263B),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Create your Pro-Link account',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Register as an intern or mentor. New accounts stay pending until an admin approves them.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF475467),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: _inputDecoration(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          icon: Icons.badge_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          label: 'Email',
                          hint: 'name@prolink.edu',
                          icon: Icons.alternate_email_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email.';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRole,
                        decoration: _inputDecoration(
                          label: 'Role',
                          hint: 'Select your role',
                          icon: Icons.work_outline,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'intern',
                            child: Text('Intern'),
                          ),
                          DropdownMenuItem(
                            value: 'mentor',
                            child: Text('Mentor'),
                          ),
                        ],
                        onChanged: _isSubmitting
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _selectedRole = value;
                                });
                              },
                      ),
                      if (_selectedRole == 'intern') ...[
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _universityIdController,
                          decoration: _inputDecoration(
                            label: 'University ID',
                            hint: 'Enter your university ID',
                            icon: Icons.school_outlined,
                          ),
                          validator: (value) {
                            if (_selectedRole != 'intern') {
                              return null;
                            }
                            if (value == null || value.trim().isEmpty) {
                              return 'University ID is required for interns.';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                final result = await FilePicker.platform.pickFiles(
                                  // Some Android emulators don't show anything for "Images"
                                  // if MediaStore has no indexed images. Allow any file so the
                                  // user can browse to Download/ and pick a JPG manually.
                                  type: FileType.any,
                                  withData: true,
                                  dialogTitle: 'Select profile photo',
                                );
                                if (!mounted ||
                                    result == null ||
                                    result.files.isEmpty) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No photo selected. If the picker looks empty on the emulator, first add an image to the emulator storage (e.g. Download) or use a real device.',
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }
                                final picked = result.files.single;
                                final ext =
                                    (picked.extension ?? '').toLowerCase().trim();
                                const allowed = {'png', 'jpg', 'jpeg', 'webp'};
                                if (ext.isEmpty || !allowed.contains(ext)) {
                                  if (!mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select an image file (png/jpg/jpeg/webp).',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => _selectedPhoto = picked);
                              },
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(
                          _selectedPhoto == null
                              ? 'Select Profile Photo (optional)'
                              : 'Photo: ${_selectedPhoto!.name}',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'If the picker is empty on the emulator: upload/copy an image into the emulator (Download folder), then try again.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF667085),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          label: 'Password',
                          hint: 'Create a password',
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your password.';
                          }
                          if (value.trim().length < 4) {
                            return 'Password must be at least 4 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: _inputDecoration(
                          label: 'Confirm Password',
                          hint: 'Re-enter your password',
                          icon: Icons.lock_person_outlined,
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please confirm your password.';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1B263B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              'Already have an account?',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF667085),
                              ),
                            ),
                            TextButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                    },
                              child: const Text('Login'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF344054), width: 1.3),
      ),
    );
  }
}
