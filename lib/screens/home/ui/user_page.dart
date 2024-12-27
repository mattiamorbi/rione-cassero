import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:pretty_qr_code_plus/pretty_qr_code_plus.dart';
import 'package:rione_cassero/core/widgets/app_text_form_field.dart';
import 'package:rione_cassero/core/widgets/no_internet.dart';
import 'package:rione_cassero/helpers/extensions.dart';
import 'package:rione_cassero/models/upper_event.dart';
import 'package:rione_cassero/models/user.dart' as up;
import 'package:rione_cassero/theming/colors.dart';

import '../../../helpers/date_time_helper.dart';
import '../../../logic/cubit/app/app_cubit.dart';

// ignore: must_be_immutable
class UserPage extends StatefulWidget {
  up.User user;
  UpperEvent? event;

  UserPage({super.key, required this.user, this.event});

  @override
  State<UserPage> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserPage> {
  bool editCardNumber = false;
  bool loadingCardNumber = false;
  bool forceEntered = false;
  final TextEditingController _cardNumber = TextEditingController();

  TextStyle title =
  TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold);
  TextStyle data = TextStyle(
      color: ColorsManager.gray17, fontSize: 14, fontWeight: FontWeight.normal);

  late String _qrData = "";

  bool _isQrLoading = false;
  bool qrMode = false;

