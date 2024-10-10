import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:upper/core/widgets/app_text_form_field.dart';
import 'package:upper/core/widgets/no_internet.dart';
import 'package:upper/models/upper_event.dart';
import 'package:upper/models/user.dart' as up;

// ignore: must_be_immutable
class EventPartecipantScreen extends StatefulWidget {
  UpperEvent? upperEvent;
  List<up.User> bookedUsers = [];
  List<up.User> partecipantsUsers = [];

  EventPartecipantScreen(
      {super.key,
      required this.upperEvent,
      required this.bookedUsers,
      required this.partecipantsUsers});

  @override
  State<EventPartecipantScreen> createState() => _EventPartecipantScreenState();
}

class _EventPartecipantScreenState extends State<EventPartecipantScreen> {
  List<up.User> totalJoinEvent = [];
  List<up.User> filteredUsers = [];

  TextEditingController searchController = TextEditingController();
  bool isUsersLoading = true;

  @override
  void initState() {
    super.initState();
    totalJoinEvent = _createJoinList();
    filteredUsers = totalJoinEvent;

    isUsersLoading = false;
  }

  List<up.User> _createJoinList() {
    // Creiamo una mappa per gestire l'unione
    Map<String, up.User> userMap = {};

    // Aggiungo prima i prenotati
    for (var us in widget.bookedUsers) {
      userMap[us.uid!] = up.User(
        uid: us.uid as String,
        name: us.name as String,
        surname: us.surname as String,
        email: us.email as String,
        address: us.address as String,
        birthdate: us.birthdate as String,
        birthplace: us.birthplace as String,
        cap: us.cap as String,
        city: us.city as String,
        telephone: us.telephone as String,
        cardNumber: us.cardNumber as int,
        state: 'booked',
      );
    }

    // Poi aggiungo i partecipanti, sovrascrivendo se già esiste
    for (var us in widget.partecipantsUsers) {
      userMap[us.uid!] = up.User(
        uid: us.uid as String,
        name: us.name as String,
        surname: us.surname as String,
        email: us.email as String,
        address: us.address as String,
        birthdate: us.birthdate as String,
        birthplace: us.birthplace as String,
        cap: us.cap as String,
        city: us.city as String,
        telephone: us.telephone as String,
        cardNumber: us.cardNumber as int,
        state: 'joined', // Sovrascrive lo stato se l'utente è già presente
      );
    }

    // Converto la mappa in una lista finale
    return userMap.values.toList();
  }

  // Funzione per filtrare la lista degli utenti in base al testo inserito
  void filterUtenti(String query) {
    List<up.User> filtered = totalJoinEvent.where((utente) {
      String fullName =
          '${utente.name.toLowerCase()} ${utente.surname.toLowerCase()}';
      return fullName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUsers = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: Container(
     //  connectivityBuilder: (context, value, child) {
     //    final bool connected =
     //        value.any((element) => element != ConnectivityResult.none);
     //    return connected ? _newEventScreen(context) : const BuildNoInternet();
     //  },
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: AppTextFormField(
                    hint: "Cerca",
                    validator: (value) {},
                    controller: searchController,
                    isObscureText: false,
                    suffixIcon: Icon(
                      Icons.search,
                      color: Colors.black38,
                    ),
                    onChanged: (value) {
                      filterUtenti(value);
                    },
                  ),
                ),
              ),
              Text("Partecipanti: ${totalJoinEvent.length}"),
              Expanded(
                child: isUsersLoading
                    ? Center(child: Text('Caricamento utenti in corso...'))
                    : filteredUsers.isEmpty
                        ? Center(child: Text('Nessun utente trovato'))
                        : ListView.builder(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final utente = filteredUsers[index];
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
                                  color: utente.state == 'booked'
                                      ? Colors.orange
                                      : utente.state == 'joined'
                                          ? Colors.green
                                          : Colors.black,
                                ),
                                trailing: GestureDetector(
                                  child: Icon(Icons.delete, color: Colors.red),
                                  onTap: () {},
                                ),
                                title: Text('${utente.name} ${utente.surname}'),
                                subtitle: Text(
                                    'Email: ${utente.email}\nData di nascita: ${utente.birthdate}'),
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
    searchController.dispose();
  }
}
