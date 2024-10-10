import 'package:flutter/material.dart';
import 'package:upper/core/widgets/app_text_form_field.dart';
import 'package:upper/models/upper_event.dart';
import 'package:upper/models/user.dart' as up;

// ignore: must_be_immutable
class EventParticipantScreen extends StatefulWidget {
  UpperEvent? upperEvent;
  List<up.User> bookedUsers = [];
  List<up.User> participantsUsers = [];

  EventParticipantScreen({super.key, required this.upperEvent, required this.bookedUsers, required this.participantsUsers});

  @override
  State<EventParticipantScreen> createState() => _EventParticipantScreenState();
}

class _EventParticipantScreenState extends State<EventParticipantScreen> {
  List<up.User> _totalJoinEvent = [];
  List<up.User> _filteredUsers = [];

  final TextEditingController _searchController = TextEditingController();
  bool _isUsersLoading = true;

  @override
  void initState() {
    super.initState();
    _totalJoinEvent = _createJoinList();
    _filteredUsers = _totalJoinEvent;

    print(_totalJoinEvent.length);
    print(_filteredUsers.length);

    _isUsersLoading = false;
  }

  List<up.User> _createJoinList() {
    // Creiamo una mappa per gestire l'unione
    Map<String, up.User> userMap = {};
    print(widget.bookedUsers.length);
    // Aggiungo prima i prenotati
    for (var us in widget.bookedUsers) {
      //userMap[us.uid!]?.state = 'booked';
      userMap[us.uid!] = us.copyWith(state: 'booked');
    }

    // Poi aggiungo i partecipanti, sovrascrivendo se già esiste
    for (var us in widget.participantsUsers) {
      userMap[us.uid!] = us.copyWith(state: 'joined');
     // userMap[us.uid!]?.state = 'joined';
    }

    print( "user map ${userMap.length}");

    // Converto la mappa in una lista finale
    return userMap.values.toList();
  }

  // Funzione per filtrare la lista degli utenti in base al testo inserito
  void filterUsers(String query) {
    List<up.User> filtered = _totalJoinEvent.where((utente) {
      String fullName = '${utente.name.toLowerCase()} ${utente.surname.toLowerCase()}';
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
          title: const Text("Ingressi"),
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
              Text("Partecipanti: ${_totalJoinEvent.length}", style: TextStyle(color: Colors.white),),
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
                                leading: Icon(
                                  Icons.person_outline,
                                  color: user.state == 'booked'
                                      ? Colors.orange
                                      : user.state == 'joined'
                                          ? Colors.green
                                          : Colors.black,
                                ),
                                trailing: GestureDetector(
                                  child: Icon(Icons.delete, color: Colors.red),
                                  onTap: () {},
                                ),
                                title: Text('${user.name} ${user.surname}'),
                                subtitle: Text('Email: ${user.email}\nData di nascita: ${user.birthdate}'),
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

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }
}
