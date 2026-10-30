import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/register/register_cubit.dart';
import '../widgets/common_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _age = TextEditingController();

  String? _gender;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _age.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<RegisterCubit>().register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      confirmPassword: _confirm.text,
      ageText: _age.text,
      gender: _gender,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state.status == RegisterStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ?? 'Registrasi gagal.',
              ),
            ),
          );
        }

        if (state.status == RegisterStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ?? 'Registrasi berhasil.',
              ),
            ),
          );

          context.read<RegisterCubit>().reset();

          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/login');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const AppLogo(height: 40),
        ),
        body: PageWidth(
          maxWidth: 620,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Buat Akun',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),

              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _age,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Umur',
                ),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Jenis Kelamin',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'L',
                    child: Text('Laki-laki'),
                  ),
                  DropdownMenuItem(
                    value: 'P',
                    child: Text('Perempuan'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _confirm,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password',
                ),
              ),

              const SizedBox(height: 20),

              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (context, state) {
                  final isLoading =
                      state.status == RegisterStatus.loading;

                  return FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: Text(
                      isLoading
                          ? 'Menyimpan...'
                          : 'Register',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}