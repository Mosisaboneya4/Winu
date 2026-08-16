import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/secure_storage_service.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final SecureStorageService _storageService = SecureStorageService();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  int _currentStep = 0;
  bool _isLoading = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await _storageService.isBiometricAvailable();
    setState(() {
      _biometricAvailable = available;
    });
  }

  Future<void> _enableBiometrics() async {
    setState(() => _isLoading = true);
    final success = await _storageService.enableBiometrics();
    setState(() {
      _isLoading = false;
      _biometricEnabled = success;
    });
  }

  Future<void> _setupPin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin.length < 4) {
      setState(() => _errorMessage = 'PIN must be at least 4 digits');
      return;
    }

    if (pin != confirmPin) {
      setState(() => _errorMessage = 'PINs do not match');
      return;
    }

    setState(() => _isLoading = true);
    final success = await _storageService.setPin(pin);
    
    if (success) {
      setState(() {
        _currentStep = 1;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = 'Failed to set PIN';
        _isLoading = false;
      });
    }
  }

  Future<void> _completeSetup() async {
    setState(() => _isLoading = true);
    // Navigate to dashboard will be handled by AppInitializer
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo/Title
              const Icon(
                Icons.favorite,
                size: 80,
                color: Color(0xFF9B59B6),
              ),
              const SizedBox(height: 16),
              const Text(
                'Winu',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9B59B6),
                ),
              ),
              const Text(
                'Women\'s Health',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF8E44AD),
                ),
              ),
              const SizedBox(height: 40),
              
              // Progress indicator
              _buildProgressIndicator(),
              const SizedBox(height: 32),
              
              // Step content
              Expanded(
                child: _currentStep == 0 ? _buildPinSetup() : _buildBiometricSetup(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 2,
            backgroundColor: const Color(0xFFE8DAEF),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9B59B6)),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${_currentStep + 1}/2',
          style: const TextStyle(
            color: Color(0xFF9B59B6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPinSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create a PIN',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9B59B6),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create a secure PIN to protect your health data',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF7F8C8D),
          ),
        ),
        const SizedBox(height: 32),
        
        TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Create PIN',
            hintText: 'Enter 4-6 digit PIN',
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF9B59B6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9B59B6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9B59B6), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        TextField(
          controller: _confirmPinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Confirm PIN',
            hintText: 'Re-enter your PIN',
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9B59B6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9B59B6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9B59B6), width: 2),
            ),
          ),
        ),
        
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
          ),
        ],
        
        const Spacer(),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _setupPin,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enable Biometrics',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9B59B6),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Use fingerprint or face recognition for quick access',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF7F8C8D),
          ),
        ),
        const SizedBox(height: 32),
        
        if (_biometricAvailable) ...[
          Card(
            color: const Color(0xFFF3E5F5),
            child: ListTile(
              leading: const Icon(
                Icons.fingerprint,
                color: Color(0xFF9B59B6),
                size: 32,
              ),
              title: const Text('Enable Biometric Login'),
              subtitle: const Text('Quick access with fingerprint or face'),
              trailing: Switch(
                value: _biometricEnabled,
                onChanged: _isLoading ? null : (value) async {
                  if (value) {
                    await _enableBiometrics();
                  } else {
                    await _storageService.disableBiometrics();
                    setState(() => _biometricEnabled = false);
                  }
                },
                activeTrackColor: const Color(0xFF9B59B6).withOpacity(0.5),
                activeColor: const Color(0xFF9B59B6),
              ),
            ),
          ),
        ] else ...[
          const Card(
            color: Color(0xFFF3E5F5),
            child: ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Color(0xFF9B59B6),
              ),
              title: Text('Biometrics Not Available'),
              subtitle: Text('Your device doesn\'t support biometric authentication'),
            ),
          ),
        ],
        
        const Spacer(),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _completeSetup,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Complete Setup'),
          ),
        ),
        const SizedBox(height: 12),
        
        TextButton(
          onPressed: _isLoading ? null : () {
            setState(() {
              _currentStep = 0;
              _biometricEnabled = false;
            });
          },
          child: const Text('Back'),
        ),
      ],
    );
  }
}