  @override
  void initState() {
    super.initState();

    //if (widget.user.cardNumber == 0) editCardNumber = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
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

  Widget _newUserPage(BuildContext context) {
    int age = widget.user.getAge();
    DateTime? signUpDate;
    try {
      signUpDate = DateTimeHelper.getDateTime(widget.user.signUpDate);
    } catch (e) {}
    try {
      signUpDate = DateTime.parse(widget.user.signUpDate);
    } catch (e) {}

    if (signUpDate == null) {
      signUpDate = DateTime(2024, 1, 1);
    }

    //print(widget.event!.title);

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          foregroundColor: ColorsManager.gray17,
          backgroundColor: ColorsManager.background,
          title: Text(
            "RIONE CASSERO - ${widget.user.name} ${widget.user.surname}",
            style: TextStyle(color: ColorsManager.gray17),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(
              top: 15.0, bottom: 15.0, left: 40.0, right: 40.0),
          child: !qrMode ? SingleChildScrollView(
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "NOME   ",
                    style: title,
                  ),
                  Text(
                    "${widget.user.name} ${widget.user.surname}",
                    style: data,
                  ),
                  Visibility(
                    visible: widget.user.cardNumber != 0,
                    child: Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                              onTap: _showUserQr,
                              child: Icon(Icons.qr_code,
                                  color: ColorsManager.gray17, size: 35))),

                    ),
                  )
                ],
              ),
              Gap(25.h),
              //Row(
              //  mainAxisAlignment: MainAxisAlignment.start,
              //  children: [
              //    Text(
              //      "DATA DI NASCITA   ",
              //      style: title,
              //    ),
              //    Text(
              //      "${widget.user.birthdate} (${age} anni)",
              //      style: data,
              //    ),
              //  ],
              //),
              //Gap(25.h),
              //Row(
              //  mainAxisAlignment: MainAxisAlignment.start,
              //  children: [
              //    Text(
              //      "LUOGO DI NASCITA   ",
              //      style: title,
              //    ),
              //    Text(
              //      "${widget.user.birthplace}",
              //      style: data,
              //    ),
              //  ],
              //),
              //Gap(25.h),
              //Row(
              //  mainAxisAlignment: MainAxisAlignment.start,
              //  children: [
              //    Text(
              //      "RESIDENZA   ",
              //      style: title,
              //    ),
              //    Text(
              //      "${widget.user.address}",
              //      style: data,
              //    ),
              //  ],
              //),
              //Gap(25.h),
              //Row(
              //  mainAxisAlignment: MainAxisAlignment.start,
              //  children: [
              //    Text(
              //      "CITTA'   ",
              //      style: title,
              //    ),
              //    Text(
              //      "${widget.user.city}  (${widget.user.cap})",
              //      style: data,
              //    ),
              //  ],
              //),
              //Gap(25.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "E-MAIL   ",
                    style: title,
                  ),
                  Text(
                    "${widget.user.email}",
                    style: data,
                  ),
                ],
              ),
              Gap(25.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "TELEFONO   ",
                    style: title,
                  ),
                  Text(
                    "${widget.user.telephone}",
                    style: data,
                  ),
                ],
              ),
              Gap(25.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "DATA ISCRIZIONE   ",
                    style: title,
                  ),
                  Text(
                    "${signUpDate.day}/${signUpDate.month}/${signUpDate
                        .year} ${signUpDate.hour}:${signUpDate.minute}",
                    style: data,
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
                      style: title,
                    ),
                    Text(
                      widget.user.cardNumber == 0
                          ? "NON TESSERATO"
                          : "${widget.user.cardNumber}",
                      style: TextStyle(
                          color: widget.user.cardNumber == 0
                              ? Colors.red
                              : ColorsManager.gray17,
                          fontSize: data.fontSize),
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
                  Visibility(
                    visible: loadingCardNumber,
                    child: Row(
                      children: [
                        Icon(
                          Icons.downloading,
                          color: ColorsManager.gray17,
                          size: 30,
                        ),
                        Gap(10.w),
                        Text(
                          "Creazione tessera in corso...",
                          style: TextStyle(color: ColorsManager.gray17, fontSize: 15),
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: widget.user.cardNumber == 0 && !loadingCardNumber,
                    child: GestureDetector(
                      child: Row(
                        children: [
                          Icon(
                            Icons.app_registration,
                            color: ColorsManager.gray17,
                            size: 30,
                          ),
                          Gap(10.w),
                          Text(
                            "Assegna tessera",
                            style: TextStyle(color: ColorsManager.gray17, fontSize: 15),
                          )
                        ],
                      ),
                      onTap: () => _assignCardNumber(widget.user),
                    ),
                  ),
                  Gap(15.w),
                  Visibility(
                    visible: widget.user.cardNumber != 0 && !loadingCardNumber,
                    child: GestureDetector(
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 30,
                          ),
                          Gap(10.w),
                          Text(
                            "Cancella tessera",
                            style: TextStyle(color: Colors.red, fontSize: 15),
                          )
                        ],
                      ),
                      onTap: () => _removeCardNumber(widget.user),
                    ),
                  ),
                  Gap(15.w),
                  Visibility(
                    visible:
                    widget.event != null ? widget.event!.isToday! : false,
                    child: GestureDetector(
                      child: Row(
                        children: [
                          Icon(
                            Icons.event,
                            color: forceEntered ? Colors.green : Colors.orange,
                            size: 30,
                          ),
                          Gap(10.w),
                          Text(
                            forceEntered
                                ? "Aggiunto come entrato"
                                : "Ingresso manuale",
                            style: TextStyle(
                                color:
                                forceEntered ? Colors.green : Colors.orange,
                                fontSize: 15),
                          )
                        ],
                      ),
                      onTap: () =>
                          _forceEnteredUser(widget.user, widget.event!),
                    ),
                  ),
                ],
              )
            ]),
          ) :
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                  color: ColorsManager.gray17,
                  borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: SizedBox(
                  width: 320,
                  child: Center(
                      child:  GestureDetector(
                        onTap: _toggleTapQr,
                        child: PrettyQrPlus(
                          data: _qrData,
                          size: 290,
                          elementColor: Colors.black,
                          roundEdges: false,
                          typeNumber: null,
                        ),
                      )
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUserQr() async {
    setState(() {
      _isQrLoading = true;
    });
    var user = await context.read<AppCubit>().getUserFromUser(widget.user);
    setState(() {
      _qrData = user.getQrData();
      _isQrLoading = false;
      qrMode = true;
    });
  }

  void _toggleTapQr() {
    setState(() {
      qrMode = false;
    });
  }

  void _forceEnteredUser(up.User user, UpperEvent event) async {
    await context.read<AppCubit>().joinEvent(event.id!, user);
    setState(() {
      forceEntered = true;
    });
  }

  void _updateUser(up.User _user) async {
    _user.cardNumber = int.tryParse(_cardNumber.text)!;
    await context.read<AppCubit>().updateUserInfo(_user);
    setState(() {
      editCardNumber = false;
      context.pop();
    });
  }

  void _assignCardNumber(up.User _user) async {
    setState(() {
      loadingCardNumber = true;
    });
    _user.cardNumber = await context.read<AppCubit>().getNewIndex();
    await context.read<AppCubit>().updateUserInfo(_user);
    setState(() {
      editCardNumber = false;
      loadingCardNumber = false;
      //context.pop();
    });
  }

  void _removeCardNumber(up.User _user) async {
    setState(() {
      loadingCardNumber = true;
    });
    _user.cardNumber = 0;
    await context.read<AppCubit>().updateUserInfo(_user);
    setState(() {
      editCardNumber = false;
      loadingCardNumber = false;
      //context.pop();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _cardNumber.dispose();
  }
}
