import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rione_cassero/core/widgets/app_text_form_field.dart';
import 'package:rione_cassero/logic/cubit/app/app_cubit.dart';
import 'package:rione_cassero/models/participant_data.dart';
import 'package:rione_cassero/models/upper_event.dart';
import 'package:rione_cassero/models/user.dart' as up;
import 'package:rione_cassero/theming/colors.dart';

// ignore: must_be_immutable
class ManageEventScreen extends StatefulWidget {
  UpperEvent upperEvent;
  ParticipantDataCassero bookData;
  Image eventImage;
  up.User loggedUser;
  bool isNewBook;

  ManageEventScreen(
      {super.key,
      required this.upperEvent,
      required this.bookData,
      required this.eventImage,
      required this.loggedUser,
      required this.isNewBook});

  @override
  State<ManageEventScreen> createState() => _ManageEventScreenState();
}

class _ManageEventScreenState extends State<ManageEventScreen> {
  int _editBookNameMode = 0;
  String bookName = "";
  int bookNumber = 1;
  int childBookNumber = 0;
  int infantBookNumber = 0;

  bool actionInProgress = false;

  final TextEditingController _bookEventController = TextEditingController();
  final TextEditingController _allergyNoteController = TextEditingController();
  bool allergy = false;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    bookName = widget.bookData.name;
    bookNumber = widget.bookData.number;
    childBookNumber = widget.bookData.childrenNumber;
    infantBookNumber = widget.bookData.infantBookNumber;

    allergy = widget.bookData.allergy ?? false;
    _allergyNoteController.text = widget.bookData.allergyNote ?? "";

