import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:pretty_qr_code_plus/pretty_qr_code_plus.dart';
import 'package:upper/core/widgets/app_text_button.dart';
import 'package:upper/core/widgets/app_text_form_field.dart';
import 'package:upper/core/widgets/no_internet.dart';
import 'package:upper/helpers/extensions.dart';
import 'package:upper/logic/cubit/app/app_cubit.dart';
import 'package:upper/models/upper_event.dart';
import 'package:upper/models/user.dart' as up;
import 'package:upper/routing/routes.dart';
import 'package:upper/screens/home/ui/widgets/event_tile.dart';
import 'package:upper/theming/colors.dart';
import 'package:upper/theming/styles.dart';

class HomeScreen extends StatefulWidget {
  int? tab_index;

  HomeScreen({super.key, this.tab_index});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _qrData = "";
  late bool _isAdmin = false;
  List<UpperEvent> _events = [];
  List<up.User> _users = [];
  bool _isUsersLoading = true;
  List<up.User> _filteredUsers = []; // Lista filtrata da visualizzare
  final TextEditingController _searchController =
      TextEditingController(); // Controller per il campo di ricerca

  late up.User _loggedUser;
  bool _isEventsLoading = true;

  bool qrTapMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OfflineBuilder(
        connectivityBuilder: (context, value, child) {
          final bool connected =
              value.any((element) => element != ConnectivityResult.none);
          return connected ? _homePage(context) : const BuildNoInternet();
        },
        child: const Center(
          child: CircularProgressIndicator(
            color: ColorsManager.mainBlue,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AppCubit>(context);
    _loadUserLevel();
    _loadEvents();
    _loadQr();
  }

  void _loadUsers() async {
    setState(() {
      _isUsersLoading = true;
    });
    _users = await context.read<AppCubit>().getUsers();
    setState(() {
      _isUsersLoading = false;
      _filteredUsers = _users;
    });
  }

  void _loadQr() async {
    var user = await context.read<AppCubit>().getUser();
    _loggedUser = user;
    setState(() {
      _qrData = user.getQrData();
    });
  }

  void _loadUserLevel() async {
    var level = await context.read<AppCubit>().getUserLevel();
    setState(() {
      _isAdmin = level == "admin";
    });
    if (_isAdmin)
      _loadUsers();
    else
      setState(() {
        _isUsersLoading = false;
      });
  }

  // Funzione per convertire una stringa dd/mm/yyyy in DateTime
  DateTime convertiStringaAData(String dataString) {
    List<String> partiData =
        dataString.split('/'); // Divide la stringa in giorno, mese e anno
    int giorno = int.parse(partiData[0]); // Prende il giorno
    int mese = int.parse(partiData[1]); // Prende il mese
    int anno = int.parse(partiData[2]); // Prende l'anno

    return DateTime(anno, mese, giorno); // Crea un oggetto DateTime
  }

  void _loadEvents() async {
    setState(() {
      _isEventsLoading = true;
    });
    var tmpEvents = await context.read<AppCubit>().getUpperEvents();

    print(tmpEvents.length);

    if (_isAdmin == false) {
      // mostro solo eventi futuri
      for (UpperEvent event in tmpEvents) {
        event.checkTodayDate();
        DateTime eDate =
            convertiStringaAData(event.date).add(Duration(days: 1));
        if (eDate.isAfter(DateTime.now()) || event.isToday!) {
          _events.add(event);
        }
      }
    } else
      _events = tmpEvents;

    print(_events.length);

    if (_events.length > 1) {
      _events.sort((a, b) => a.getDate().compareTo(b.getDate()));
    }

    // se un evento ha la da di oggi lo metto in prima fila
    if (_events.length > 1) {
      for (UpperEvent event in _events) {
        event.checkTodayDate();
        if (event.isToday!) {
          int index_today = _events.indexOf(event);
          UpperEvent temp = _events[0];
          _events[0] = _events[index_today];
          _events[index_today] = temp;
        }
      }
    }

    print(_events.length);

    setState(() {
      _isEventsLoading = false;
    });
  }

  List<Widget> _getTabBars() {
    var widgets = <Widget>[
      Icon(Icons.calendar_month_rounded, color: Colors.white),
      Icon(Icons.account_circle_outlined, color: Colors.white),
    ];

    if (_isAdmin) {
      widgets.add(Icon(Icons.verified_user_outlined, color: Colors.orange));
    }
    return widgets;
  }

  List<Widget> _tabBarViewWidgets() {
    var widgets = <Widget>[_eventsWidget(), _profileWidget()];
    if (_isAdmin) widgets.add(_userManagementWidget());
    return widgets;
  }

  Widget _eventsWidget() {
    print(_isEventsLoading);
    print(_isUsersLoading);
    if (!_isEventsLoading && !_isUsersLoading) {
      //if (_events.isNotEmpty) {
      return Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Visibility(
            visible: _events.isNotEmpty,
            child: Expanded(
              child: EventTile(
                  upperEvents: _events,
                  isAdmin: _isAdmin,
                  allUsers: _users,
                  loggedUser: _loggedUser),
            ),
          ),
          Visibility(
            visible: _events.isEmpty,
            child: Expanded(
                child: Center(
                    child: Text(
              "Nessun evento in programma",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white),
            ))),
          ),
//           Visibility(
//             visible: _isAdmin ,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 GestureDetector(
//                   child: Padding(
//                     padding: const EdgeInsets.only(bottom: 20, right: 20),
//                     child: Icon(Icons.add, size: 30, color: Colors.orange,),
//                   ),
//                   onTap: () async {
//                     await context.pushNamed(Routes.newEventScreen,
//                         arguments: null);
//                     setState(() {});
//                   },
//                 )
//                ],
//              ),
//            ),
        ],
      );
    } else {
      return Center(
        child: Image(image: AssetImage("assets/images/loading.gif")),
      );
    }
  }

