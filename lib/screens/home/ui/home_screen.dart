import 'dart:async';
import 'dart:html' as html;
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:pretty_qr_code_plus/pretty_qr_code_plus.dart';
import 'package:rione_cassero/core/widgets/app_text_button.dart';
import 'package:rione_cassero/core/widgets/app_text_form_field.dart';
import 'package:rione_cassero/core/widgets/no_internet.dart';
import 'package:rione_cassero/helpers/extensions.dart';
import 'package:rione_cassero/logic/cubit/app/app_cubit.dart';
import 'package:rione_cassero/models/upper_event.dart';
import 'package:rione_cassero/models/user.dart' as up;
import 'package:rione_cassero/routing/routes.dart';
import 'package:rione_cassero/screens/home/ui/widgets/event_tile.dart';
import 'package:rione_cassero/theming/colors.dart';
import 'package:rione_cassero/theming/styles.dart';

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
  bool _isLoggedUserLoading = true;
  bool cardFilter = false;
  List<up.User> _filteredUsers = []; // Lista filtrata da visualizzare
  final TextEditingController _searchController =
      TextEditingController(); // Controller per il campo di ricerca

  late up.User _loggedUser;
  bool _isEventsLoading = true;

  bool qrTapMode = false;

  StreamSubscription<List<up.User>>? userSubscription;
  StreamSubscription<int>? cardSubscription;

  late String whatsappGroupLink =
      ""; // = "https://chat.whatsapp.com/GNCcUncHRnX3cqqfsKemoa";

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
    _loadQr();
    _loadEvents();
    //_loadWhatsappLink();
    _listenCardNumber();
  }

  void _listenCardNumber() {
    cardSubscription =
        context.read<AppCubit>().watchCardNumber().listen((cardNumber) {
      if (_loggedUser.cardNumber == 0) _loadEvents();
      _loadQr();
      setState(() {
        _loggedUser.cardNumber = cardNumber;
        //print("aggiunto utente totale ${_users.length}");
        //_filterUsers(_searchController.text);
      });
    });
  }

  bool isMobileDevice() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();
    final width = window.physicalSize.width / window.devicePixelRatio;

    // Usa user agent per la verifica primaria
    if (userAgent.contains('mobile') ||
        userAgent.contains('android') ||
        userAgent.contains('iphone')) {
      return true;
    }

    // Verifica secondaria con larghezza schermo
    return width < 600;
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    userSubscription?.cancel();
  }

  void _loadWhatsappLink() async {
    String link = await context.read<AppCubit>().getWhatsappLink();
    setState(() {
      whatsappGroupLink = link;
    });
  }

  void _loadUsers() {
    userSubscription = context.read<AppCubit>().getUsers().listen((userList) {
      setState(() {
        _users = userList;
        //print("aggiunto utente totale ${_users.length}");
        _filterUsers(_searchController.text);
      });

      if (_isUsersLoading) {
        setState(() {
          _isUsersLoading = false;
          _filteredUsers = _users;
        });
        if (kDebugMode) {
          print(
              "Caricamento iniziale completato con ${userList.length} utenti.");
        }
      }
    });

    //setState(() {
    //  _isUsersLoading = true;
    //});
    //_users = await context.read<AppCubit>().getUsers();
    //setState(() {
    //  _isUsersLoading = false;
    //  _filteredUsers = _users;
    //});
  }

  void _loadQr() async {
    var user = await context.read<AppCubit>().getUser();
    _loggedUser = user;
    setState(() {
      _qrData = user.getQrData();
      _isLoggedUserLoading = false;
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

    if (kDebugMode) {
      print(tmpEvents.length);
    }

    if (_isAdmin == false) {
      // mostro solo eventi futuri
      for (UpperEvent event in tmpEvents) {
        event.checkTodayDate();
        DateTime eDate =
            convertiStringaAData(event.date).add(Duration(days: 1));
        if (eDate.isAfter(DateTime.now()) || event.isToday!) {
          if (_loggedUser.cardNumber != 0) _events.add(event);
        }
      }
    } else _events = tmpEvents;

    if (kDebugMode) {
      print(_events.length);
    }

    //for (int i = 0; i < tmpEvents.length; i++) {
    //  print(_events[i].date);
    //}

    if (_events.length > 1) {
      _events.sort((b, a) => a.getDate().compareTo(b.getDate()));
    }

   //for (int i = 0; i < tmpEvents.length; i++) {
   //  print(_events[i].date);
   //}

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
    } else {
      for (UpperEvent event in _events) {
        event.checkTodayDate();
      }
    }

    if (kDebugMode) {
      print(_events.length);
    }

    setState(() {
      _isEventsLoading = false;
    });
  }

  List<Widget> _getTabBars() {
    var widgets = <Widget>[
      Icon(Icons.calendar_month_rounded, color: ColorsManager.gray17),
      Icon(Icons.account_circle_outlined, color: ColorsManager.gray17),
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
    //print("Events ${_events.length}");
    //print("Events ${_isAdmin}");
    //print("Events ${_users.length}");
    //print("Events ${_loggedUser.name}");

    //print(_isEventsLoading);
    //print(_isUsersLoading);
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
              textAlign: TextAlign.center,
              _loggedUser.cardNumber != 0
                  ? "Nessun evento in programma"
                  : "La tua richiesta è in fase di elaborazione, una volta ricevuto il tuo UPPER PASS potrai visualizzare i nostri eventi",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: ColorsManager.gray17),
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
      bool result = false;
      String fullName =
          '${utente.name.toLowerCase()} ${utente.surname.toLowerCase()}';
      result = fullName.contains(query.toLowerCase());
      if (cardFilter) result = result && utente.cardNumber == 0;
      return result;
    }).toList();

    setState(() {
      _filteredUsers = filtered;
    });
  }

  void _manageCardFilter() {
    if (_isUsersLoading) return;
    setState(() {
      cardFilter = !cardFilter;
    });
    _filterUsers(_searchController.text);
  }

  void _clearSearch() {
    _searchController.clear();
    _filterUsers("");
  }

  Widget _userManagementWidget() {
    return Container(
      height: MediaQuery.of(context).size.height, // Altezza massima dello schermo
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Expanded(
                child: AppTextFormField(
                  hint: "Cerca",
                  validator: (value) {},
                  controller: _searchController,
                  isObscureText: false,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black38,
                  ),
                  suffixIcon: Visibility(
                    visible: _searchController.text.length != 0,
                    child: GestureDetector(
                      onTap: _clearSearch,
                      child: Icon(
                        Icons.cancel,
                        color: Colors.black38,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _filterUsers(value);
                  },
                ),
              ),
              Gap(20.w),
              GestureDetector(
                onTap: _manageCardFilter,
                child: Icon(
                  cardFilter ? Icons.person : Icons.person_outline,
                  color: ColorsManager.gray17,
                  size: 30,
                ),
              ),
              Gap(10.w),
            ]),
          ),
          Text(
            cardFilter
                ? "Totale utenti: ${_users.length} / Da tesserare: ${_filteredUsers.length}"
                : "Totale utenti: ${_users.length}",
            style: TextStyle(color: ColorsManager.gray17, fontSize: 14),
          ),
          Expanded(
            child: _isUsersLoading
                ? Center(
                    child: Text(
                    'Caricamento utenti in corso...',
                    style: TextStyle(color: ColorsManager.gray17),
                  ))
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Text('Nessun utente trovato'),
                      )
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return ListTile(
                            tileColor: ColorsManager.gray9_01,
                            textColor: Colors.black,
                            onTap: () => _showUser(user),
                            subtitleTextStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                            shape: RoundedRectangleBorder(
                              //<-- SEE HERE
                              side: BorderSide(width: 0, color: ColorsManager.gray17_03),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            leading: Icon(
                              user.getAge() < 18
                                  ? Icons.bedroom_baby_outlined
                                  : user.isAdmin!
                                      ? Icons.settings_accessibility
                                      : user.cardNumber != 0
                                          ? Icons.person
                                          : Icons.person_outline,
                              color: user.getAge() < 18 && user.cardNumber == 0
                                  ? Colors.red
                                  : user.isAdmin!
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
    UpperEvent? todayEvent;
    for (UpperEvent event in _events) {
      event.checkTodayDate();
      if (event.isToday!) todayEvent = event;
    }

    //print(todayEvent!.title);

    await context.pushNamed(
      Routes.viewUserPage,
      arguments: {
        'user': _user,
        'event': todayEvent,
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



  Widget _profileWidget() {
    if (_isLoggedUserLoading == false) {
      if (qrTapMode == false) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          physics: ClampingScrollPhysics(), // Consente solo scroll verticale
          child: Column(
            children: [
              Text(FirebaseAuth.instance.currentUser!.displayName!,
                  style: TextStyle(fontSize: 30, color: ColorsManager.gray17)),
              SizedBox(
                height: 3,
              ),
              Text(
                "Mostra questo QR e un documento d'identità per entrare!",
                style: TextStyle(fontSize: 16, color: ColorsManager.gray17),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                    color: ColorsManager.gray17_03,
                    borderRadius: BorderRadius.circular(5)),
                child: Center(
                  child: SizedBox(
                    width: 320,
                    child: Center(
                        child: _loggedUser.cardNumber != 0
                            ? GestureDetector(
                                onTap: _toggleTapQr,
                                child: PrettyQrPlus(
                                  data: _qrData,
                                  size: 290,
                                  elementColor: Colors.black,
                                  roundEdges: false,
                                  typeNumber: null,
                                  //decoration: const PrettyQrDecoration(
                                  //  background: ColorsManager.gray17,
                                  //),
                                ),
                              )
                            : Center(
                                child: Text(
                                  "La tua richiesta è in fase di elaborazione, il tuo UPPER PASS comparirà qui",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              )),
                  ),
                ),
              ),
              Container(
                width: 320,
                child: Center(
                  child: Row(children: [
                    Text(
                      _loggedUser.uid!,
                      style: TextStyle(color: ColorsManager.gray17, fontSize: 9),
                      textAlign: TextAlign.start,
                    ),
                    Gap(10.w),
                    Visibility(
                      visible: _loggedUser.cardNumber != 0,
                      child: Expanded(
                        child: Text(
                          _loggedUser.cardNumber.toString(),
                          style: TextStyle(color: ColorsManager.gray17, fontSize: 9),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              Gap(20.h),
              Visibility(
                visible: whatsappGroupLink != "" &&
                    isMobileDevice() &&
                    _loggedUser.cardNumber != 0,
                child: GestureDetector(
                  onTap: _redirectWhatsapp,
                  child: Container(
                    width: 320,
                    height: 60,
                    padding: const EdgeInsets.only(
                        right: 8.0, left: 8.0, bottom: 2.0, top: 2.0),
                    decoration: BoxDecoration(
                        color: ColorsManager.gray17,
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      children: [
                        //Icon(Icons.message),
                        Image(image: AssetImage("assets/images/whatsapp.gif")),
                        Gap(15.w),
                        Text("Unisciti al gruppo Whatsapp",
                            style: TextStyle(fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                ),
              ),
              Gap(30.h),
              Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: AppTextButton(
                  buttonText: 'Logout',
                  textStyle: TextStyles.font16Black600Weight,
                  buttonWidth: 100,
                  buttonHeight: 50,
                  onPressed: () {
                    context.read<AppCubit>().signOut();
                    context.pushNamed(Routes.loginScreen);
                  },
                ),
              )
            ],
          ),
        );
      } else {
        return Container(
          color: ColorsManager.gray17,
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
                //  background: ColorsManager.gray17,
                //),
              ),
            ),
          ),
        );
      }
    } else {
      return Center(
        child: Image(image: AssetImage("assets/images/loading.gif")),
      );
    }
  }

  void _redirectWhatsapp() {
    html.window.open(whatsappGroupLink!, "_blank");
  }

  SafeArea _homePage(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        initialIndex: widget.tab_index ?? 1,
        length: _isAdmin ? 3 : 2,
        child: Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: ColorsManager.background,
            title: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              //child: Center(child: Container(width: 300, height: 100, child: Image(image: AssetImage("assets/images/upper_2.png"),fit: BoxFit.scaleDown,))),
              child: Center(
                child: Text(
                  "RIONE CASSERO",
                  style: TextStyle(color: ColorsManager.gray17, fontSize: 25),
                ),
              ),
            ),
            bottom: TabBar(
              tabs: _getTabBars(),
              indicatorColor: ColorsManager.gray17,
              padding: EdgeInsets.only(bottom: 10),
            ),
          ),
          body: Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: TabBarView(children: _tabBarViewWidgets())),
        ),
      ),
    );
  }

  void _toggleTapQr() {
    setState(() {
      if (isMobileDevice()) qrTapMode = !qrTapMode;
    });
  }
}