    _bookEventController.text = bookName;
  }

  Widget build(BuildContext context) {
    var currentEvent = widget.upperEvent;
    bool enableSave = true;

    if (widget.bookData.confirmed != null &&
        widget.upperEvent.confirmation != null) {
      if (widget.bookData.confirmed! && widget.upperEvent.confirmation!) {
        enableSave = false;
      }
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          title: Text(
            widget.isNewBook
                ? "${widget.upperEvent.title} - Prenotazione"
                : "${widget.upperEvent.title} - Gestisci",
            style: TextStyle(fontSize: 24, color: ColorsManager.gray17),
          ),
          foregroundColor: ColorsManager.gray17,
          backgroundColor: ColorsManager.background,
          titleTextStyle: TextStyle(color: ColorsManager.gray17),
        ),
        body: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Image(
                            image: widget.eventImage.image,
                            fit: BoxFit.scaleDown),
                      ),
                      Gap(15.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentEvent.title,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ColorsManager.gray17),
                          ),
                          Text(
                            "${currentEvent.date} - ${currentEvent.time}",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: ColorsManager.gray17),
                          ),
                          Text(
                            currentEvent.place,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: ColorsManager.gray17),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: Text(
                          widget.isNewBook
                              ? "Aggiungi una prenotazione"
                              : "Modifica la tua prenotazione",
                          style: TextStyle(
                              color: Color.fromRGBO(50, 50, 50, 1),
                              fontSize: 15),
                        )),
                        Gap(10.h),
                        widget.loggedUser.isAdmin! &&
                                !widget.isNewBook &&
                                widget.bookData.date != null
                            ? Center(
                                child: Text(
                                "Effettuata il ${widget.bookData.date!.day}/${widget.bookData.date!.month}/${widget.bookData.date!.year} ${widget.bookData.date!.hour}:${widget.bookData.date!.minute}",
                                style: TextStyle(
                                    color: Color.fromRGBO(50, 50, 50, 1),
                                    fontSize: 15),
                              ))
                            : SizedBox.shrink(),
                        Gap(10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _editBookNameMode == 0
                                ? Text(
                                    bookName,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20),
                                  )
                                : Center(
                                    child: Container(
                                      width: window.physicalSize.width /
                                              window.devicePixelRatio -
                                          100,
                                      child: AppTextFormField(
                                        textAlignment: TextAlign.center,
                                        hint: "",
                                        validator: (value) {
                                          String enteredValue =
                                              (value ?? '').trim();
                                          _bookEventController.text =
                                              enteredValue;
                                          if (enteredValue.isEmpty) {
                                            return "Il valore non può essere nullo";
                                          }
                                        },
                                        controller: _bookEventController,
                                      ),
                                    ),
                                  ),
                            Visibility(
                                visible: _editBookNameMode == 0,
                                child: Gap(10.w)),
                            Visibility(
                              visible: _editBookNameMode == 0,
                              child: GestureDetector(
                                child: Icon(Icons.edit, size: 20),
                                onTap: _editBookName,
                              ),
                            )
                          ],
                        ),
                        Gap(15.h),
                        Center(
                            child: Text(
                          "Adulti",
                          style: TextStyle(fontSize: 15),
                        )),
                        Gap(5.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              child: Container(
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.remove,
                                  size: 25,
                                ),
                              ),
                              onTap: () => setState(() {
                                bookNumber--;
                                if (bookNumber <= 1) bookNumber = 1;
                              }),
                            ),
                            Text(
                              bookNumber.toString(),
                              style: TextStyle(fontSize: 30),
                            ),
                            GestureDetector(
                              child: Container(
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.add,
                                  size: 25,
                                ),
                              ),
                              onTap: () => setState(() {
                                bookNumber++;
                              }),
                            ),
                          ],
                        ),
                        Gap(15.h),
                        Center(
                            child: Text(
                              "Bambini",
                              style: TextStyle(fontSize: 15),
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              child: Container(
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.remove,
                                  size: 25,
                                ),
                              ),
                              onTap: () => setState(() {
                                childBookNumber--;
                                if (childBookNumber <= 0) childBookNumber = 0;
                              }),
                            ),
                            Text(
                              childBookNumber.toString(),
                              style: TextStyle(fontSize: 30),
                            ),
                            GestureDetector(
                              child: Container(
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.add,
                                  size: 25,
                                ),
                              ),
                              onTap: () => setState(() {
                                childBookNumber++;
                              }),
                            ),
                          ],
                        ),
                        Gap(15.h),
                        Center(
                            child: Text(
                              "Neonati",
                              style: TextStyle(fontSize: 15),
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              child: Container(
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.remove,
                                  size: 25,
                                ),
                              ),
                              onTap: () => setState(() {
                                infantBookNumber--;
                                if (infantBookNumber <= 0) infantBookNumber = 0;
                              }),
                            ),
                            Text(
                              infantBookNumber.toString(),
                              style: TextStyle(fontSize: 30),
                            ),
                            GestureDetector(
                              child: Container(
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.add,
                                  size: 25,
                                ),
                              ),
                              onTap: () => setState(() {
                                infantBookNumber++;
                              }),
                            ),
                          ],
                        ),
                        Gap(15.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Intolleranze",
                                style: TextStyle(fontSize: 22)),
                            Gap(40.w),
                            GestureDetector(
                              onTap: () => setState(() {
                                allergy = true;
                              }),
                              child: Row(
                                children: [
                                  Icon(
                                    allergy
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
                                allergy = false;
                                _allergyNoteController.text = "";
                              }),
                              child: Row(
                                children: [
                                  Icon(
                                    !allergy
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
                        Gap(20.h),
                        Visibility(
                            visible: allergy,
                            child: Text(
                              "Inserisci qui le tue note sulle intolleranze",
                              style: TextStyle(fontSize: 15),
                            )),
                        Visibility(
                          visible: allergy,
                          child: AppTextFormField(
                            textAlignment: TextAlign.left,
                            hint: "",
                            validator: (value) {
                              String enteredValue = (value ?? '');
                              _allergyNoteController.text = enteredValue;
                              if (enteredValue.isEmpty) {
                                return "Il valore non può essere nullo";
                              }
                            },
                            controller: _allergyNoteController,
                          ),
                        ),
                        Gap(40.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _bookEventUndo,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.undo,
                                    size: 35,
                                    color: Colors.black,
                                  ),
                                  Gap(3.h),
                                  Text("Indietro"),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: !widget.isNewBook,
                              child: GestureDetector(
                                onTap:
                                    !actionInProgress ? _bookEventDelete : null,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 35,
                                      color: Colors.red,
                                    ),
                                    Gap(3.h),
                                    Text(
                                      "Cancella",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //Gap(100.w),
                            GestureDetector(
                              onTap: !actionInProgress ? _bookEventSave : null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save,
                                    size: 35,
                                    color:
                                        enableSave ? Colors.green : Colors.grey,
                                  ),
                                  Gap(3.h),
                                  Text(
                                    "Salva",
                                    style: TextStyle(
                                        color: enableSave
                                            ? Colors.green
                                            : Colors.grey),
                                  ),
                                ],
                              ),
                            ),

                            Visibility(
                              visible: !widget.isNewBook &&
                                  widget.loggedUser.isAdmin! &&
                                  widget.upperEvent.confirmation != null &&
                                  widget.upperEvent.confirmation! &&
                                  widget.bookData.confirmed != null &&
                                  !widget.bookData.confirmed!,
                              child: GestureDetector(
                                onTap: !actionInProgress
                                    ? _bookConfirmation
                                    : null,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.confirmation_num_outlined,
                                      size: 35,
                                      color: Colors.orange,
                                    ),
                                    Gap(3.h),
                                    Text(
                                      "Conferma",
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap(40.h),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editBookName() {
    if (_editBookNameMode == 1) {
      setState(() {
        _editBookNameMode = 0;
        bookName = _bookEventController.text;
      });
    } else {
      setState(() {
        _editBookNameMode = 1;
        _bookEventController.text = bookName;
      });
    }
  }

  Future<void> _bookEventSave() async {
    if (widget.bookData.confirmed != null &&
        widget.upperEvent.confirmation != null) {
      if (widget.bookData.confirmed! && widget.upperEvent.confirmation!) {
        await AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.topSlide,
          title: 'La prenotazione è confermata',
          desc:
              "Non è possibile modificare una prenotazione confermata, inseriscine una nuova!",
        ).show();
        return;
      }
    }

    setState(() {
      actionInProgress = true;
    });

    if (widget.upperEvent.bookable!) {
      if ((_editBookNameMode == 1 && _bookEventController.text.length == 0) ||
          (allergy && _allergyNoteController.text.length == 0)) {
        formKey.currentState!.validate();
      } else {
        if (widget.isNewBook) {
          await context.read<AppCubit>().bookEventCassero(
              widget.loggedUser.uid!,
              "${widget.loggedUser.name} ${widget.loggedUser.surname}",
              widget.upperEvent.id!,
              widget.isNewBook ? null : widget.bookData.eventUid,
              _bookEventController.text,
              bookNumber,
              childBookNumber,
              infantBookNumber,
              allergy,
              _allergyNoteController.text,
              null,
              null,
              widget.upperEvent.confirmation,
              null);
        } else {
          await context.read<AppCubit>().bookEventCassero(
              widget.bookData.uid!,
              widget.bookData.bookUserName,
              widget.upperEvent.id!,
              widget.isNewBook ? null : widget.bookData.eventUid,
              _bookEventController.text,
              bookNumber,
              childBookNumber,
              infantBookNumber,
              allergy,
              _allergyNoteController.text,
              null,
              null,
              widget.upperEvent.confirmation,
              widget.bookData.confirmed);
        }

        if (widget.isNewBook) {
          if (widget.upperEvent.confirmation == null ||
              widget.upperEvent.confirmation == false) {
            await AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.topSlide,
              title: 'Prenotazione confermata',
              desc: "Grazie ${_bookEventController.text}, ti aspettiamo!",
            ).show();
          } else {
            await AwesomeDialog(
              context: context,
              dialogType: DialogType.info,
              animType: AnimType.topSlide,
              title: 'Prenotazione inviata',
              desc:
                  "Grazie ${_bookEventController.text}, la tua prenotazione verrà confermata al più presto!",
            ).show();
          }
        } else {
          await AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.topSlide,
            title: 'Prenotazione modificata',
            desc: "Dati aggiornati con successo",
          ).show();
        }

        Navigator.pop(context);
      }
    } else {
      await AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: 'Prenotazioni chiuse',
        desc: "Chiedi informazioni agli organizzatori dell'evento",
      ).show();

      Navigator.pop(context);
    }
  }

  Future<void> _bookConfirmation() async {
    setState(() {
      actionInProgress = true;
    });

    if ((_editBookNameMode == 1 && _bookEventController.text.length == 0) ||
        (allergy && _allergyNoteController.text.length == 0)) {
      formKey.currentState!.validate();
    } else {
      if (!widget.isNewBook) {
        await context.read<AppCubit>().bookEventCassero(
            widget.bookData.uid!,
            widget.bookData.bookUserName,
            widget.upperEvent.id!,
            widget.isNewBook ? null : widget.bookData.eventUid,
            _bookEventController.text,
            bookNumber,
            childBookNumber,
            infantBookNumber,
            allergy,
            _allergyNoteController.text,
            null,
            null,
            widget.upperEvent.confirmation,
            true);

        String? address =
            context.read<AppCubit>().getEmailFromUserUID(widget.bookData.uid!);
        if (address != null) {
          bool email_result = await sendEmail(
              address,
              widget.upperEvent.title,
              widget.bookData.bookUserName,
              widget.bookData.name,
              widget.upperEvent.date.toString(),
              childBookNumber == 0
                  ? "${bookNumber}"
                  : "${bookNumber} + ${childBookNumber+infantBookNumber} bambini");
          if (!email_result) {
            await AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              animType: AnimType.topSlide,
              title: 'Errore invio email',
              desc: "Non è stato possibile inviare l'email di conferma",
            ).show();
          }
        } else {
          await AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.topSlide,
            title: 'Email non trovata',
            desc:
                "Non è stato possibile trovare l'indirizzo email del destinatario",
          ).show();
        }

        await AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          title: 'Prenotazione confermata',
          desc: "Hai confermato la prenotazione per ${widget.bookData.name}",
        ).show();
      }

      Navigator.pop(context);
    }
  }

  Future<bool> sendEmail(String address, String eventName, String personName,
      String bookName, String eventDate, String bookInfo) async {
    return context.read<AppCubit>().sendConfirmationEmail(
        address, eventName, personName, bookName, eventDate, bookInfo);
  }

  void _bookEventUndo() {
    Navigator.pop(context);
  }

  Future<void> _bookEventDelete() async {
    setState(() {
      actionInProgress = true;
    });

    await context.read<AppCubit>().deleteBookEventCassero(
        widget.upperEvent.id!, widget.bookData.eventUid);

    await AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.topSlide,
      title: 'Prenotazione cancellata',
      desc: "Ci dispiace per la tua disdetta",
    ).show();

    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
    _bookEventController.dispose();
    _allergyNoteController.dispose();

    actionInProgress = false;
  }
}
