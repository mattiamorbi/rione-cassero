import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rione_cassero/core/widgets/app_text_form_field.dart';
import 'package:rione_cassero/core/widgets/no_internet.dart';
import 'package:rione_cassero/helpers/extensions.dart';
import 'package:rione_cassero/models/upper_event.dart';
import 'package:rione_cassero/theming/colors.dart';

import '../../../logic/cubit/app/app_cubit.dart';
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
  bool _noImage = false;
  bool bookable = true;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _childrenPriceController =
      TextEditingController();
  final TextEditingController _bookingLimitController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.upperEvent != null) {
      _titleController.text = widget.upperEvent!.title;
      _descriptionController.text = widget.upperEvent!.description;
      _dateController.text = widget.upperEvent!.date;
      _timeController.text = widget.upperEvent!.time;
      _placeController.text = widget.upperEvent!.place;
      _bookingLimitController.text = widget.upperEvent!.bookingLimit == null
          ? ""
          : widget.upperEvent!.bookingLimit.toString();
      _priceController.text = widget.upperEvent!.price == null
          ? ""
          : widget.upperEvent!.price.toString();
      _childrenPriceController.text = widget.upperEvent!.childrenPrice == null
          ? ""
          : widget.upperEvent!.childrenPrice.toString();

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

  Widget dataField() {
    return AppTextFormField(
      hint: 'Data (gg/mm/aaaa)',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Inserisci una data';
        }

        // Controllo che sia nel formato gg/mm/aaaa usando regex
        final RegExp dateRegex = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$');
        if (!dateRegex.hasMatch(value)) {
          return 'Formato data non valido. Usa gg/mm/aaaa';
        }

        // Estrai giorno, mese e anno
        final Match? match = dateRegex.firstMatch(value);
        final int day = int.parse(match!.group(1)!);
        final int month = int.parse(match.group(2)!);
        final int year = int.parse(match.group(3)!);

        // Usa DateTime per validare
        try {
          final parsedDate = DateTime(year, month, day);
          if (parsedDate.day != day ||
              parsedDate.month != month ||
              parsedDate.year != year) {
            return 'Data non valida';
          }
        } catch (e) {
          return 'Data non valida';
        }

        return null; // Data valida
      },
      controller: _dateController,
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

  Widget numericField(TextEditingController controller, String placeholder,
      String errorMessage) {
    return AppTextFormField(
      hint: placeholder,
      validator: (value) {
        String enteredValue = (value ?? '').trim();
        controller.text = enteredValue;
        if (enteredValue.isEmpty || int.tryParse(enteredValue) == null) {
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
        _noImage = false;
      });
    } else {
      if (kDebugMode) {
        print("Immagine non selezionata");
      }
    }
  }

  Future<void> _uploadToFirebase() async {
    if (formKey.currentState!.validate()) {
      final storageRef = FirebaseStorage.instance.ref();
      var events = FirebaseFirestore.instance.collection('events');

      print("1--");

      if (widget.upperEvent == null) {
        final storageRef = FirebaseStorage.instance.ref();

        print("2--");

        if (_pickedImage == null) {
          setState(() {
            _noImage = true;
          });
          return;
        } else {
          final imageRef = storageRef.child("images/${_pickedImage!.name}");
          print("3--");
          try {
            print("5--");
            await imageRef.putData(_webImage);
            print("6--");
          } on FirebaseException catch (e) {
            if (kDebugMode) {
              print("Errore durante il caricamento dell'immagine! $e");
            }
          }

          var newUpperEvent = UpperEvent(
            title: _titleController.text,
            description: _descriptionController.text,
            date: _dateController.text,
            time: _timeController.text,
            place: _placeController.text,
            imagePath: "images/${_pickedImage!.name}",
            price: int.parse(_priceController.text),
            childrenPrice: int.parse(_childrenPriceController.text),
            bookingLimit: int.parse(_bookingLimitController.text),
          );

          print("4--");

          try {
            await events.doc().set(newUpperEvent.toJson());
          } on Exception catch (e) {
            if (kDebugMode) {
              print("Error while saving event! $e");
            }
          }
        }
      } else {
        final imageRef = _pickedImage == null
            ? storageRef.child(widget.upperEvent!.imagePath)
            : storageRef.child("images/${_pickedImage!.name}");

        try {
          if (_pickedImage != null) await imageRef.putData(_webImage);
        } on FirebaseException catch (e) {
          if (kDebugMode) {
            print("Errore durante il caricamento dell'immagine! $e");
          }
        }
        var id = widget.upperEvent!.id;
        var upperEvent = UpperEvent(
            title: _titleController.text,
            description: _descriptionController.text,
            date: _dateController.text,
            time: _timeController.text,
            place: _placeController.text,
            id: id,
            imagePath: _pickedImage == null
                ? widget.upperEvent!.imagePath
                : "images/${_pickedImage!.name}",
            price: int.parse(_priceController.text),
            childrenPrice: int.parse(_childrenPriceController.text),
            bookingLimit: int.parse(_bookingLimitController.text));

        try {
          await events.doc(id).set(upperEvent.toJson());
        } on Exception catch (e) {
          if (kDebugMode) {
            print("Error while saving event! $e");
          }
        }
        widget.upperEvent = upperEvent;
        print("fatto");
      }
      try {
        await context.read<AppCubit>().updateBookPermission(
            widget.upperEvent!.id!, bookable);
      }on Exception catch (e) {
        if (kDebugMode) {
          print("Error while updateBookRooles! $e");
        }
      }
      context.pop();
    }
  }

  Widget _newEventScreen(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
            backgroundColor: ColorsManager.background,
            foregroundColor: ColorsManager.gray17,
            title: Text(
              widget.upperEvent == null
                  ? "Rione Cassero - Nuovo evento"
                  : "Rione Cassero - Modifica evento",
              style: TextStyle(fontSize: 24, color: ColorsManager.gray17),
            )),
        body: Padding(
          padding: const EdgeInsets.only(
              top: 15.0, bottom: 15.0, left: 40.0, right: 40.0),
          child: SingleChildScrollView(
            child: Column(children: [
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Gap(20.w),
                    genericField(_titleController, "Titolo",
                        "Inserisci un titolo valido"),
                    Gap(20.w),
                    genericField(_descriptionController, "Descrizione",
                        "Inserisci una descrizione valida"),
                    Gap(20.w),
                    //genericField(
                    //    _dateController, "Data", "Inserisci una data valida"),
                    dataField(),
                    Gap(20.w),
                    genericField(_timeController, "Orario",
                        "Inserisci un orario valido"),
                    Gap(20.w),
                    genericField(
                        _placeController, "Luogo", "Inserisci un luogo valido"),
                    Gap(20.w),
                    numericField(_bookingLimitController, "Posti",
                        "Inserisci il limite delle prenotazioni"),
                    Gap(20.w),
                    numericField(_priceController, "Prezzo",
                        "Inserisci un prezzo valido"),
                    Gap(20.w),
                    numericField(_childrenPriceController, "Prezzo bambini",
                        "Inserisci un prezzo valido"),
                    Gap(20.w),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Prenotazioni aperte",
                            style: TextStyle(fontSize: 22)),
                        Gap(40.w),
                        GestureDetector(
                          onTap: () => setState(() {
                            bookable = true;
                          }),
                          child: Row(
                            children: [
                              Icon(
                                bookable
                                    ? Icons.check_circle_outline
                                    : Icons.circle_outlined,
                                size: 25,
                              ),
                              Text("SI", style: TextStyle(fontSize: 22)),
                            ],
                          ),
                        ),
                        Gap(30.w),
                        GestureDetector(
                          onTap: () => setState(() {
                            bookable = false;
                          }),
                          child: Row(
                            children: [
                              Icon(
                                !bookable
                                    ? Icons.check_circle_outline
                                    : Icons.circle_outlined,
                                size: 25,
                              ),
                              Text("NO", style: TextStyle(fontSize: 22)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
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
                            color: _noImage == true
                                ? Colors.red
                                : ColorsManager.gray17,
                          )),
                      onTap: _loadImage),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    child: Container(
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.save,
                          color: ColorsManager.gray17,
                        )),
                    onTap: _uploadToFirebase,
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
    _priceController.dispose();
    _childrenPriceController.dispose();
    _bookingLimitController.dispose();
  }
}
