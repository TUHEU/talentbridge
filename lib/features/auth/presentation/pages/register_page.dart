// lib/features/auth/presentation/pages/register_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/tb_text_field.dart';
import '../controllers/auth_controller.dart';
import 'email_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _form        = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _pwCtrl      = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _picker      = ImagePicker();

  File?     _photo;
  DateTime? _dob;
  String?   _gender;
  bool _showPw = false, _showConfirm = false;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _pwCtrl, _confirmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Add Profile Photo',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
          const SizedBox(height: 20),
          _srcTile(ctx, 'Take a photo',  Icons.camera_alt_rounded,  ImageSource.camera),
          const SizedBox(height: 8),
          _srcTile(ctx, 'Choose from gallery', Icons.photo_library_rounded, ImageSource.gallery),
        ]),
      ),
    );
    if (src == null) return;
    final f = await _picker.pickImage(source: src, imageQuality: 82);
    if (f != null) setState(() => _photo = File(f.path));
  }

  Widget _srcTile(BuildContext ctx, String label, IconData icon, ImageSource src) =>
      ListTile(
        tileColor: AppColors.grey100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Inter')),
        onTap: () => Navigator.pop(ctx, src),
      );

  Future<void> _pickDob() async {
    final p = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1920),
      lastDate:  DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (p != null) setState(() => _dob = p);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final ok = await auth.register(
      fullName:    _nameCtrl.text.trim(),
      email:       _emailCtrl.text.trim(),
      phone:       _phoneCtrl.text.trim(),
      password:    _pwCtrl.text,
      dateOfBirth: _dob != null
          ? '${_dob!.year}-${_dob!.month.toString().padLeft(2,'0')}-${_dob!.day.toString().padLeft(2,'0')}'
          : null,
      gender:      _gender,
      profileImage: _photo,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => EmailVerificationPage(email: _emailCtrl.text.trim())));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.error ?? 'Registration failed'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.white : AppColors.grey900,
        title: Text('Create Account',
            style: TextStyle(
                color: isDark ? AppColors.white : AppColors.grey900,
                fontWeight: FontWeight.w700, fontFamily: 'Inter')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Photo
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.darkCard : AppColors.grey100,
                      border: Border.all(
                          color: AppColors.primary.withAlpha(80), width: 2),
                      image: _photo != null
                          ? DecorationImage(
                              image: FileImage(_photo!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _photo == null
                        ? Icon(Icons.person_outline_rounded,
                            size: 44,
                            color: isDark ? AppColors.grey500 : AppColors.grey400)
                        : null,
                  ),
                  Positioned(
                    bottom: 2, right: 2,
                    child: Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.add_a_photo_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text('Add Profile Photo',
                  style: TextStyle(color: AppColors.primary,
                      fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
            ),
            const SizedBox(height: 28),

            _label('Full Name'),
            TbTextField(controller: _nameCtrl, label: 'Full name',
                prefixIcon: Icons.person_outline_rounded, validator: Validators.fullName),
            const SizedBox(height: 16),

            _label('Email Address'),
            TbTextField(controller: _emailCtrl, label: 'Email',
                prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
                validator: Validators.email),
            const SizedBox(height: 16),

            _label('Phone Number'),
            TbTextField(controller: _phoneCtrl, label: 'Phone number',
                prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone,
                validator: Validators.phone),
            const SizedBox(height: 16),

            _label('Date of Birth'),
            GestureDetector(
              onTap: _pickDob,
              child: AbsorbPointer(
                child: TbTextField(
                  controller: TextEditingController(
                    text: _dob == null ? ''
                        : '${_dob!.day.toString().padLeft(2,'0')}/'
                          '${_dob!.month.toString().padLeft(2,'0')}/${_dob!.year}',
                  ),
                  label: _dob == null ? 'Select date of birth' : 'Date of birth',
                  prefixIcon: Icons.calendar_today_outlined,
                  suffix: const Icon(Icons.arrow_drop_down_rounded),
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _label('Gender (optional)'),
            DropdownButtonFormField<String>(
              value: _gender,
              onChanged: (v) => setState(() => _gender = v),
              decoration: InputDecoration(
                labelText: 'Select gender',
                prefixIcon: const Icon(Icons.wc_rounded),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.grey100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
              ),
              items: const [
                DropdownMenuItem(value: 'male',            child: Text('Male')),
                DropdownMenuItem(value: 'female',          child: Text('Female')),
                DropdownMenuItem(value: 'other',           child: Text('Other')),
                DropdownMenuItem(value: 'prefer_not_to_say',child: Text('Prefer not to say')),
              ],
            ),
            const SizedBox(height: 16),

            _label('Password'),
            TbTextField(
              controller: _pwCtrl, label: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: !_showPw, validator: Validators.password,
              helperText: 'Min 8 chars, 1 uppercase, 1 number',
              suffix: IconButton(
                icon: Icon(_showPw ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                onPressed: () => setState(() => _showPw = !_showPw),
              ),
            ),
            const SizedBox(height: 16),

            _label('Confirm Password'),
            TbTextField(
              controller: _confirmCtrl, label: 'Confirm password',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: !_showConfirm,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (v) => Validators.confirmPassword(v, _pwCtrl.text),
              suffix: IconButton(
                icon: Icon(_showConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                onPressed: () => setState(() => _showConfirm = !_showConfirm),
              ),
            ),
            const SizedBox(height: 32),

            Consumer<AuthController>(
              builder: (_, auth, __) => GradientButton(
                text: 'Create Account',
                isLoading: auth.isLoading,
                onPressed: _submit,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: AppColors.grey500, fontSize: 14, fontFamily: 'Inter'),
                    children: [
                      TextSpan(text: 'Sign in',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: AppColors.grey600, fontFamily: 'Inter')),
  );
}
