import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rione_cassero/logic/cubit/app/app_cubit.dart';

import 'package:rione_cassero/models/upper_event.dart';
import 'package:rione_cassero/models/user.dart' as up;
import 'package:rione_cassero/screens/forget/ui/forget_screen.dart';
import 'package:rione_cassero/screens/home/ui/event_participants_screen.dart';
import 'package:rione_cassero/screens/home/ui/home_screen.dart';
import 'package:rione_cassero/screens/home/ui/new_event_screen.dart';
import 'package:rione_cassero/screens/home/ui/user_page.dart';
import 'package:rione_cassero/screens/login/ui/login_screen.dart';
import 'package:rione_cassero/screens/signup/ui/sign_up_screen.dart';
import 'package:rione_cassero/screens/signup/ui/verfication.dart';
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
            child: HomeScreen(
              tab_index: settings.arguments == null ? 1 : settings.arguments as int,
            ),
          ),
        );

      case Routes.signupScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: const SignUpScreen(),
          ),
        );

      case Routes.verifyScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: VerificaEmailPage(),
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

      case Routes.viewParticipantsScreen:
        var map = settings.arguments as Map<String, Object?>;

        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: EventParticipantScreen(
              upperEvent: map['upperEvent'] as UpperEvent,
              allUsers: map['allUsers'] as List<up.User>,
              //bookedUsers: map['bookedUsers'] as List<up.User>,
              //participantsUsers: map['participantsUsers'] as List<up.User>,
            ),
          ),
        );

      case Routes.viewUserPage:
        var map = settings.arguments as Map<String, Object?>;

        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: UserPage(user: map['user'] as up.User, event: map['event'] as UpperEvent?,
            ),
          ),
        );
    }
    return null;
  }
}
