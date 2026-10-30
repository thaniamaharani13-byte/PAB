import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/bmi/bmi_bloc.dart';
import 'core/app_theme.dart';
import 'cubits/admin/admin_cubit.dart';
import 'cubits/article/article_cubit.dart';
import 'cubits/feedback/feedback_cubit.dart';
import 'cubits/profile/profile_cubit.dart';
import 'cubits/register/register_cubit.dart';
import 'router/app_router.dart';
import 'services/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = LocalStore();
  await store.seed();

  final authBloc = AuthBloc(store)..add(const AuthAppStarted());
  final appRouter = AppRouter(authBloc);

  runApp(
    CekBmikuApp(
      store: store,
      authBloc: authBloc,
      appRouter: appRouter,
    ),
  );
}

class CekBmikuApp extends StatelessWidget {
  const CekBmikuApp({
    super.key,
    required this.store,
    required this.authBloc,
    required this.appRouter,
  });

  final LocalStore store;
  final AuthBloc authBloc;
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider(create: (_) => RegisterCubit(store)),
        BlocProvider(create: (_) => BmiBloc(store)),
        BlocProvider(create: (_) => ProfileCubit(store)),
        BlocProvider(create: (_) => ArticleCubit(store)..load()),
        BlocProvider(create: (_) => FeedbackCubit(store)),
        BlocProvider(create: (_) => AdminCubit(store)),
      ],
      child: MaterialApp.router(
        title: 'CekBMI Thania',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter.router,
      ),
    );
  }
}
