import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upper/core/widgets/app_text_form_field.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/models/upper_event.dart';
import 'package:upper/models/user.dart' as up;

import 'package:upper/logic/cubit/app/app_cubit.dart';

import '../../../routing/routes.dart';

// ignore: must_be_immutable
class EventParticipantScreen extends StatefulWidget {
  UpperEvent upperEvent;
  List<up.User> allUsers = [];

  //List<up.User> bookedUsers = [];
  //List<up.User> participantsUsers = [];

  EventParticipantScreen(
      {super.key, required this.upperEvent, required this.allUsers});

  //required this.bookedUsers,
  //required this.participantsUsers});

  @override
  State<EventParticipantScreen> createState() => _EventParticipantScreenState();
}

class _EventParticipantScreenState extends State<EventParticipantScreen> {
  List<up.User> _totalJoinEvent = [];
  List<up.User> _filteredUsers = [];

 List<up.User?>? bookedUsers = [];
 List<up.User?>? participantsUsers = [];

  final TextEditingController _searchController = TextEditingController();
  bool _isUsersLoading = true;

  StreamSubscription<List<up.User>?>? _presenceSubscription;
  StreamSubscription<List<up.User>?>? _bookSubscription;

  @override
  void initState() {
    super.initState();

    _loadEventSubscription();

    //Future.delayed(Duration(seconds: 3));




    if (kDebugMode) {
      print(_totalJoinEvent.length);
      print(_filteredUsers.length);
    }

    _isUsersLoading = false;
  }

  void _loadEventSubscription() {
    _presenceSubscription = context
        .read<AppCubit>()
        .getEventsParticipantStream(widget.upperEvent.id!, widget.allUsers)
        .listen((snapshot) {
      setState(() {
        participantsUsers = snapshot;
        _totalJoinEvent = _createJoinList();
        _filteredUsers = _totalJoinEvent;
      });
    });

    _bookSubscription = context
        .read<AppCubit>()
        .getEventsBookStream(widget.upperEvent.id!, widget.allUsers)
        .listen((snapshot) {
      setState(() {
        bookedUsers = snapshot;
        _totalJoinEvent = _createJoinList();
        _filteredUsers = _totalJoinEvent;
      });
    });
  }

  List<up.User> _createJoinList() {
    // Creiamo una mappa per gestire l'unione
    Map<String, up.User> userMap = {};
    if (kDebugMode) print(bookedUsers!.length);
    // Aggiungo prima i prenotati
    for (var us in bookedUsers!) {
      //userMap[us.uid!]?.state = 'booked';
      userMap[us!.uid!] = us.copyWith(state: 'booked');
    }

    // Poi aggiungo i partecipanti, sovrascrivendo se già esiste
    for (var us in participantsUsers!) {
      userMap[us!.uid!] = us.copyWith(state: 'joined');
      // userMap[us.uid!]?.state = 'joined';
    }

    if (kDebugMode) print("user map ${userMap.length}");

    // Converto la mappa in una lista finale
    return userMap.values.toList();
  }

  // Funzione per filtrare la lista degli utenti in base al testo inserito
  void filterUsers(String query) {
    List<up.User> filtered = _totalJoinEvent.where((utente) {
      String fullName =
          '${utente.name.toLowerCase()} ${utente.surname.toLowerCase()}';
      return fullName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredUsers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromRGBO(17, 17, 17, 1),
        appBar: AppBar(
          title: Text(
            "${widget.upperEvent.title} - Ingressi",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          foregroundColor: Colors.white,
          backgroundColor: Color.fromRGBO(17, 17, 17, 1),
          titleTextStyle: TextStyle(color: Colors.white),
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
                "Prenotati: ${bookedUsers!.length} / Ingressi: ${participantsUsers!.length}",
                style: TextStyle(color: Colors.white),
              ),
              Expanded(
                child: _isUsersLoading
                    ? Center(child: Text('Caricamento utenti in corso...'))
                    : _filteredUsers.isEmpty
                        ? Center(child: Text('Nessun utente trovato'))
                        : ListView.builder(
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return ListTile(
                                tileColor: Colors.white,
                                textColor: Colors.black,
                                subtitleTextStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black38,
                                ),
                                shape: RoundedRectangleBorder(
                                  //<-- SEE HERE
                                  side: BorderSide(width: 2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                onTap: () => _showUser(user),
                                leading: Icon(
                                  Icons.person_outline,
                                  color: user.state == 'booked'
                                      ? Colors.orange
                                      : user.state == 'joined'
                                          ? Colors.green
                                          : Colors.black,
                                ),

                                //trailing: GestureDetector(
                                //  child: Icon(Icons.delete, color: Colors.red),
                                //  onTap: () {},
                                //),
                                title: Text('${user.name} ${user.surname}'),
                                subtitle: Text(
                                    'Email: ${user.email}\nData di nascita: ${user.birthdate}'),
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

  void _showUser(up.User _user) async {
    await context.pushNamed(
      Routes.viewUserPage,
      arguments: {
        'user': _user,
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
