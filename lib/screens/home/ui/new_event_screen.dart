import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:upper/core/widgets/no_internet.dart';
import 'package:upper/models/upper_event.dart';
import 'package:upper/theming/colors.dart';

import '../../../core/widgets/app_text_form_field.dart';



class NewEventScreen extends StatefulWidget {
  const NewEventScreen({super.key});

  @override
  State<NewEventScreen> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen> {
  late String qrData = "";
  late bool isAdmin = false;
  List<UpperEvent> events = [];

  TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OfflineBuilder(
        connectivityBuilder: (context, value, child) {
          final bool connected =
              value.any((element) => element != ConnectivityResult.none);
          return connected ? _newEventScreen(context) : const BuildNoInternet();
        },
        child: const Center(
          child: CircularProgressIndicator(
            color: ColorsManager.mainBlue,
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: isAdmin,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              //index = (index + 1) % customizations.length;
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  SafeArea _newEventScreen(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        initialIndex: 1,
        length: isAdmin ? 3 : 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("UPPER Event"),
            //bottom: TabBar(tabs: _getTabBars()),
          ),
          body: Column(
            children: [
              Text("Aggiungi un nuovo evento"),
              AppTextFormField(
                hint: "Titolo",
                validator: (value) {
                  String enteredValue = (value ?? '').trim();
                  titleController.text = enteredValue;
                  if (enteredValue.isEmpty) {
                    return 'Inserisci un titolo valido';
                  }
                },
                controller: titleController,
              ),
            ]


          )
        ),
      ),
    );
    // child: Padding(
    //   padding: EdgeInsets.all(15.w),
    //   child: SingleChildScrollView(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         SizedBox(
    //           height: 200.h,
    //           width: 200.w,
    //           child: FirebaseAuth.instance.currentUser!.photoURL != null
    //               ? CachedNetworkImage(
    //                   imageUrl: FirebaseAuth.instance.currentUser!.photoURL!,
    //                   placeholder: (context, url) => Image.asset('assets/images/loading.gif'),
    //                   fit: BoxFit.cover,
    //                 )
    //               : Image.asset('assets/images/placeholder.png'),
    //         ),
    //         Text(
    //           FirebaseAuth.instance.currentUser!.displayName!,
    //           style: TextStyles.font15DarkBlue500Weight.copyWith(fontSize: 30.sp),
    //         ),
    //         BlocConsumer<AuthCubit, AuthState>(
    //           buildWhen: (previous, current) => previous != current,
    //           listenWhen: (previous, current) => previous != current,
    //           listener: (context, state) async {
    //             if (state is AuthLoading) {
    //               pi.ProgressIndicator.showProgressIndicator(context);
    //             } else if (state is UserSignedOut) {
    //               context.pop();
    //               context.pushNamedAndRemoveUntil(
    //                 Routes.loginScreen,
    //                 predicate: (route) => false,
    //               );
    //             } else if (state is AuthError) {
    //               await AwesomeDialog(
    //                 context: context,
    //                 dialogType: DialogType.info,
    //                 animType: AnimType.rightSlide,
    //                 title: 'Errore di logout',
    //                 desc: state.message,
    //               ).show();
    //             }
    //           },
    //           builder: (context, state) {
    //             return AppTextButton(
    //               buttonText: 'Logout',
    //               textStyle: TextStyles.font15DarkBlue500Weight,
    //               buttonWidth: 300,
    //               buttonHeight: 70,
    //               onPressed: () {
    //                 context.read<AuthCubit>().signOut();
    //               },
    //             );
    //           },
    //         ),
    //       ],
    //     ),
    //   ),
    // ),
  }
}
