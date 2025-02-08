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

    _filteredBook = widget.bookData;
    //_totalJoinBook = widget.bookData;

    //_loadEventSubscription();

    //Future.delayed(Duration(seconds: 3));

    //if (kDebugMode) {
    //  print(_totalJoinEvent.length);
    //  print(_filteredUsers.length);
    //}

    //_isUsersLoading = false;
  }

  // void _loadEventSubscription() {
  //   _presenceSubscription = context
  //       .read<AppCubit>()
  //       .getEventsParticipantStream(widget.upperEvent.id!, widget.allUsers)
  //       .listen((snapshot) {
  //     setState(() {
  //       participantsUsers = snapshot;
  //       _totalJoinEvent = _createJoinList();
  //       _filteredUsers = _totalJoinEvent;
  //     });
  //   });
//
  //   _bookSubscription = context
  //       .read<AppCubit>()
  //       .getEventsBookStream(widget.upperEvent.id!, widget.allUsers)
  //       .listen((snapshot) {
  //     setState(() {
  //       bookedUsers = snapshot;
  //       _totalJoinEvent = _createJoinList();
  //       _filteredUsers = _totalJoinEvent;
  //     });
  //   });
  // }

  //List<up.User> _createJoinList() {
  //  // Creiamo una mappa per gestire l'unione
  //  Map<String, up.User> userMap = {};
  //  if (kDebugMode) print(bookedUsers!.length);
  //  // Aggiungo prima i prenotati
  //  for (var us in bookedUsers!) {
  //    //userMap[us.uid!]?.state = 'booked';
  //    userMap[us!.uid!] = us.copyWith(state: 'booked');
  //  }
//
  //  // Poi aggiungo i partecipanti, sovrascrivendo se già esiste
  //  for (var us in participantsUsers!) {
  //    userMap[us!.uid!] = us.copyWith(state: 'joined');
  //    // userMap[us.uid!]?.state = 'joined';
  //  }
//
  //  if (kDebugMode) print("user map ${userMap.length}");
