import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:upper/core/widgets/already_have_account_text.dart';
import 'package:upper/core/widgets/login_and_signup_animated_form.dart';
import 'package:upper/core/widgets/progress_indicator.dart' as pi;
import 'package:upper/core/widgets/terms_and_conditions_text.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/logic/cubit/app/app_cubit.dart';
import 'package:upper/routing/routes.dart';
import 'package:upper/theming/styles.dart';

import '../../../helpers/server_date.dart';

class VerificaEmailPage extends StatefulWidget {
  @override
  _VerificaEmailPageState createState() => _VerificaEmailPageState();
}

class _VerificaEmailPageState extends State<VerificaEmailPage> {
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
        print("Email verificata con successo!");

        context.pushNamedAndRemoveUntil(
          Routes.loginScreen,
          predicate: (route) => false,
        );

        // Ricarica lo stato utente per riflettere la verifica
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.emailVerified) {
          // L'email è stata verificata, reindirizza o aggiorna lo stato
          print("L'utente ha verificato l'email.");
          context.pushNamedAndRemoveUntil(
            Routes.loginScreen,
            predicate: (route) => false,
          );
        }
      } catch (e) {
        print("Errore durante la verifica dell'email: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verifica Email")),
      body: Center(child: Text("Stiamo verificando la tua email...")),
    );
  }
}
