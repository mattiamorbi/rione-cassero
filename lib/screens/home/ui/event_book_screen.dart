import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rione_cassero/core/widgets/app_text_form_field.dart';
import 'package:rione_cassero/models/participant_data.dart';
import 'package:rione_cassero/models/upper_event.dart';
import 'package:rione_cassero/models/user.dart' as up;
import 'package:rione_cassero/theming/colors.dart';

import '../../../routing/routes.dart';

// ignore: must_be_immutable
class EventBookScreen extends StatefulWidget {
  UpperEvent upperEvent;
  up.User loggedUser;
  Image eventImage;
  bool isMoneyScreen;

  //List<up.User> allUsers = [];
  List<ParticipantDataCassero> bookData = [];

  //List<up.User> bookedUsers = [];
  //List<up.User> participantsUsers = [];

  EventBookScreen(
      {super.key,
      required this.upperEvent,
      required this.bookData,
      required this.loggedUser,
      required this.eventImage,
      required this.isMoneyScreen});

  //required this.bookedUsers,
  //required this.participantsUsers});

  @override
  State<EventBookScreen> createState() => _EventBookScreenState();
}

class _EventBookScreenState extends State<EventBookScreen> {
  //List<ParticipantDataCassero> _totalJoinBook = [];
  List<ParticipantDataCassero> _filteredBook = [];
  List<ParticipantDataCassero> _preFilteredBook = [];
  int toBeConfirmedBook = 0;

  //List<up.User?>? bookedUsers = [];
  //List<up.User?>? participantsUsers = [];

  final TextEditingController _searchController = TextEditingController();

  bool _allergyFilter = false;

  //bool _isUsersLoading = true;

  //StreamSubscription<List<up.User>?>? _presenceSubscription;
  //StreamSubscription<List<up.User>?>? _bookSubscription;

  @override
  void initState() {
    super.initState();

    _loadFilteredBook();


  }

  void _loadFilteredBook() {
    if (_preFilteredBook.length > 0) {
      _preFilteredBook.clear();
      toBeConfirmedBook = 0;
    }
    if (widget.isMoneyScreen &&
        widget.upperEvent.confirmation != null &&
        widget.upperEvent.confirmation!) {
      for (int i = 0; i < widget.bookData.length; i++) {
        if (widget.bookData[i].confirmed!) {
          _preFilteredBook.add(widget.bookData[i]);
        }
      }
    } else {
      for (int i = 0; i < widget.bookData.length; i++) {
        if (!widget.bookData[i].confirmed!) {
          _preFilteredBook.add(widget.bookData[i]);
          toBeConfirmedBook++;
        }
      }
      for (int i = 0; i < widget.bookData.length; i++) {
        if (widget.bookData[i].confirmed!) {
          _preFilteredBook.add(widget.bookData[i]);
        }
      }
    }

    _filteredBook = _preFilteredBook;
  }

  // Funzione per filtrare la lista degli utenti in base al testo inserito
  void filterUsers(String query) {
    List<ParticipantDataCassero> filtered = _preFilteredBook.where((book) {
      String fullName =
          '${book.name.toLowerCase()} ${book.bookUserName.toLowerCase()}';

      bool result = fullName.contains(query.toLowerCase());
      if (_allergyFilter) result = result && book.allergy == true;
      //if (widget.isMoneyScreen || widget.upperEvent.confirmation != null) result = result && book.confirmed != null && book.confirmed!;
      return result;
    }).toList();

    setState(() {
      _filteredBook = filtered;
    });
  }

  int calcTotalBook(ParticipantDataCassero book) {
    int total = book.number + book.childrenNumber;
    return (total);
  }

  int calcNotPaied(ParticipantDataCassero book) {
    int total = book.number + book.childrenNumber;
    int paied = book.paied ?? 0;
    int chPaied = book.childrenPaied ?? 0;
    return (total - paied - chPaied);
  }

  int getTotalBookPeople(List<ParticipantDataCassero> list, bool paied) {
    int sum = 0;
    for (var book in list) {
      //var event = UpperEvent.fromJson(doc.data());
      //print(doc.id);
      sum += paied ? book.paied ?? 0 : book.number;
    }
    return sum;
  }

