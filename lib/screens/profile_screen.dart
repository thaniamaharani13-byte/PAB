import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth/auth_bloc.dart';
import '../core/app_theme.dart';
import '../cubits/profile/profile_cubit.dart';
import '../widgets/bmi_chart.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      context.read<ProfileCubit>().load(user.email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.status == ProfileStatus.loading ||
            state.status == ProfileStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = state.user;
        if (user == null) {
          return const Center(child: Text('Profil tidak tersedia.'));
        }

        return PageWidth(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundImage: AssetImage('assets/images/profile.png'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        Text(user.email),
                        Text(
                          '${user.gender == 'L' ? 'Laki-laki' : 'Perempuan'} • ${user.age} tahun',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.push('/profile/edit'),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Profil'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/profile/feedback'),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Masukan'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(const AuthLogoutRequested());
                      context.go('/home');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const SectionTitle('Tren BMI Terakhir'),
              BmiChart(items: state.history),
              const SizedBox(height: 24),
              const SectionTitle('Riwayat BMI'),
              if (state.history.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Belum ada riwayat BMI.'),
                  ),
                )
              else
                ...state.history.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFFFE9F2),
                        child: Text(item.bmi.toStringAsFixed(1)),
                      ),
                      title: Text(
                        item.category,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${item.weightKg.toStringAsFixed(1)} kg • ${item.heightCm.toStringAsFixed(0)} cm\n${formatDate(item.createdAt)}',
                      ),
                      isThreeLine: true,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Halaman Profil dilindungi auth guard pada go_router. Jika user belum login, route otomatis dialihkan ke /login.',
                  style: TextStyle(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
