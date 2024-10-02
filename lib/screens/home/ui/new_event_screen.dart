import 'dart:io';
import 'dart:typed_data';



import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _pickedImage;
  Uint8List webImage = Uint8List(8);

  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController placeController = TextEditingController();

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

  Widget genericFieldEvent(TextEditingController controller, String placeholder,
      String errorMessage) {
    return AppTextFormField(
      hint: placeholder,
      validator: (value) {
        String enteredValue = (value ?? '').trim();
        titleController.text = enteredValue;
        if (enteredValue.isEmpty) {
          return errorMessage;
        }
      },
      controller: controller,
    );
  }

  Future<void> _loadImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      var selected = File(image.path);
      var f = await image.readAsBytes();

      setState(() {
        webImage = f;
        _pickedImage = File('a');
      });

    } else {
      print("Problemi con l'immagine");
    }
  }

  void _uploadToFirebase() {

  }

  SafeArea _newEventScreen(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        initialIndex: 1,
        length: isAdmin ? 3 : 2,
        child: Scaffold(
            appBar: AppBar(
              title: const Text("UPPER - Nuovo evento"),
              //bottom: TabBar(tabs: _getTabBars()),
            ),
            body: Padding(
              padding: const EdgeInsets.only(
                  top: 15.0, bottom: 15.0, left: 40.0, right: 40.0),
              child: SingleChildScrollView(
                child: Column(children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Aggiungi un nuovo evento")),
                  SizedBox(height: 20),
                  genericFieldEvent(
                      titleController, "Titolo", "Inserisci un titolo valido"),
                  SizedBox(height: 20),
                  genericFieldEvent(
                      dateController, "Data", "Inserisci una data valida"),
                  SizedBox(height: 20),
                  genericFieldEvent(
                      timeController, "Orario", "Inserisci un orario valido"),
                  SizedBox(height: 20),
                  genericFieldEvent(
                      placeController, "Luogo", "Inserisci un luogo valido"),
                  SizedBox(height: 20),
                  Visibility(visible: _pickedImage != null, child: Image.memory(webImage,width: 200,height: 200,fit: BoxFit.fill ,)),
                  Row(
                    children: [
                      SizedBox(width: MediaQuery.sizeOf(context).width / 2),
                      FloatingActionButton(onPressed: _loadImage, child: Icon(Icons.image, color: Colors.black54,)),
                      SizedBox(width: 20,),
                      FloatingActionButton(onPressed: _uploadToFirebase, child: Icon(Icons.add, color: Colors.black54,)),
                    ],
                  )
                ]),
              ),
            )),
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
