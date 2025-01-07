import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rione_cassero/core/widgets/app_text_form_field.dart';
import 'package:rione_cassero/helpers/extensions.dart';
import 'package:rione_cassero/models/participant_data.dart';
import 'package:rione_cassero/models/upper_event.dart';
import 'package:rione_cassero/models/user.dart' as up;
import 'package:rione_cassero/theming/colors.dart';
import 'dart:ui';

import 'package:rione_cassero/logic/cubit/app/app_cubit.dart';

import '../../../routing/routes.dart';

// ignore: must_be_immutable
class ManageEventScreen extends StatefulWidget {
  UpperEvent upperEvent;
  ParticipantDataCassero bookData;
  Image eventImage;
  up.User loggedUser;

  ManageEventScreen({super.key,
    required this.upperEvent,
    required this.bookData,
    required this.eventImage,
  required this.loggedUser});

  @override
  State<ManageEventScreen> createState() => _ManageEventScreenState();
}

class _ManageEventScreenState extends State<ManageEventScreen> {

  int _editBookNameMode = 0;
  String bookName = "";
  int bookNumber = 1;
  int childBookNumber = 0;

  final TextEditingController _bookEventController = TextEditingController();

  @override
  void initState() {
    super.initState();

    bookName = widget.bookData.name;
    bookNumber = widget.bookData.number;
    childBookNumber = widget.bookData.childrenNumber;

    _bookEventController.text = bookName;
  }

  Widget build(BuildContext context) {
    var currentEvent = widget.upperEvent;
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          title: Text(
            "${widget.upperEvent.title} - Gestisci",
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
                        width: 100,
                        height: 200,
                        child: Image(
                            image: widget.eventImage.image,
                            fit: BoxFit.fitHeight),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentEvent.title,
                            style: TextStyle(
                                fontSize: 25,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Text(
                            "Modifica la tua prenotazione",
                            style: TextStyle(
                                color: Color.fromRGBO(50, 50, 50, 1),
                                fontSize: 15),
                          )),
                      Gap(20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _editBookNameMode == 0
                              ? Text(
                            bookName,
                            style: TextStyle(color: Colors.black, fontSize: 20),
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
                                  String enteredValue = (value ?? '').trim();
                                  _bookEventController.text = enteredValue;
                                  if (enteredValue.isEmpty) {
                                    return "Il valore non può essere nullo";
                                  }
                                },
                                controller: _bookEventController,
                              ),
                            ),
                          ),
                          Visibility(
                              visible: _editBookNameMode == 0, child: Gap(
                              10.w)),
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
                            child: Icon(
                              Icons.remove,
                              size: 25,
                            ),
                            onTap: () =>
                                setState(() {
                                  bookNumber--;
                                  if (bookNumber <= 1) bookNumber = 1;
                                }),
                          ),
                          Text(
                            bookNumber.toString(),
                            style: TextStyle(fontSize: 30),
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.add,
                              size: 25,
                            ),
                            onTap: () =>
                                setState(() {
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
                      Gap(5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            child: Icon(
                              Icons.remove,
                              size: 25,
                            ),
                            onTap: () =>
                                setState(() {
                                  childBookNumber--;
                                  if (childBookNumber <= 0) childBookNumber = 0;
                                }),
                          ),
                          Text(
                            childBookNumber.toString(),
                            style: TextStyle(fontSize: 30),
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.add,
                              size: 25,
                            ),
                            onTap: () =>
                                setState(() {
                                  childBookNumber++;
                                }),
                          ),
                        ],
                      ),
                      Gap(20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Icon(
                              Icons.delete,
                              size: 25,
                            ),
                            onTap: () =>
                                setState(() {
                                  // cancella prenotazione
                                }),
                          ),
                          Gap(50.w),
                          GestureDetector(
                            child: Icon(Icons.save, size: 25),
                            onTap: _bookEventSave,
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),),),);
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
    await context.read<AppCubit>().bookEventCassero(
        widget.upperEvent.id!,
        widget.bookData.uid,
        _bookEventController.text,
        bookNumber, childBookNumber);

    context.pop();
  }


  @override
  void dispose() {
    super.dispose();
  }
}