//
  //  // Converto la mappa in una lista finale
  //  return userMap.values.toList();
  //}

  // Funzione per filtrare la lista degli utenti in base al testo inserito
  void filterUsers(String query) {
    List<ParticipantDataCassero> filtered = widget.bookData.where((book) {
      String fullName =
          '${book.name.toLowerCase()} ${book.bookUserName.toLowerCase()}';

      bool result = fullName.contains(query.toLowerCase());
      if (_allergyFilter) result = result && book.allergy == true;
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
                      "Prenotazioni: ${widget.bookData.length}",
                      style: TextStyle(color: ColorsManager.gray17),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin!,
                      child: Text(
                        "Persone totali: ${getTotalBookPeople(widget.bookData, false)}",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin!,
                      child: Text(
                        "Bambini totali: ${getTotalBookChild(widget.bookData, false)}",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin! &&
                          widget.upperEvent.price != null &&
                          widget.upperEvent.childrenPrice != null,
                      child: Text(
                        "Incasso previsto: ${(widget.upperEvent.price! * getTotalBookPeople(widget.bookData, false)) + (widget.upperEvent.childrenPrice! * getTotalBookChild(widget.bookData, false))} €",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin! &&
                          widget.upperEvent.price != null &&
                          widget.upperEvent.childrenPrice != null,
                      child: Text(
                        "Incasso attuale: ${(widget.upperEvent.price! * getTotalBookPeople(widget.bookData, true)) + (widget.upperEvent.childrenPrice! * getTotalBookChild(widget.bookData, true))} €",
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
                          return GestureDetector(
                            onTap: () =>
                            widget.isMoneyScreen ? _managePayment(_filteredBook[index], index) : _manageBook(_filteredBook[index], index, notPaied != totalBook && !widget.loggedUser.isAdmin!),
                            //child: ListTile(
                            //  tileColor: !widget.isMoneyScreen
                            //      ? ColorsManager.background
                            //      : notPaied > 0
                            //          ? Colors.amberAccent
                            //          : Colors.green,
                            //  textColor: Colors.black,
                            //  subtitleTextStyle: TextStyle(
                            //    fontSize: 12,
                            //    color: Colors.black38,
                            //  ),
                            //  shape: RoundedRectangleBorder(
                            //    //<-- SEE HERE
                            //    side: BorderSide(
                            //        width: 0, color: ColorsManager.background),
                            //    borderRadius: BorderRadius.circular(20),
                            //  ),
                            //  //onTap: () => _showUser(user, widget.upperEvent),
                            //  //leading: Icon(
                            //  //  Icons.person_outline,
                            //  //  color: user.state == 'booked'
                            //  //      ? Colors.orange
                            //  //      : user.state == 'joined'
                            //  //          ? Colors.green
                            //  //          : Colors.black,
                            //  //),
                            //  leading: Icon(
                            //    _filteredBook[index].allergy != null &&
                            //            _filteredBook[index].allergy == true
                            //        ? Icons.no_food
                            //        : Icons.bookmark_border,
                            //    color: Colors.black,
                            //  ),
                            //  trailing: Text(
                            //    widget.isMoneyScreen ? "${totalBook - notPaied} / ${totalBook}" : notPaied == 0 ? "PAGATO" : (widget.upperEvent.price! * widget.bookData[index].paied!) + (widget.upperEvent.childrenPrice! * widget.bookData[index].childrenPaied!) == 0 ? "${(widget.upperEvent.price! * widget.bookData[index].number) + (widget.upperEvent.childrenPrice! * widget.bookData[index].childrenNumber)} €" : "${(widget.upperEvent.price! * widget.bookData[index].paied!) + (widget.upperEvent.childrenPrice! * widget.bookData[index].childrenPaied!)} € / ${(widget.upperEvent.price! * widget.bookData[index].number) + (widget.upperEvent.childrenPrice! * widget.bookData[index].childrenNumber)} €",
                            //    style: TextStyle(
                            //        fontSize: 14,
                            //        color: Colors.black,
                            //        fontWeight: FontWeight.bold),
                            //  ),
//
                            //  //trailing: GestureDetector(
                            //  //  child: Icon(Icons.delete, color: Colors.red),
                            //  //  onTap: () {},
                            //  //),
                            //  title: widget.isMoneyScreen ? Text(
                            //      "${user.name}") : Text(totalBook > 1
                            //      ? "${user.name} (${totalBook} persone)"
                            //      : "${user.name} (${totalBook} persona)"),
                            //  subtitle: Text(
                            //      //'Email: ${user.email}\nData di nascita: ${user.birthdate}'),
                            //      widget.isMoneyScreen
                            //          ? 'Prenotazione effettuata da: ${user.bookUserName}'
                            //          : 'Effettuata da: ${user.bookUserName}'),
                            //),
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
                                    colors: [
                                      notPaied == 0 ? Colors.lightGreen[100]! : !widget.isMoneyScreen ? Colors.blue[100]! : Colors.red[100]!,
                                      notPaied == 0 ? Colors.lightGreen[300]! : !widget.isMoneyScreen ? Colors.blue[300]! : Colors.red[300]!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                  leading: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8), // Sfondo per l'icona
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _filteredBook[index].allergy != null &&
                                          _filteredBook[index].allergy == true
                                          ? Icons.no_food
                                          : Icons.bookmark_border,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  title: Text(
                                    widget.isMoneyScreen
                                        ? "${user.name}"
                                        : totalBook > 1
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
                                        ? 'Prenotazione effettuata da: ${user.bookUserName}'
                                        : 'Effettuata da: ${user.bookUserName}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: notPaied == 0 ? Colors.green[700] : widget.isMoneyScreen? Colors.red[700] : Colors.blue[700],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      widget.isMoneyScreen
                                          ? "${notPaied} DA PAGARE"
                                          : notPaied == 0
                                          ? "PAGATO" : notPaied != totalBook ?
                                          "${notPaied} DA PAGARE" : "MODIFICA",
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
                                  tileColor: Colors.transparent, // Lascia il colore trasparente
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


  Future<void> _manageBook(
      ParticipantDataCassero currentBookData, int index, bool alreadyPaied) async {
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
