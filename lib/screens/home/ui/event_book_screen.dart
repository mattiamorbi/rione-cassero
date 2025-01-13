import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rione_cassero/core/widgets/app_text_form_field.dart';
import 'package:rione_cassero/helpers/extensions.dart';
import 'package:rione_cassero/models/participant_data.dart';
import 'package:rione_cassero/models/upper_event.dart';
import 'package:rione_cassero/models/user.dart' as up;
import 'package:rione_cassero/theming/colors.dart';

import '../../../logic/cubit/app/app_cubit.dart';
import '../../../routing/routes.dart';

// ignore: must_be_immutable
class EventBookScreen extends StatefulWidget {
  UpperEvent upperEvent;
  up.User loggedUser;
  Image eventImage;

  //List<up.User> allUsers = [];
  List<ParticipantDataCassero> bookData = [];

  //List<up.User> bookedUsers = [];
  //List<up.User> participantsUsers = [];

  EventBookScreen(
      {super.key, required this.upperEvent, required this.bookData, required this.loggedUser, required this.eventImage});

  //required this.bookedUsers,
  //required this.participantsUsers});

  @override
  State<EventBookScreen> createState() => _EventBookScreenState();
}

class _EventBookScreenState extends State<EventBookScreen> {
  List<ParticipantDataCassero> _totalJoinBook = [];
  List<ParticipantDataCassero> _filteredBook = [];

  //List<up.User?>? bookedUsers = [];
  //List<up.User?>? participantsUsers = [];

  final TextEditingController _searchController = TextEditingController();

  //bool _isUsersLoading = true;

  //StreamSubscription<List<up.User>?>? _presenceSubscription;
  //StreamSubscription<List<up.User>?>? _bookSubscription;

  @override
  void initState() {
    super.initState();

    _filteredBook = widget.bookData;
    _totalJoinBook = widget.bookData;

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
    List<ParticipantDataCassero> filtered = _totalJoinBook.where((book) {
      String fullName =
          '${book.name.toLowerCase()} ${book.bookUserName.toLowerCase()}';

      return fullName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredBook = filtered;
    });
  }

  int getTotalBookPeople(List<ParticipantDataCassero> list) {
    int sum = 0;
    for (var book in list) {
      //var event = UpperEvent.fromJson(doc.data());
      //print(doc.id);
      sum += book.number;
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
            "${widget.upperEvent.title} - Prenotazioni",
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
                "Prenotazioni: ${widget.bookData.length} / Persone totali: ${getTotalBookPeople(widget.bookData)}",
                style: TextStyle(color: ColorsManager.gray17),
              ),
              Expanded(
                child: _filteredBook.isEmpty
                    ? Center(child: Text('Nessuna prenotazione trovata'))
                    : ListView.builder(
                  itemCount: _filteredBook.length,
                  itemBuilder: (context, index) {
                    final user = _filteredBook[index];
                    return ListTile(
                      tileColor: ColorsManager.background,
                      textColor: Colors.black,
                      subtitleTextStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.black38,
                      ),
                      shape: RoundedRectangleBorder(
                        //<-- SEE HERE
                        side: BorderSide(
                            width: 0, color: ColorsManager.background),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      //onTap: () => _showUser(user, widget.upperEvent),
                      //leading: Icon(
                      //  Icons.person_outline,
                      //  color: user.state == 'booked'
                      //      ? Colors.orange
                      //      : user.state == 'joined'
                      //          ? Colors.green
                      //          : Colors.black,
                      //),
                      leading: Icon(
                        Icons.bookmark_border,
                        color: Colors.black,
                      ),
                      trailing: GestureDetector(
                        onTap: () => _manageBook(widget.bookData[index], index),
                        child: Text(
                          "GESTISCI",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      //trailing: GestureDetector(
                      //  child: Icon(Icons.delete, color: Colors.red),
                      //  onTap: () {},
                      //),
                      title: Text(user.number > 1 ? "${user.name} (${user.number} persone)" : "${user.name} (${user.number} persona)"),
                      subtitle: Text(
                        //'Email: ${user.email}\nData di nascita: ${user.birthdate}'),
                          'Effettuata da: ${user.bookUserName}'),
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

  Future<void> _manageBook(ParticipantDataCassero currentBookData, int index) async {
    final result = await Navigator.pushNamed(context,
      Routes.manageBookScreen,
      arguments: {
        'user': widget.loggedUser,
        'event': widget.upperEvent,
        'bookData': currentBookData,
        'image':widget.eventImage,
      },
    );

    if (result == 'edit') {
      final updated =  await context
          .read<AppCubit>()
          .getSingleBookEventCassero(
          widget.upperEvent.id!,
          currentBookData.eventUid) as ParticipantDataCassero;
      setState(() {
        widget.bookData[index] = updated;
      });
    } else if (result == 'delete'){
      setState(() {
        widget.bookData.removeAt(index);
      });
    }
  }


  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }
}
