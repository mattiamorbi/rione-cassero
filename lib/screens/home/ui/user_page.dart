import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:upper/core/widgets/app_text_form_field.dart';
import 'package:upper/core/widgets/no_internet.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/models/user.dart' as up;
import 'package:upper/screens/home/ui/home_screen.dart';
import 'package:upper/theming/colors.dart';

import '../../../logic/cubit/app/app_cubit.dart';

// ignore: must_be_immutable
class UserPage extends StatefulWidget {
  up.User user;

  UserPage({super.key, required this.user});

  @override
  State<UserPage> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserPage> {
  bool editCardNumber = false;

  final TextEditingController _cardNumber = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.user.cardNumber == 0) editCardNumber = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(17, 17, 17, 1),
      body: OfflineBuilder(
        connectivityBuilder: (context, value, child) {
          final bool connected =
              value.any((element) => element != ConnectivityResult.none);
          return connected ? _newUserPage(context) : const BuildNoInternet();
        },
        child: const Center(
          child: CircularProgressIndicator(
            color: ColorsManager.mainBlue,
          ),
        ),
      ),
    );
  }

  Widget genericField(TextEditingController controller, String placeholder,
      String errorMessage) {
    return AppTextFormField(
      hint: placeholder,
      validator: (value) {
        String enteredValue = (value ?? '').trim();
        controller.text = enteredValue;
        if (enteredValue.isEmpty) {
          return errorMessage;
        }
      },
      controller: controller,
    );
  }

//Future<void> _uploadToFirebase() async {
//  //this.build(context);
//  context.pushNamed(Routes.homeScreen);
//  final storageRef = FirebaseStorage.instance.ref();
//  final imageRef = storageRef.child("images/${_pickedImage!.name}");

//  try {
//    await imageRef.putData(_webImage);
//  } on FirebaseException catch (e) {
//    if (kDebugMode) {
//      print("Errore durante il caricamento dell'immagine! $e");
//    }
//  }
//  var events = FirebaseFirestore.instance.collection('events');
//  var upperEvent = UpperEvent(
//      title: _titleController.text,
//      description: _descriptionController.text,
//      date: _dateController.text,
//      time: _timeController.text,
//      place: _placeController.text,
//      imagePath: _pickedImage == null
//          ? widget.upperEvent!.imagePath
//          : "images/${_pickedImage!.name}");

//  try {
//    if (widget.upperEvent != null) {
//      var id = widget.upperEvent!.id;
//      widget.upperEvent = upperEvent;
//      await events.doc(id).set(widget.upperEvent!.toJson());
//    } else {
//      await events.doc().set(upperEvent.toJson());
//    }
//    //context.pushNamed(Routes.homeScreen);
//  } on Exception catch (e) {
//    if (kDebugMode) {
//      print("Error while saving event! $e");
//    }
//  }
//}

  Widget _newUserPage(BuildContext context) {
    int age = widget.user.getAge();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(17, 17, 17, 1),
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromRGBO(17, 17, 17, 1),
          title: Text(
            "UPPER - ${widget.user.name} ${widget.user.surname}",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(
              top: 15.0, bottom: 15.0, left: 40.0, right: 40.0),
          child: SingleChildScrollView(
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "NOME   ",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    "${widget.user.name} ${widget.user.surname}",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
              Gap(25.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "DATA DI NASCITA   ",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    "${widget.user.birthdate} (${age} anni)",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
              Gap(25.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "LUOGO DI NASCITA   ",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    "${widget.user.birthplace}",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
              Gap(25.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "RESIDENZA   ",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    "${widget.user.address}, ${widget.user.city}  (${widget.user.cap})",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              Gap(25.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "E-MAIL   ",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    "${widget.user.email}",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
              Gap(25.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "TELEFONO   ",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    "${widget.user.telephone}",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
              Gap(25.h),
              Visibility(
                visible: !editCardNumber,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "TESSERA   ",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      "${widget.user.cardNumber}",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: editCardNumber,
                child: genericField(_cardNumber, "Numero di tessera",
                    "Inserire un numero di tessera valido"),
              ),
              Gap(40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Container(
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        )),
                    onTap: () {
                      setState(() {
                        editCardNumber = !editCardNumber;
                      });
                    },
                  ),
                  Visibility(
                    visible: editCardNumber,
                    child: GestureDetector(
                      child: Container(
                          width: 50,
                          height: 50,
                          child: Icon(
                            Icons.save,
                            color: Colors.white,
                          )),
                      onTap: () => _updateUser(widget.user),
                    ),
                  ),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }

  void _updateUser(up.User _user) async {
    _user.cardNumber = int.tryParse(_cardNumber.text)!;
    await context.read<AppCubit>().updateUserInfo(_user);
    setState(() {
      editCardNumber = false;
      context.pop();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _cardNumber.dispose();
  }
}
