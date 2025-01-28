import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rione_cassero/logic/cubit/app/app_cubit.dart';
import 'package:rione_cassero/models/participant_data.dart';
import 'package:rione_cassero/models/upper_event.dart';
import 'package:rione_cassero/models/user.dart' as up;
import 'package:rione_cassero/theming/colors.dart';

class PaymentHelper {
  int type;
  bool paied;

  static final int adult = 0;
  static final int child = 1;

  PaymentHelper({required this.type, required this.paied});

  void pay() {
    this.paied = true;
  }

  void unpay() {
    this.paied = false;
  }
}

// ignore: must_be_immutable
class ManagePaymentScreen extends StatefulWidget {
  UpperEvent upperEvent;
  ParticipantDataCassero bookData;
  up.User loggedUser;

  ManagePaymentScreen({
    super.key,
    required this.upperEvent,
    required this.bookData,
    required this.loggedUser,
  });

  @override
  State<ManagePaymentScreen> createState() => _ManagePaymentScreenState();
}

class _ManagePaymentScreenState extends State<ManagePaymentScreen> {
  int _editBookNameMode = 0;
  String bookName = "";
  int bookNumber = 1;
  int childBookNumber = 0;

  final TextEditingController _bookEventController = TextEditingController();
  final TextEditingController _allergyNoteController = TextEditingController();
  bool allergy = false;
  final formKey = GlobalKey<FormState>();

  List<PaymentHelper> paymentList = [];

  bool actionInProgress = false;

  @override
  void initState() {
    super.initState();

    bookName = widget.bookData.name;
    bookNumber = widget.bookData.number;
    childBookNumber = widget.bookData.childrenNumber;

    allergy = widget.bookData.allergy ?? false;
    _allergyNoteController.text = widget.bookData.allergyNote ?? "";

    _bookEventController.text = bookName;

    for (int i = 0; i < widget.bookData.number; i++) {
      paymentList.add(PaymentHelper(
          type: PaymentHelper.adult, paied: i < widget.bookData.paied!));
    }

    for (int i = 0; i < widget.bookData.childrenNumber; i++) {
      paymentList.add(PaymentHelper(
          type: PaymentHelper.child, paied: i < widget.bookData.childrenPaied!));
    }
  }

  int getRealTimePayment(int type) {
    int tot = 0;
    for (int i = 0; i < paymentList.length; i++) {
      if (paymentList[i].paied && paymentList[i].type == type) tot++;
    }

    return tot;
  }

