import 'package:flutter/material.dart';
import '../data/mock_repository.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import 'tourist_home.dart';
import 'provider_dashboard.dart';
import 'admin_panel.dart';

/// Login and registration with role selection (tourist / local provider).
class AuthScreen extends StatefulWidget {
  final bool startInRegisterMode;
  const AuthScreen({super.key, this.startInRegisterMode = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _loginMode;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  Role _role = Role.tourist;

  @override
  void initState() {
    super.initState();
    _loginMode = !widget.startInRegisterMode;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _goHome(AppUser user) {
    Widget home;
    switch (user.role) {
      case Role.tourist:
        home = const TouristHome();
        break;
      case Role.provider:
        home = const ProviderDashboard();
        break;
      case Role.admin:
        home = const AdminPanel();
        break;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => home),
    );
  }

  void _submit() {
    final repo = NativeGoRepo();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      showSnack(context, 'Please enter your email and password.');
      return;
    }
    if (_loginMode) {
      final user = repo.login(email, pass);
      if (user == null) {
        showSnack(context, 'Invalid email or password.');
      } else {
        _goHome(user);
      }
    } else {
      if (_nameCtrl.text.trim().isEmpty) {
        showSnack(context, 'Please enter your full name.');
        return;
      }
      final user = repo.register(
        name: _nameCtrl.text.trim(),
        email: email,
        password: pass,
        phone: _phoneCtrl.text.trim(),
        role: _role,
      );
      showSnack(context, 'Welcome to NativeGo, ${user.name}!');
      _goHome(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Icon(Icons.explore, size: 72, color: Color(0xFF0E7C5B)),
              const SizedBox(height: 12),
              const Text(
                'NativeGo',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0E7C5B)),
              ),
              const SizedBox(height: 4),
              Text(
                'Trusted local people, wherever you roam.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
              const SizedBox(height: 32),
              if (!_loginMode) ...[
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('I am joining as a:',
                    style: TextWeightStyle.label),
                RadioGroup<Role>(
                  groupValue: _role,
                  onChanged: (v) => setState(() => _role = v!),
                  child: Row(
                    children: [
                      const Expanded(
                        child: RadioListTile<Role>(
                          title: Text('Tourist'),
                          value: Role.tourist,
                        ),
                      ),
                      const Expanded(
                        child: RadioListTile<Role>(
                          title: Text('Local provider'),
                          value: Role.provider,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E7C5B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_loginMode ? 'Log in' : 'Create account',
                    style: const TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () => setState(() => _loginMode = !_loginMode),
                child: Text(_loginMode
                    ? 'New here? Create an account'
                    : 'Already have an account? Log in'),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Demo accounts\n'
                  'Tourist: tourist@demo.co.ke / demo123\n'
                  'Provider: david@demo.co.ke / demo123\n'
                  'Admin: admin@nativego.co.ke / admin123',
                  style:
                      TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextWeightStyle {
  static const label =
      TextStyle(fontWeight: FontWeight.w600, fontSize: 14);
}
