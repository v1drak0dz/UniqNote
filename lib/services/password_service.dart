import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class PasswordService {
  final _storage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();

  /// Adiciona ou atualiza senha para uma pasta ou nota
  Future<void> setPassword(String id, String password) async {
    await _storage.write(key: id, value: password);
  }

  /// Checa se a senha informada está correta
  Future<bool> checkPassword(String id, String input) async {
    String? saved = await _storage.read(key: id);
    return saved != null && saved == input;
  }

  /// Pede desbloqueio biométrico (Face ID / impressão digital)
  Future<bool> requestBiometricUnlock() async {
    bool canCheck = await _auth.canCheckBiometrics;
    if (!canCheck) return false;

    return await _auth.authenticate(
      localizedReason: 'Confirme sua identidade para desbloquear',
      biometricOnly: true,
    );
  }

  /// Remove senha de uma pasta ou nota
  Future<void> removePassword(String id) async {
    await _storage.delete(key: id);
  }
}