  int getTotalBookChild(List<ParticipantDataCassero> list, bool paied) {
    int sum = 0;
    for (var book in list) {
      //var event = UpperEvent.fromJson(doc.data());
      //print(doc.id);
      sum += paied ? book.childrenPaied ?? 0 : book.childrenNumber;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          title: Text(
            widget.isMoneyScreen
                ? "${widget.upperEvent.title} - Cassa"
                : "${widget.upperEvent.title} - Prenotazioni",
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: AppTextFormField(
                          hint: "Cerca",
                          validator: (value) {},
                          controller: _searchController,
                          isObscureText: false,
                          suffixIcon: Icon(
                            Icons.search,
                            color: Colors.black38,
                          ),
                          onChanged: (value) {
                            filterUsers(value);
                          },
                        ),
                      ),
                    ),
                    Text(
                      widget.isMoneyScreen
                          ? "Prenotazioni: ${_preFilteredBook.length}"
                          : toBeConfirmedBook > 0
                              ? "Prenotazioni: ${_preFilteredBook.length} (Da confermare: ${toBeConfirmedBook})"
                              : "Prenotazioni: ${_preFilteredBook.length}",
                      style: TextStyle(color: ColorsManager.gray17),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin!,
                      child: Text(
                        "Persone totali: ${getTotalBookPeople(_preFilteredBook, false)}",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin!,
                      child: Text(
                        "Bambini totali: ${getTotalBookChild(_preFilteredBook, false)}",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin! &&
                          widget.upperEvent.price != null &&
                          widget.upperEvent.childrenPrice != null,
                      child: Text(
                        "Incasso previsto: ${(widget.upperEvent.price! * getTotalBookPeople(_preFilteredBook, false)) + (widget.upperEvent.childrenPrice! * getTotalBookChild(_preFilteredBook, false))} €",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin! &&
                          widget.upperEvent.price != null &&
                          widget.upperEvent.childrenPrice != null,
                      child: Text(
                        "Incasso attuale: ${(widget.upperEvent.price! * getTotalBookPeople(_preFilteredBook, true)) + (widget.upperEvent.childrenPrice! * getTotalBookChild(_preFilteredBook, true))} €",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Gap(10.h),
                    Visibility(
                      visible:
                          widget.loggedUser.isAdmin! && !widget.isMoneyScreen,
                      child: GestureDetector(
                          onTap: () => setState(() {
                                _allergyFilter = !_allergyFilter;
                                filterUsers(_searchController.text);
                              }),
                          child: Icon(
                              _allergyFilter
                                  ? Icons.no_food
                                  : Icons.no_food_outlined,
                              size: 30)),
                    ),
                    Gap(15.h),
                  ],
                ),
              ),
              Expanded(
                child: _filteredBook.isEmpty
                    ? Center(child: Text('Nessuna prenotazione trovata'))
                    : ListView.builder(
                        itemCount: _filteredBook.length,
                        itemBuilder: (context, index) {
                          final user = _filteredBook[index];
                          int notPaied = calcNotPaied(user);
                          int totalBook = calcTotalBook(user);

                          late Color bgShade1;
                          late Color bgShade2;
                          late Color textColor;
                          late Color subTextColor;

                          if (widget.isMoneyScreen) {
                            if (notPaied == 0) {
                              // verde
                              bgShade1 = Colors.lightGreen[100]!;
                              bgShade2 = Colors.lightGreen[300]!;
                              textColor = Colors.lightGreen[900]!;
                              subTextColor = Colors.lightGreen[700]!;
                            } else {
                              //rosso
                              bgShade1 = Colors.red[100]!;
                              bgShade2 = Colors.red[300]!;
                              textColor = Colors.red[900]!;
                              subTextColor = Colors.red[700]!;
                            }

                          } else {
                            if (user.confirmed!) {
                              bgShade1 = Colors.lightBlue[100]!;
                              bgShade2 = Colors.lightBlue[300]!;
                              textColor = Colors.blue[900]!;
                              subTextColor = Colors.blue[700]!;
                            } else {
                              bgShade1 = Colors.orange[100]!;
                              bgShade2 = Colors.orange[300]!;
                              textColor = Colors.orange[900]!;
                              subTextColor = Colors.orange[700]!;
                            }
                          }

                          return GestureDetector(
                            onTap: () => widget.isMoneyScreen
                                ? _managePayment(_filteredBook[index], index)
                                : _manageBook(
                                    _filteredBook[index],
                                    index,
                                    notPaied != totalBook &&
                                        !widget.loggedUser.isAdmin!),
                            child: Card(
                              elevation: 10,
                              // Ombra intorno alla card
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    20), // Angoli arrotondati
                              ),
                              shadowColor: Colors.black.withOpacity(0.3),
                              // Colore ombra
                              child: Container(
                                padding:
                                    EdgeInsets.all(10), // Spaziatura interna
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      //notPaied == 0 ? Colors.lightGreen[100]! : !widget.isMoneyScreen ? Colors.blue[100]! : Colors.red[100]!,
                                      //notPaied == 0 ? Colors.lightGreen[300]! : !widget.isMoneyScreen ? Colors.blue[300]! : Colors.red[300]!,
                                      //notPaied == 0
                                      //    ? Colors.lightGreen[100]!
                                      //    : widget.isMoneyScreen
                                      //        ? Colors.red[100]!
                                      //        : (user.confirmed != null &&
                                      //                user.confirmed! &&
                                      //                widget
                                      //                    .loggedUser.isAdmin!)
                                      //            ? Colors.green[100]!
                                      //            : Colors.blue[100]!,
                                      //notPaied == 0
                                      //    ? Colors.lightGreen[300]!
                                      //    : widget.isMoneyScreen
                                      //        ? Colors.red[300]!
                                      //        : (user.confirmed != null &&
                                      //                user.confirmed! &&
                                      //                widget
                                      //                    .loggedUser.isAdmin!)
                                      //            ? Colors.green[300]!
                                      //            : Colors.blue[300]!,
                                      bgShade1,
                                      bgShade2,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  leading: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      // Sfondo per l'icona
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _filteredBook[index].allergy != null &&
                                              _filteredBook[index].allergy ==
                                                  true
                                          ? Icons.no_food
                                          : Icons.bookmark_border,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  title: Text(
                                    totalBook > 1
                                        ? "${user.name} (${totalBook} persone)"
                                        : "${user.name} (${totalBook} persona)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    widget.isMoneyScreen
                                        ? "Prenotazione effettuata da: ${user.bookUserName}"
                                        : widget.loggedUser.isAdmin! ? "Effettuata da: ${user.bookUserName}\r\n${user.date!.day}/${user.date!.month}/${user.date!.year} ${user.date!.hour}:${user.date!.minute}"
                                        : "Effettuata da: ${user.bookUserName}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      //color: notPaied == 0
                                      //    ? Colors.green[700]
                                      //    : widget.isMoneyScreen
                                      //        ? Colors.red[700]
                                      //        : (user.confirmed != null &&
                                      //                user.confirmed! &&
                                      //                widget
                                      //                    .loggedUser.isAdmin!)
                                      //            ? Colors.green[700]
                                      //            : Colors.blue[700],
                                      color: textColor,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      widget.isMoneyScreen
                                          ? notPaied == 0
                                              ? "PAGATO"
                                              : "${notPaied} DA PAGARE"
                                          : notPaied == 0
                                              ? "PAGATO"
                                              : notPaied != totalBook
                                                  ? "${notPaied} DA PAGARE"
                                                  : (user.confirmed != null &&
                                                          user.confirmed! &&
                                                          widget.loggedUser
                                                              .isAdmin!)
                                                      ? "MODIFICA"
                                                      : "GESTISCI",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  // trailing: Column(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   children: [
                                  //     Text(
                                  //       widget.isMoneyScreen
                                  //           ? "${totalBook - notPaied} / ${totalBook}"
                                  //           : notPaied == 0
                                  //           ? "PAGATO"
                                  //           : (widget.upperEvent.price! *
                                  //           widget.bookData[index].paied!) +
                                  //           (widget.upperEvent.childrenPrice! *
                                  //               widget.bookData[index].childrenPaied!) ==
                                  //           0
                                  //           ? "${(widget.upperEvent.price! * widget.bookData[index].number) + (widget.upperEvent.childrenPrice! * widget.bookData[index].childrenNumber)} €"
                                  //           : "${(widget.upperEvent.price! * widget.bookData[index].paied!) + (widget.upperEvent.childrenPrice! * widget.bookData[index].childrenPaied!)} € / ${(widget.upperEvent.price! * widget.bookData[index].number) + (widget.upperEvent.childrenPrice! * widget.bookData[index].childrenNumber)} €",
                                  //       style: TextStyle(
                                  //         fontSize: 14,
                                  //         color: Colors.black,
                                  //         fontWeight: FontWeight.bold,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  tileColor: Colors
                                      .transparent, // Lascia il colore trasparente
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

  Future<void> _manageBook(ParticipantDataCassero currentBookData, int index,
      bool alreadyPaied) async {
    if (!alreadyPaied) {
      await Navigator.pushNamed(
        context,
        Routes.manageBookScreen,
        arguments: {
          'user': widget.loggedUser,
          'event': widget.upperEvent,
          'bookData': currentBookData,
          'image': widget.eventImage,
          'isNewBook': false,
        },
      );
    } else {
      await AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: 'Prenotazione chiusa',
        desc: "Non è più possibile modificare questa prenotazione",
      ).show();
    }

    //if (result == 'edit') {
    //  final updated = await context.read<AppCubit>().getSingleBookEventCassero(
    //          widget.upperEvent.id!, currentBookData.eventUid)
    //      as ParticipantDataCassero;
    //  setState(() {
    //    widget.bookData[index] = updated;
    //  });
    //} else if (result == 'delete') {
    //  setState(() {});
    //}
    _loadFilteredBook();
    setState(() {});
  }

  Future<void> _managePayment(
      ParticipantDataCassero currentBookData, int index) async {
    await Navigator.pushNamed(
      context,
      Routes.managePaymentScreen,
      arguments: {
        'user': widget.loggedUser,
        'event': widget.upperEvent,
        'bookData': currentBookData,
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }
}
