import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upper/logic/cubit/app/app_cubit.dart';

import 'package:upper/models/upper_event.dart';
import 'package:upper/screens/forget/ui/forget_screen.dart';
import 'package:upper/screens/home/ui/home_screen.dart';
import 'package:upper/screens/home/ui/new_event_screen.dart';
import 'package:upper/screens/login/ui/login_screen.dart';
import 'package:upper/screens/signup/ui/sign_up_screen.dart';
import 'routes.dart';

class AppRouter {
  late AppCubit authCubit;

  AppRouter() {
    authCubit = AppCubit();
  }

  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.forgetScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const ForgetScreen(),
          ),
        );

      case Routes.homeScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const HomeScreen(),
          ),
        );

      case Routes.signupScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const SignUpScreen(),
          ),
        );

      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const LoginScreen(),
          ),
        );

      case Routes.newEventScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: NewEventScreen(
              upperEvent: null,
            ),
          ),
        );

      case Routes.editEventScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: NewEventScreen(
              upperEvent: settings.arguments as UpperEvent,
            ),
          ),
        );
    }
    return null;
  }
}
