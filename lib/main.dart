import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:upper/firebase_options.dart';
import 'package:upper/routing/app_router.dart';
import 'package:upper/routing/routes.dart';
import 'package:upper/theming/colors.dart';

late String initialRoute;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  await ScreenUtil.ensureScreenSize();

  final Uri uri = Uri.base; // L'URL corrente
  final String? oobCode = uri.queryParameters['oobCode'];
  final String? mode = uri.queryParameters['mode'];

  FirebaseAuth.instance.authStateChanges().listen(
    (user) {
      if (oobCode != null && mode != null && mode.contains("verifyEmail")) initialRoute = Routes.verifyScreen;
      //else if (oobCode != null && mode != null && mode.contains("resetPassword")) initialRoute = Routes.forgetScreen;

        //if (user != null) print("L'utente non e' nullo");

      else {
        if (user == null || !user.emailVerified) {
          initialRoute = Routes.loginScreen;
        } else {
          initialRoute = Routes.homeScreen;
        }
      }
    },
  );

  runApp(MyApp(router: AppRouter()));
}

class MyApp extends StatelessWidget {
  final AppRouter router;

  const MyApp({super.key, required this.router});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(720, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'UPPER',
          theme: ThemeData(
            useMaterial3: true,
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: ColorsManager.mainBlue,
              selectionColor: ColorsManager.mainBlue,
              selectionHandleColor: ColorsManager.mainBlue,
            ),
            colorSchemeSeed: ColorsManager.mainBlue,
          ),
          onGenerateRoute: router.generateRoute,
          debugShowCheckedModeBanner: false,
          initialRoute: initialRoute,

        );
      },
    );
  }
}