  Widget build(BuildContext context) {
    var currentEvent = widget.upperEvent;
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          title: Text(
            "${widget.bookData.name} - Pagamento",
            style: TextStyle(fontSize: 24, color: ColorsManager.gray17),
          ),
          foregroundColor: ColorsManager.gray17,
          backgroundColor: ColorsManager.background,
          titleTextStyle: TextStyle(color: ColorsManager.gray17),
        ),
        body: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Container(
                color: ColorsManager.background,
                width: double.infinity,
                child: Column(
                  children: [
                    Visibility(
                      visible: widget.loggedUser.isAdmin!,
                      child: Text(
                        "Persone totali: ${widget.bookData.number}",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin!,
                      child: Text(
                        "Bambini totali: ${widget.bookData.childrenNumber}",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin!,
                      child: Text(
                        "Adulti pagati: ${getRealTimePayment(PaymentHelper.adult)}",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin!,
                      child: Text(
                        "Bambini pagati: ${getRealTimePayment(PaymentHelper.child)}",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin! &&
                          widget.upperEvent.price != null &&
                          widget.upperEvent.childrenPrice != null,
                      child: Text(
                        "Incasso previsto: ${(widget.upperEvent.price! * widget.bookData.number!) + (widget.upperEvent.childrenPrice! * widget.bookData.childrenNumber!)} €",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin! &&
                          widget.upperEvent.price != null &&
                          widget.upperEvent.childrenPrice != null,
                      child: Text(
                        "Incasso attuale: ${(widget.upperEvent.price! * getRealTimePayment(PaymentHelper.adult)) + (widget.upperEvent.childrenPrice! * getRealTimePayment(PaymentHelper.child))} €",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Gap(10.h),
                    GestureDetector(
                        onTap: !actionInProgress ? savePaymentData : null,
                        child: Icon(Icons.save, size: 30)),
                    Gap(15.h),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: paymentList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => setState(() {
                        paymentList[index].paied = !paymentList[index].paied;
                      }),
                     // child: ListTile(
                     //   tileColor: paymentList[index].paied
                     //       ? Colors.lightGreen
                     //       : Colors.amberAccent,
                     //   textColor: Colors.black,
                     //   subtitleTextStyle: TextStyle(
                     //     fontSize: 12,
                     //     color: Colors.black38,
                     //   ),
                     //   shape: RoundedRectangleBorder(
                     //     //<-- SEE HERE
                     //     side: BorderSide(
                     //         width: 0, color: ColorsManager.background),
                     //     borderRadius: BorderRadius.circular(20),
                     //   ),
                     //   //onTap: () => _showUser(user, widget.upperEvent),
                     //   //leading: Icon(
                     //   //  Icons.person_outline,
                     //   //  color: user.state == 'booked'
                     //   //      ? Colors.orange
                     //   //      : user.state == 'joined'
                     //   //          ? Colors.green
                     //   //          : Colors.black,
                     //   //),
                     //   leading: Icon(
                     //     paymentList[index].type == PaymentHelper.adult
                     //         ? Icons.person
                     //         : Icons.bedroom_baby,
                     //     color: Colors.black,
                     //   ),
                     //   // trailing: GestureDetector(
                     //   //   onTap: () => setState(() {
                     //   //     paymentList[index].paied = !paymentList[index].paied;
                     //   //   }),
                     //   //   child: Text(
                     //   //     paymentList[index].paied ? "PAGATO" : "GESTISCI",
                     //   //     style: TextStyle(
                     //   //         fontSize: 14,
                     //   //         color: Colors.black,
                     //   //         fontWeight: FontWeight.bold),
                     //   //   ),
                     //   // ),
//
                     //   //trailing: GestureDetector(
                     //   //  child: Icon(Icons.delete, color: Colors.red),
                     //   //  onTap: () {},
                     //   //),
                     //   title: Text(
                     //       paymentList[index].type == PaymentHelper.adult
                     //           ? "Adulto"
                     //           : "Bambino"),
                     //   subtitle: Text(
                     //       paymentList[index].type == PaymentHelper.adult
                     //           ? "${widget.upperEvent.price} €"
                     //           : "${widget.upperEvent.childrenPrice} €"),
                     // ),
                      child: Card(
                        elevation: 10, // Ombra intorno alla card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Angoli arrotondati
                        ),
                        shadowColor: Colors.black.withOpacity(0.3), // Colore ombra
                        child: Container(
                          padding: EdgeInsets.all(10), // Spaziatura interna
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: paymentList[index].paied
                                  ? [Colors.lightGreen[300]!, Colors.lightGreen[500]!]
                                  : [Colors.red[300]!, Colors.red[500]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            leading: Container(
                              padding: EdgeInsets.all(8), // Margine interno per l'icona
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9), // Sfondo bianco per l'icona
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                paymentList[index].type == PaymentHelper.adult
                                    ? Icons.person
                                    : Icons.bedroom_baby,
                                color: Colors.black87,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              paymentList[index].type == PaymentHelper.adult ? "Adulto" : "Bambino",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              paymentList[index].type == PaymentHelper.adult
                                  ? "${widget.upperEvent.price} €"
                                  : "${widget.upperEvent.childrenPrice} €",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () => setState(() {
                                paymentList[index].paied = !paymentList[index].paied;
                              }),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: paymentList[index].paied ? Colors.green[700] : Colors.red[700],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  paymentList[index].paied ? "PAGATO" : "PAGA",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> savePaymentData() async {
    setState(() {
      actionInProgress = true;
    });

    int paied = getRealTimePayment(PaymentHelper.adult);
    int childPaied = getRealTimePayment(PaymentHelper.child);

    try {
      await context.read<AppCubit>().bookEventCassero(
          widget.bookData.uid!,
          widget.bookData.bookUserName,
          widget.upperEvent.id!,
          widget.bookData.eventUid,
          _bookEventController.text,
          bookNumber,
          childBookNumber,
          allergy,
          _allergyNoteController.text,
          paied,
          childPaied);

      await AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        title: 'Pagamento registrato',
        desc: "${widget.bookData.name}",
      ).show();

      widget.bookData.paied = paied;
      widget.bookData.childrenPaied = childPaied;

      Navigator.pop(context);
    } catch (e) {
      print(e.toString());
      await AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: 'Pagamento non registrato',
        desc: "Errore: ${e.toString()}",
      ).show();

      Navigator.pop(context);
    }
  }

//  Future<void> _bookEventSave() async {
//    if ((_editBookNameMode == 1 && _bookEventController.text.length == 0) ||
//        (allergy && _allergyNoteController.text.length == 0)) {
//      formKey.currentState!.validate();
//    } else {
//      await context.read<AppCubit>().bookEventCassero(
//          widget.upperEvent.id!,
//          widget.isNewBook ? null : widget.bookData.eventUid,
//          _bookEventController.text,
//          bookNumber,
//          childBookNumber,
//          allergy,
//          _allergyNoteController.text);
//
//      if (widget.isNewBook) {
//        await AwesomeDialog(
//          context: context,
//          dialogType: DialogType.success,
//          animType: AnimType.topSlide,
//          title: 'Prenotazione confermata',
//          desc: "Grazie ${_bookEventController.text}, ti aspettiamo!",
//        ).show();
//      } else {
//        await AwesomeDialog(
//          context: context,
//          dialogType: DialogType.success,
//          animType: AnimType.topSlide,
//          title: 'Prenotazione modificata',
//          desc: "Dati aggiornati con successo",
//        ).show();
//      }
//
//      Navigator.pop(context);
//    }
//  }

  void _bookEventUndo() {
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