// Funzione per filtrare la lista degli utenti in base al testo inserito
  void _filterUsers(String query) {
    List<up.User> filtered = _users.where((utente) {
      String fullName =
          '${utente.name.toLowerCase()} ${utente.surname.toLowerCase()}';
      return fullName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredUsers = filtered;
    });
  }

  Widget _userManagementWidget() {
    return Container(
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
                  _filterUsers(value);
                },
              ),
            ),
          ),
          Expanded(
            child: _isUsersLoading
                ? Center(child: Text('Caricamento utenti in corso...'))
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Text('Nessun utente trovato'),
                      )
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return ListTile(
                            tileColor: Colors.white,
                            textColor: Colors.black,
                            onTap: () => _showUser(user),
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
                              user.isAdmin!
                                  ? Icons.settings_accessibility
                                  : user.cardNumber != 0
                                      ? Icons.person_pin
                                      : Icons.person_outline,
                              color: user.isAdmin!
                                  ? Colors.orange
                                  : user.cardNumber != 0
                                      ? Colors.green
                                      : Colors.black,
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (String result) {
                                switch (result) {
                                  case 'show_user':
                                    _showUser(user);
                                    break;
                                  case 'reimposta_password':
                                    _resetPassword(user);
                                    break;
                                  case 'rendi_amministratore':
                                    _userToAdmin(user);
                                    break;
                                  case 'elimina_account':
                                    _deleteAccount(user);
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'show_user',
                                  child: Text('Visualizza'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'reimposta_password',
                                  child: Text('Reimposta password'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'rendi_amministratore',
                                  child: user.isAdmin!
                                      ? Text('Rendi utente')
                                      : Text('Rendi amministratore'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'elimina_account',
                                  child: Text('Elimina account'),
                                ),
                              ],
                            ),
                            title: Text('${user.name} ${user.surname}'),
                            subtitle: Text(
                                'Email: ${user.email}\nData di nascita: ${user.birthdate}'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _resetPassword(up.User _user) async {
    await context.read<AppCubit>().resetPassword(_user.email);
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

  void _userToAdmin(up.User _user) async {
    if (!_user.isAdmin!) {
      await context.read<AppCubit>().setUserLevel(_user, "admin");
      _user.isAdmin = true;
    } else {
      await context.read<AppCubit>().setUserLevel(_user, "user");
      _user.isAdmin = false;
    }

    setState(() {
      // giusto per aggiornare la lista
      _isUsersLoading = false;
    });
  }

  void _deleteAccount(up.User _user) async {
    // questa funzione deve cancellare un account

    setState(() {
      // giusto per aggiornare la lista
      _isUsersLoading = false;
    });
  }

  Widget _profileWidget() {
    if (qrTapMode == false) {
      return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(FirebaseAuth.instance.currentUser!.displayName!,
                style: TextStyle(fontSize: 30, color: Colors.white)),
            SizedBox(
              height: 10,
            ),
            Text(
              "Mostra questo QR per entrare!",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: _toggleTapQr,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child: Center(
                  child: SizedBox(
                    width: 300,
                    child: Center(
                      child: StreamBuilder(
                        stream: context.read<AppCubit>().watchCardNumber(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Errore: ${snapshot.error}');
                          }

                          bool isCardNumberNonZero = snapshot.data ?? false;
                          if (isCardNumberNonZero) {
                            return PrettyQrPlus(
                              data: _qrData,
                              size: 290,
                              elementColor: Colors.black,
                              roundEdges: false,
                              typeNumber: null,
                              //decoration: const PrettyQrDecoration(
                              //  background: Colors.white,
                              //),
                            );
                          } else {
                            return Text(
                              "Riceverai una tessera molto presto",
                              style: TextStyle(fontSize: 20),
                            );
                          }

                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Gap(30.h),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: AppTextButton(
                  buttonText: 'Logout',
                  textStyle: TextStyles.font14White400Weight,
                  buttonWidth: 100,
                  buttonHeight: 50,
                  onPressed: () {
                    context.read<AppCubit>().signOut();
                    context.pushNamed(Routes.loginScreen);
                  },
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Container(
        color: Colors.white,
        child: Center(
          child: GestureDetector(
            onTap: _toggleTapQr,
            child: PrettyQrPlus(
              data: _qrData,
              size: MediaQuery.of(context).size.width - 10,
              elementColor: Colors.black,
              roundEdges: false,
              typeNumber: null,
              //decoration: const PrettyQrDecoration(
              //  background: Colors.white,
              //),
            ),
          ),
        ),
      );
    }
  }

  SafeArea _homePage(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        initialIndex: widget.tab_index ?? 1,
        length: _isAdmin ? 3 : 2,
        child: Scaffold(
          backgroundColor: Color.fromRGBO(17, 17, 17, 1),
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(17, 17, 17, 1),
            title: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              //child: Center(child: Container(width: 300, height: 100, child: Image(image: AssetImage("assets/images/upper_2.png"),fit: BoxFit.scaleDown,))),
              child: Center(
                child: Text(
                  "UPPER",
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            bottom: TabBar(
              tabs: _getTabBars(),
              indicatorColor: Colors.white,
              padding: EdgeInsets.only(bottom: 10),
            ),
          ),
          body: TabBarView(children: _tabBarViewWidgets()),
        ),
      ),
    );
  }

  void _toggleTapQr() {
    setState(() {
      qrTapMode = !qrTapMode;
    });
  }
}
