import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/bmi/bmi_bloc.dart';
import '../core/app_theme.dart';
import '../cubits/profile/profile_cubit.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _height = TextEditingController();
  final _weight = TextEditingController();
  String _gender = 'P';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    if (user != null) _gender = user.gender;
  }

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _calculate() {
    final auth = context.read<AuthBloc>().state;
    context.read<BmiBloc>().add(
          BmiCalculateRequested(
            heightText: _height.text,
            weightText: _weight.text,
            gender: _gender,
            userEmail: auth.user?.email,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;

    return BlocConsumer<BmiBloc, BmiState>(
      listener: (context, state) {
        if (state.status == BmiStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? 'Perhitungan gagal.')),
          );
        }

        if (state.status == BmiStatus.success && state.result != null) {
          if (auth.user != null) {
            context.read<ProfileCubit>().load(auth.user!.email);
          }
          context.push('/result', extra: state.result);
        }
      },
      builder: (context, bmiState) {
        return PageWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFECF4), Color(0xFFEAF2FF)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kenali kondisi tubuhmu lewat BMI',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkBlue,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      auth.isAuthenticated
                          ? 'Hasil akan otomatis tersimpan ke riwayat ${auth.user!.name}.'
                          : 'Kamu bisa menghitung sebagai tamu. Login jika ingin menyimpan riwayat.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const SectionTitle(
                'Kalkulator BMI',
                subtitle: 'Business logic perhitungan berada di BmiBloc, bukan di Widget.',
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'L',
                    icon: Icon(Icons.male),
                    label: Text('Laki-laki'),
                  ),
                  ButtonSegment(
                    value: 'P',
                    icon: Icon(Icons.female),
                    label: Text('Perempuan'),
                  ),
                ],
                selected: {_gender},
                onSelectionChanged: (value) {
                  setState(() => _gender = value.first);
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _height,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Tinggi badan (cm)',
                  prefixIcon: Icon(Icons.height),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _weight,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onSubmitted: (_) => _calculate(),
                decoration: const InputDecoration(
                  labelText: 'Berat badan (kg)',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed:
                    bmiState.status == BmiStatus.loading ? null : _calculate,
                icon: const Icon(Icons.calculate_outlined),
                label: Text(
                  bmiState.status == BmiStatus.loading
                      ? 'Menghitung...'
                      : 'Hitung BMI',
                ),
              ),
              if (!auth.isAuthenticated) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login),
                  label: const Text('Login untuk menyimpan riwayat'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
