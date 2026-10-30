import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/models.dart';
import '../../services/local_store.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._store) : super(const RegisterState());

  final LocalStore _store;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String ageText,
    required String? gender,
  }) async {
    final age = int.tryParse(ageText.trim());

    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        age == null ||
        gender == null) {
      emit(const RegisterState(
        status: RegisterStatus.failure,
        message: 'Semua kolom wajib diisi dengan benar.',
      ));
      return;
    }

    if (!email.contains('@')) {
      emit(const RegisterState(
        status: RegisterStatus.failure,
        message: 'Format email belum benar.',
      ));
      return;
    }

    if (password != confirmPassword) {
      emit(const RegisterState(
        status: RegisterStatus.failure,
        message: 'Konfirmasi password tidak cocok.',
      ));
      return;
    }

    if (password.length < 6) {
      emit(const RegisterState(
        status: RegisterStatus.failure,
        message: 'Password minimal 6 karakter.',
      ));
      return;
    }

    emit(const RegisterState(status: RegisterStatus.loading));

    final error = await _store.register(
      AppUser(
        name: name.trim(),
        email: email.trim(),
        password: password,
        age: age,
        gender: gender,
      ),
    );

    if (error != null) {
      emit(RegisterState(status: RegisterStatus.failure, message: error));
    } else {
      emit(const RegisterState(
        status: RegisterStatus.success,
        message: 'Registrasi berhasil. Silakan login.',
      ));
    }
  }

  void reset() => emit(const RegisterState());
}
