import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upper/core/widgets/app_text_form_field.dart';
import 'package:upper/core/widgets/no_internet.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/models/upper_event.dart';
import 'package:upper/theming/colors.dart';

import '../../../routing/routes.dart';

// ignore: must_be_immutable
class NewEventScreen extends StatefulWidget {
  UpperEvent? upperEvent;

  NewEventScreen({super.key, this.upperEvent});

  @override
  State<NewEventScreen> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen> {
  XFile? _pickedImage;
  Uint8List _webImage = Uint8List(0);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.upperEvent != null) {
      _titleController.text = widget.upperEvent!.title;
      _descriptionController.text = widget.upperEvent!.description;
      _dateController.text = widget.upperEvent!.date;
      _timeController.text = widget.upperEvent!.time;
      _placeController.text = widget.upperEvent!.place;
      _loadEventImage();
    }
    //print(widget.upperEvent!.id);
  }

  void _loadEventImage() async {
    var data = await widget.upperEvent!.getEventImage();
    setState(() {
      _webImage = data!;
    });
  }

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

  Future<void> _loadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _pickedImage = image;
      var f = await image.readAsBytes();
      setState(() {
        _webImage = f;
      });
    } else {
      if (kDebugMode) {
        print("Immagine non selezionata");
      }
    }
  }

  Future<void> _uploadToFirebase() async {
    //
    //
    //build(context);
    //
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = _pickedImage == null ? storageRef.child(widget.upperEvent!.imagePath) : storageRef.child("images/${_pickedImage!.name}");

    try {
      await imageRef.putData(_webImage);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print("Errore durante il caricamento dell'immagine! $e");
      }
    }
    var events = FirebaseFirestore.instance.collection('events');
    var upperEvent = UpperEvent(
        title: _titleController.text,
        description: _descriptionController.text,
        date: _dateController.text,
        time: _timeController.text,
        place: _placeController.text,
        imagePath: _pickedImage == null
            ? widget.upperEvent!.imagePath
            : "images/${_pickedImage!.name}");

    try {
      if (widget.upperEvent != null) {
        var id = widget.upperEvent!.id;
        print("Event id! ${widget.upperEvent!.id}");
        await events.doc(id).set(upperEvent.toJson());
        widget.upperEvent = upperEvent;
        print("fatto");
      } else {
        await events.doc().set(upperEvent.toJson());
      }
      context.pushNamed(Routes.homeScreen, arguments: 0);
    } on Exception catch (e) {
      if (kDebugMode) {
        print("Error while saving event! $e");
      }
    }

   // context.pushNamedAndRemoveUntil(
   //   Routes.homeScreen,
   //   predicate: (route) => false,
   // );

    //context.pushNamed(Routes.homeScreen);
  }

  Widget _newEventScreen(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(17, 17, 17, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(17, 17, 17, 1),
          title: const Text("UPPER - Nuovo evento"),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.only(
              top: 15.0, bottom: 15.0, left: 40.0, right: 40.0),
          child: SingleChildScrollView(
            child: Column(children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(widget.upperEvent == null ? "Aggiungi un nuovo evento" : "Modifica evento", style: TextStyle(fontSize: 15, color: Colors.white),)),
              Gap(20.w),
              genericField(
                  _titleController, "Titolo", "Inserisci un titolo valido"),
              Gap(20.w),
              genericField(_descriptionController, "Descrizione",
                  "Inserisci una descrizione valida"),
              Gap(20.w),
              genericField(_dateController, "Data", "Inserisci una data valida"),
              Gap(20.w),
              genericField(
                  _timeController, "Orario", "Inserisci un orario valido"),
              Gap(20.w),
              genericField(
                  _placeController, "Luogo", "Inserisci un luogo valido"),
              Gap(20.w),
              Visibility(
                visible: _webImage.length > 1,
                child: Container(
                  width: 300,
                  height: 300,
                  child: Image.memory(
                    _webImage,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Gap(25.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Container(
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.image,
                          color: Colors.white,
                        )),
                    onTap: _loadImage
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                      child: Container(
                          width: 50,
                          height: 50,
                          child: Icon(
                            Icons.save,
                            color: Colors.white,
                          )),
                      onTap: _uploadToFirebase
                  ),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _placeController.dispose();
  }
}
