import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rione_cassero/core/widgets/no_internet.dart';
import 'package:rione_cassero/helpers/extensions.dart';
import 'package:rione_cassero/routing/routes.dart';

import '../../../theming/colors.dart';

class VerificaEmailPage extends StatefulWidget {
  @override
  _VerificaEmailPageState createState() => _VerificaEmailPageState();
}

class _VerificaEmailPageState extends State<VerificaEmailPage> {
  String verify = 'waiting';

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    // Estrai i parametri dall'URL
    final Uri uri = Uri.base; // L'URL corrente
    final String? oobCode = uri.queryParameters['oobCode'];

    if (oobCode != null) {
      try {
        // Applica il codice di verifica per confermare l'email
        await FirebaseAuth.instance.applyActionCode(oobCode);
        if (kDebugMode) {
          print("Email verificata con successo!");
        }

        //verify = true;
        //print(user.name);
        //context.pushNamedAndRemoveUntil(
        //  Routes.loginScreen,
        //  predicate: (route) => false,
        //);

        // Ricarica lo stato utente per riflettere la verifica
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.emailVerified) {
          // L'email è stata verificata, reindirizza o aggiorna lo stato
          if (kDebugMode) {
            print("L'utente ha verificato l'email.");
          }

          verify = 'true';

          await Future.delayed(const Duration(seconds: 3));

          context.pushNamedAndRemoveUntil(
            Routes.loginScreen,
            predicate: (route) => false,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print("Errore durante la verifica dell'email: $e");
        }
        verify = 'false';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      body: OfflineBuilder(
        connectivityBuilder: (context, value, child) {
          final bool connected =
              value.any((element) => element != ConnectivityResult.none);
          return connected
              ? _newVerificationPage(context)
              : const BuildNoInternet();
        },
        child: const Center(
          child: CircularProgressIndicator(
            color: ColorsManager.mainBlue,
          ),
        ),
      ),
    );
  }

  Widget _newVerificationPage(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        //appBar: AppBar(
        //  foregroundColor: ColorsManager.gray17,
        //  backgroundColor: ColorsManager.background,
        //  title: Text(
        //    "UPPER - Verifica email",
        //    style: TextStyle(color: ColorsManager.gray17),
        //  ),
        //),
        body: Padding(
          padding: const EdgeInsets.only(
              top: 15.0, bottom: 15.0, left: 40.0, right: 40.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                  child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Image(
                        image: AssetImage("assets/images/upper_2.png"),
                        fit: BoxFit.fitWidth,
                      ))),
              Gap(20.h),
              Visibility(
                visible: verify == 'waiting',
                child: Center(
                  child: CircularProgressIndicator(
                    color: ColorsManager.mainBlue,
                  ),
                ),
              ),
              Visibility(
                  visible: verify == 'waiting',
                  child: Text(
                    "Verifica e-mail in corso...",
                    style: TextStyle(
                        color: ColorsManager.gray17,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )),
              Visibility(
                  visible: verify == 'false',
                  child: Text(
                    "Codice di verifica non valido",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )),
              Visibility(
                  visible: verify == 'false',
                  child: Text(
                    "Codice errato o già utilizzato",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  )),
              Visibility(
                  visible: verify == 'true',
                  child: Text(
                    "E-mail verificata",
                    style: TextStyle(
                        color: ColorsManager.gray17,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )),
              Visibility(
                  visible: verify == 'true',
                  child: Text(
                    "Ora puoi accedere al tuo profilo UPPER",
                    style: TextStyle(
                        color: ColorsManager.gray17,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  )),
              Visibility(visible: verify == 'false', child: Gap(30.h)),
              Visibility(
                  visible: verify == 'false', child: loginButton(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginButton(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 200,
        height: 40,
        decoration: BoxDecoration(
          color: ColorsManager.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorsManager.gray17, width: 2),
        ),
        child: Center(
            child: Text("Torna al login",
                style: TextStyle(color: ColorsManager.gray17, fontSize: 20))),
      ),
      onTap: () {
        context.pushNamedAndRemoveUntil(
          Routes.loginScreen,
          predicate: (route) => false,
        );
      },
    );
  }
}
