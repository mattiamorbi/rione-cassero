import 'dart:async';
import 'dart:html' as html;
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rione_cassero/core/widgets/app_text_button.dart';
import 'package:rione_cassero/core/widgets/app_text_form_field.dart';
import 'package:rione_cassero/core/widgets/no_internet.dart';
import 'package:rione_cassero/helpers/extensions.dart';
import 'package:rione_cassero/logic/cubit/app/app_cubit.dart';
import 'package:rione_cassero/models/upper_event.dart';
import 'package:rione_cassero/models/user.dart' as up;
import 'package:rione_cassero/routing/routes.dart';
import 'package:rione_cassero/theming/colors.dart';
import 'package:rione_cassero/theming/styles.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

import '../../../models/participant_data.dart';

class HomeScreen extends StatefulWidget {
  int? tab_index;

  HomeScreen({super.key, this.tab_index});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  //late String _qrData = "";
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

  List<UpperEvent> myEventBooks = [];

  late String whatsappGroupLink =
      ""; // = "https://chat.whatsapp.com/GNCcUncHRnX3cqqfsKemoa";

  // from EventTile file
  final List<Image> _image = [];
  up.User? _user;
  int _editBookNameMode = 0;
  String bookName = "";
  int bookNumber = 1;
  int childBookNumber = 0;
  //List<UpperEvent> data = [];
  int _focusedIndex = 0;
  GlobalKey<ScrollSnapListState> sslKey = GlobalKey();
  List<List<ParticipantDataCassero>> _currentEventBookData = [];
  bool _loading = true;
  StreamSubscription<List<BookPermission>>? _bookPermission;
  List<StreamSubscription<List<ParticipantDataCassero>>?>
      _eventBookSubscription = [];
  late List<int> totalBookedPlaces = [];
  final TextEditingController _bookEventController = TextEditingController();
  final TextEditingController _allergyNoteController = TextEditingController();
  bool allergy = false;
  bool _isEventDetailVisible = true;

  late TabController _tabController;

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

    // Imposta l'indice iniziale della TabBar (es. 1 per la seconda tab)
    _tabController = TabController(length: 3, initialIndex: 1, vsync: this);
    //_loadQr();

    //_loadWhatsappLink();
    //_listenCardNumber();

    for (int i = 0; i < 10; i++) {
      // dummy number
      _image.add(Image(image: AssetImage("assets/images/loading.gif")));
      //print("image loading");
      //_image[0].image.toString();
    }

    //_loadLoggedUser();
  }

  List<UpperEvent> getMyEventBooks() {
    List<UpperEvent> myBooks = [];
    for (int i = 0; i < _events.length; i++) {
      if (_currentEventBookData[i].length > 0) {
        myBooks.add(_events[i]);
        myBooks.last.sumUpMyBookChildren = 0;
        myBooks.last.sumUpMyBookPerson = 0;
        for (int y = 0; y < _currentEventBookData[i].length; y++) {
          if (_loggedUser.uid == _currentEventBookData[i].elementAt(y).uid) {
            myBooks.last.sumUpMyBookPerson +=
                _currentEventBookData[i].elementAt(y).number;
            myBooks.last.sumUpMyBookChildren +=
                _currentEventBookData[i].elementAt(y).childrenNumber;
          }
        }
        print("sono prenotato a ${_events[i].id}");
      }
    }

    for (int i = 0; i < myBooks.length; i++) {
      if (myBooks[i].sumUpMyBookChildren == 0 &&
          myBooks[i].sumUpMyBookPerson == 0) {
        myBooks.removeAt(i);
      }
    }

    return myBooks;
  }

  Future<void> _loadEventsSubscription() async {
    setState(() {
      _loading = true;
      //_qrMode = 0;
    });

    //totalBookedPlaces = 0;

    // Inizializza _currentEventBookData come una lista di liste vuote
    _currentEventBookData = List.generate(_events.length, (_) => []);
    totalBookedPlaces = List.generate(_events.length, (_) => 0);

    for (int i = 0; i < _events.length; i++) {
      print(_isAdmin);
      // Ottieni lo stream per ogni evento
      final stream = context.read<AppCubit>().getBookEventCasseroStream(
          _events[i].id!, _loggedUser.uid!, _isAdmin);

      // Ascolta lo stream e gestisci i dati
      //final subscription = stream.listen((snapshot) {
      //  setState(() {
      //    totalBookedPlaces[i] = 0;
      //
      //    // Aggiorna i dati per l'amministratore o l'utente normale
      //    _currentEventBookData[i].clear();
      //    for (var item in snapshot) {
      //      if (_isAdmin || item.uid == _loggedUser.uid) {
      //        _currentEventBookData[i].add(item);
      //      }
      //      totalBookedPlaces[i] += item.number;
      //    }
      //  });
      //});

      // Ascolta lo stream e gestisci i dati
      final subscription = stream.listen((snapshot) {
        setState(() {
          totalBookedPlaces[i] = 0;

          // Aggiorna i dati per l'amministratore o l'utente normale
          _currentEventBookData[i].clear();
          for (var item in snapshot) {
            _currentEventBookData[i].add(item);

            if (_isAdmin)
              totalBookedPlaces[i] += (item.number + item.childrenNumber);

            print("ho eseguito l'aggioranmento");

            setState(() {
              myEventBooks.clear();
              myEventBooks = getMyEventBooks();
            });
          }
        });
      });

      // Aggiungi la subscription alla lista
      _eventBookSubscription.add(subscription);
    }

    final permissionStream =
        context.read<AppCubit>().getBookPermissionCasseroStream();
    _bookPermission = permissionStream.listen((snapshot) {
      for (int i = 0; i < snapshot.length; i++) {
        for (int y = 0; y < _events.length; y++) {
          if (snapshot[i].eventID == _events[y].id) {
            _events[y].bookable = snapshot[i].bookable;
          }
        }
      }

      setState(() {});
    });

    setState(() {
      _loading = false;
      //_qrMode = 0;
    });
  }

  void _toggleBookMode(int index) async {
    await Navigator.pushNamed(
      context,
      Routes.manageBookScreen,
      arguments: {
        'user': _loggedUser,
        'event': _events[index],
        'bookData': ParticipantDataCassero(
            name: "${_loggedUser.name} ${_loggedUser.surname}",
            number: 1,
            childrenNumber: 0,
            eventUid: _events[index].id!,
            bookUserName: "${_loggedUser.name} ${_loggedUser.surname}"),
        'image': _image[index],
        'isNewBook': true,
      },
    );
  }

  void _errorBookMode(int index) async {
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.topSlide,
      title: 'Prenotazioni chiuse',
      desc: "Chiedi informazioni agli organizzatori dell'evento",
    ).show();
  }

  void _editBookName() {
    if (_editBookNameMode == 1) {
      setState(() {
        _editBookNameMode = 0;
        bookName = _bookEventController.text;
      });
    } else {
      setState(() {
        _editBookNameMode = 1;
        _bookEventController.text = bookName;
      });
    }
  }

  Widget _buildItemDetail(int index) {
    if (_events.length > index) {
      var currentEvent = _events[index];
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            currentEvent.title,
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: ColorsManager.gray17),
          ),
          Text(
            "${currentEvent.date} - ${currentEvent.time}",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColorsManager.gray17),
          ),
          Text(
            currentEvent.place,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColorsManager.gray17),
          ),
          Gap(10.h),
          _currentEventBookData[index].isNotEmpty &&
                  index < _currentEventBookData.length &&
                  _loading == false
              ? Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "PRENOTATO x${getTotalBookPeople(_currentEventBookData[index])}",
                    style: TextStyle(
                        color: ColorsManager.gray17,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : SizedBox.shrink(),
          currentEvent.bookingLimit != null
              ? Visibility(
                  visible: currentEvent.bookingLimit != null &&
                      currentEvent.bookingLimit! > 0 &&
                      _isAdmin,
                  child: Text(
                    "Posti rimanenti ${currentEvent.bookingLimit! - totalBookedPlaces[index]}",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                )
              : SizedBox.shrink(),
          SizedBox(
            height: 5,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  visible: _events[index].bookable == true,
                  child: GestureDetector(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add_alt_1,
                            color: ColorsManager.gray17,
                          ),
                          Gap(5.w),
                          Text(
                            "Aggiungi prenotazione",
                            style: TextStyle(
                                color: ColorsManager.gray17, fontSize: 18),
                          )
                        ]),
                    onTap: () => _toggleBookMode(
                        index), //_toggleBookEvent(_focusedIndex),
                  ),
                ),
                Visibility(
                  visible: _events[index].bookable == false,
                  child: GestureDetector(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add_disabled_rounded,
                            color: ColorsManager.gray17,
                          ),
                          Gap(5.w),
                          Text(
                            "Prenotazioni bloccate",
                            style: TextStyle(
                                color: ColorsManager.gray17, fontSize: 18),
                          )
                        ]),
                    onTap: () => _errorBookMode(
                        index), //_toggleBookEvent(_focusedIndex),
                  ),
                ),
                Gap(10.h),
                GestureDetector(
                  child: Visibility(
                    visible: _currentEventBookData[index].isNotEmpty,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.settings,
                            color: ColorsManager.gray17,
                          ),
                          Gap(5.w),
                          Text(
                            "Gestisci prenotazione",
                            style: TextStyle(
                                color: ColorsManager.gray17, fontSize: 18),
                          )
                        ]),
                  ),
                  onTap: () async {
                    if (_currentEventBookData[index].isNotEmpty) {
                      await context.pushNamed(
                        Routes.viewBookScreen,
                        arguments: {
                          'event': _events[index],
                          'bookData': _currentEventBookData[index],
                          'user': _loggedUser,
                          'image': _image[index],
                          'isMoneyScreen': false,
                          //'bookedUsers': _bookedUsers,
                          //'participantsUsers': _participantUsers,
                        },
                      );
                      setState(() {
                        myEventBooks = getMyEventBooks();
                      });
                    }
                  },
                ),
                Visibility(
                  visible: _isAdmin,
                  child: SizedBox(
                    width: 20,
                  ),
                ),
                Visibility(
                  visible: _isAdmin & !_loading,
                  child: GestureDetector(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.orange,
                          ),
                          Gap(5.w),
                          Text(
                            "Modifica evento",
                            style:
                                TextStyle(color: Colors.orange, fontSize: 18),
                          )
                        ]),
                    onTap: () => _editEvent(index),
                  ),
                ),
                Visibility(
                  visible: _isAdmin,
                  child: SizedBox(
                    width: 20,
                  ),
                ),
                Visibility(
                  visible: _isAdmin &
                      !_loading &
                      (currentEvent.isToday! ||
                          (_loggedUser.name == 'Mattia' &&
                              _loggedUser.surname == 'Morbidelli')),
                  child: GestureDetector(
                    onTap: () async {
                      if (_currentEventBookData[index].isNotEmpty) {
                        await context.pushNamed(
                          Routes.viewBookScreen,
                          arguments: {
                            'event': _events[index],
                            'bookData': _currentEventBookData[index],
                            'user': _loggedUser,
                            'image': _image[index],
                            'isMoneyScreen': true,
                            //'bookedUsers': _bookedUsers,
                            //'participantsUsers': _participantUsers,
                          },
                        );
                      }
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            color: Colors.orange,
                          ),
                          Gap(5.w),
                          Text(
                            "Gestisci ingresso",
                            style:
                                TextStyle(color: Colors.orange, fontSize: 18),
                          )
                        ]),
                  ),
                ),
                Visibility(
                  visible: _isAdmin &
                      !_loading &
                      (currentEvent.isToday! ||
                          (_loggedUser.name == 'Mattia' &&
                              _loggedUser.surname == 'Morbidelli')),
                  child: SizedBox(
                    width: 20,
                  ),
                ),
                //Visibility(
                //  visible: _isAdmin & !_loading,
                //  child: GestureDetector(
                //    onTap: () => _viewParticipants(index),
                //    child: Icon(
                //      Icons.menu,
                //      color: Colors.orange,
                //    ),
                //  ),
                //),
                //Visibility(
                //  visible: _isAdmin,
                //  child: SizedBox(
                //    width: 20,
                //  ),
                //),
                Visibility(
                  visible: _isAdmin & !_loading,
                  child: GestureDetector(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.orange,
                          ),
                          Gap(5.w),
                          Text(
                            "Aggiungi evento",
                            style:
                                TextStyle(color: Colors.orange, fontSize: 18),
                          )
                        ]),
                    onTap: () async {
                      await context.pushNamed(Routes.newEventScreen,
                          arguments: null);
                      setState(() {
                        _loadUserLevel();

                      });
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      );
    } else {
      return SizedBox(
        width: 350,
        height: 350,
      );
    }
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

  Widget _buildListItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () async => {},
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        width: isMobileDevice() ? window.display.size.width - 30 : 400,
        height: isMobileDevice() ? window.display.size.width - 30 : 400,
        child: InkWell(
          onTap: () async {
            sslKey.currentState!.focusToItem(index);
            if (_currentEventBookData.isNotEmpty) {
              await context.pushNamed(
                Routes.viewBookScreen,
                arguments: {
                  'event': _events[index],
                  'bookData': _currentEventBookData,
                  'user': _loggedUser,
                  'image': _image[_focusedIndex],
                  //'bookedUsers': _bookedUsers,
                  //'participantsUsers': _participantUsers,
                },
              );
            }
          },
          child: Stack(children: [
            Center(child: Image(image: _image[index].image)),
            index < _currentEventBookData.length &&
                    index == _focusedIndex &&
                    _loading == false
                ? Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "PRENOTATO x${getTotalBookPeople(_currentEventBookData[index])}",
                      style: TextStyle(
                          color: ColorsManager.gray17,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : SizedBox.shrink(),
          ]),
        ),
      ),
    );
  }

  Future<void> _loadImage(int index) async {
    //print("load image future");
    try {
      final imageData = await _events[index].getEventImage();
      if (imageData != null) {
        setState(() {
          if (index < _image.length) {
            _image[index] = Image.memory(imageData);
          } else {
            _image.add(Image.memory(imageData));
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading image: $e');
      }
    }

    //if (index == _events.length - 1) {
    //  setState(() {
    //    _imageLoading = false;
    //  });
    //}
  }

  Future<void> _editEvent(int index) async {
    await context.pushNamed(Routes.editEventScreen, arguments: _events[index]);
    setState(() {});
  }

  Future<void> _viewParticipants(int index) async {
    context.pushNamed(
      Routes.viewParticipantsScreen,
      arguments: {
        'upperEvent': _events[index],
        'allUsers': _users,
        //'bookedUsers': _bookedUsers,
        //'participantsUsers': _participantUsers,
      },
    );
  }

  int getTotalBookPeople(List<ParticipantDataCassero> list) {
    int sum = 0;
    for (var book in list) {
      //var event = UpperEvent.fromJson(doc.data());
      //print(doc.id);
      sum += book.number + book.childrenNumber;
    }
    return sum;
  }

  Widget LocalEventTile() {
    return PageView.builder(
      controller: PageController(viewportFraction: 0.8),
      // Mostra l'80% di una card
      itemCount: _events.length,
      itemBuilder: (context, index) {
        return Container(
          height: 500,
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: GestureDetector(
            onDoubleTap: () {
              setState(() {
                _isEventDetailVisible =
                    !_isEventDetailVisible; // Nasconde il pannello quando si preme
              });
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: _image[index].image,
                    fit: _image[index].image.toString().contains("loading.gif")
                        ? BoxFit.contain
                        : BoxFit.cover,
                  ),
                ),
                child: Visibility(
                  visible: _isEventDetailVisible,
                  child: Stack(
                    children: [
                      Center(
                        child: Visibility(
                          visible: !_image[index]
                              .image
                              .toString()
                              .contains("loading.gif"),
                          child: Container(
                            width: 300,
                            height: _isAdmin ? 300 : 230,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              // Bianco semi-trasparente
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: _buildItemDetail(index),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _listenCardNumber() {
    cardSubscription =
        context.read<AppCubit>().watchCardNumber().listen((cardNumber) {
      //if (_loggedUser.cardNumber == 0) _loadEvents();
      //_loadQr();
      setState(() {
        _loggedUser.cardNumber = cardNumber;
        //print("aggiunto utente totale ${_users.length}");
        //_filterUsers(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    userSubscription?.cancel();
    _allergyNoteController.dispose();
    _bookEventController.dispose();
    for (int i = 0; i < _eventBookSubscription.length; i++)
      _eventBookSubscription[i]!.cancel();
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

  //void _loadQr() async {
  //  var user = await context.read<AppCubit>().getUser();
  //  _loggedUser = user;
  //  setState(() {
  //    _qrData = user.getQrData();
  //    _isLoggedUserLoading = false;
  //  });
  //}

  void _loadUserLevel() async {
    var user = await context.read<AppCubit>().getUser();
    _loggedUser = user;
    var level = await context.read<AppCubit>().getUserLevel();
    setState(() {
      _isAdmin = level == "admin";
      _loggedUser.isAdmin = true;
    });
    if (_isAdmin) _loadUsers();

    await _loadEvents();

    //print("pippo");


    for (int i = 0; i < _events.length; i++) {
      //data.add(_events[i]);
      //print("for events");
      _loadImage(i);
    }

    _loadEventsSubscription();

    setState(() {
      _isUsersLoading = false;
      _isLoggedUserLoading = false;
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

  Future<void> _loadEvents() async {
    setState(() {
      _isEventsLoading = true;
    });
    var tmpEvents = await context.read<AppCubit>().getUpperEvents();

    if (kDebugMode) {
      print("TEMP EVENTS LENGTH ${tmpEvents.length}");
    }

    if (_isAdmin == false) {
      _events.clear();
      // mostro solo eventi futuri
      //for (UpperEvent event in tmpEvents) {
      for (int i = 0; i < tmpEvents.length; i++) {
        var event = tmpEvents[i];
        event.checkTodayDate();
        DateTime eDate =
            convertiStringaAData(event.date).add(Duration(days: 1));
        if (eDate.isAfter(DateTime.now()) || event.isToday!) {
          //if (_loggedUser.cardNumber != 0) _events.add(event);
          _events.add(event);
        }
      }
    } else
      _events = tmpEvents;

    if (kDebugMode) {
      print("events length ${_events.length}");
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
              child: LocalEventTile(),
              //child: EventTile(
              //    upperEvents: _events,
              //    isAdmin: _isAdmin,
              //    allUsers: _users,
              //    loggedUser: _loggedUser),
            ),
          ),
          Visibility(
              visible: _events.isEmpty,
              child: !_isAdmin
                  ? Expanded(
                      child: Center(
                          child: Text(
                      textAlign: TextAlign.center,
                      //_loggedUser.cardNumber != 0 ?
                      "Nessun evento in programma",
                      //    : "La tua richiesta è in fase di elaborazione, una volta ricevuto il tuo UPPER PASS potrai visualizzare i nostri eventi",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: ColorsManager.gray17),
                    )))
                  : Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            textAlign: TextAlign.center,
                            //_loggedUser.cardNumber != 0 ?
                            "Nessun evento in programma",
                            //    : "La tua richiesta è in fase di elaborazione, una volta ricevuto il tuo UPPER PASS potrai visualizzare i nostri eventi",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: ColorsManager.gray17),
                          ),
                          Gap(20.h),
                          GestureDetector(
                            child: Icon(
                              Icons.add,
                              color: ColorsManager.gray17,
                            ),
                            onTap: () async {
                              await context.pushNamed(Routes.newEventScreen,
                                  arguments: null);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    )),
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
      height:
          MediaQuery.of(context).size.height, // Altezza massima dello schermo
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
                              side: BorderSide(
                                  width: 0, color: ColorsManager.gray17_03),
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
                                //'Email: ${user.email}\nData di nascita: ${user.birthdate}'),
                                'Email: ${user.email}'),
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
      //if (qrTapMode == false) {
      return Column(
        children: [
          Text(FirebaseAuth.instance.currentUser!.displayName!,
              style: TextStyle(fontSize: 30, color: ColorsManager.gray17)),
          SizedBox(
            height: 10,
          ),
          Visibility(
            visible: !myEventBooks.isEmpty,
            child: Text("Le mie prenotazioni",
                style: TextStyle(fontSize: 15, color: ColorsManager.gray17)),
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
            child: myEventBooks.isEmpty
                ? GestureDetector(
                    onTap: () async {
                      _tabController.animateTo(0);
                    },
                    child: Container(
                        width: 270,
                        height: 200,
                        child: Image(
                          image: AssetImage("assets/images/scopri_eventi.png"),
                          fit: BoxFit.cover,
                        )))
                : Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: ListView.builder(
                      itemCount: myEventBooks.length,
                      itemBuilder: (context, index) {
                        UpperEvent event = myEventBooks[index];

                        int eventIndex = _events.indexOf(event);

                        return GestureDetector(
                          onTap: () async {
                            await context.pushNamed(
                              Routes.viewBookScreen,
                              arguments: {
                                'event': event,
                                'bookData': _currentEventBookData[eventIndex],
                                'user': _loggedUser,
                                'image': _image[eventIndex],
                                'isMoneyScreen': false,
                                //'bookedUsers': _bookedUsers,
                                //'participantsUsers': _participantUsers,
                              },
                            );
                          },
                          child: CustomCard(
                            title: event.title,
                            subtitle: event.description,
                            date: event.date,
                            imagePath: "assets/images/cassero_no_bg.png",
                            persons: event.sumUpMyBookPerson,
                            children: event.sumUpMyBookChildren,
                          ),
                        );
                        //return ListTile(
                        //  tileColor: Colors.green,
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
                        //    Icons.star,
                        //    color: Colors.black,
                        //  ),
                        //  // trailing: GestureDetector(
                        //  //   onTap: () =>
                        //  //       _manageBook(_filteredBook[index], index),
                        //  //   child: Text(
                        //  //     widget.isMoneyScreen ? "PAGAMENTO" : "GESTISCI",
                        //  //     style: TextStyle(
                        //  //         fontSize: 14,
                        //  //         color: Colors.black,
                        //  //         fontWeight: FontWeight.bold),
                        //  //   ),
                        //  // ),
                        //  //
                        //  //trailing: GestureDetector(
                        //  //  child: Icon(Icons.delete, color: Colors.red),
                        //  //  onTap: () {},
                        //  //),
                        //  title: Text("${event.title}"),
                        //  subtitle: Text('${event.date}'),
                        //);
                      },
                    ),
                  ),
          ),
          //Text(
          //  "Mostra questo QR e un documento d'identità per entrare!",
          //  style: TextStyle(fontSize: 16, color: ColorsManager.gray17),
          //  textAlign: TextAlign.center,
          //),
          //SizedBox(
          //  height: 20,
          //),
          //Container(
          //  width: 320,
          //  height: 320,
          //  decoration: BoxDecoration(
          //      color: ColorsManager.gray17_03,
          //      borderRadius: BorderRadius.circular(5)),
          //  child: Center(
          //    child: SizedBox(
          //      width: 320,
          //      child: Center(
          //          child: _loggedUser.cardNumber != 0
          //              ? GestureDetector(
          //                  onTap: _toggleTapQr,
          //                  child: PrettyQrPlus(
          //                    data: _qrData,
          //                    size: 290,
          //                    elementColor: Colors.black,
          //                    roundEdges: false,
          //                    typeNumber: null,
          //                    //decoration: const PrettyQrDecoration(
          //                    //  background: ColorsManager.gray17,
          //                    //),
          //                  ),
          //                )
          //              : Center(
          //                  child: Text(
          //                    "La tua richiesta è in fase di elaborazione, il tuo UPPER PASS comparirà qui",
          //                    textAlign: TextAlign.center,
          //                    style: TextStyle(
          //                      fontSize: 20,
          //                    ),
          //                  ),
          //                )),
          //    ),
          //  ),
          //),
          //Container(
          //  width: 320,
          //  child: Center(
          //    child: Row(children: [
          //      Text(
          //        _loggedUser.uid!,
          //        style: TextStyle(color: ColorsManager.gray17, fontSize: 9),
          //        textAlign: TextAlign.start,
          //      ),
          //      Gap(10.w),
          //      Visibility(
          //        visible: _loggedUser.cardNumber != 0,
          //        child: Expanded(
          //          child: Text(
          //            _loggedUser.cardNumber.toString(),
          //            style: TextStyle(color: ColorsManager.gray17, fontSize: 9),
          //            textAlign: TextAlign.end,
          //          ),
          //        ),
          //      ),
          //    ]),
          //  ),
          //),
          //Gap(20.h),
          //Visibility(
          //  visible: whatsappGroupLink != "" &&
          //      isMobileDevice() &&
          //      _loggedUser.cardNumber != 0,
          //  child: GestureDetector(
          //    onTap: _redirectWhatsapp,
          //    child: Container(
          //      width: 320,
          //      height: 60,
          //      padding: const EdgeInsets.only(
          //          right: 8.0, left: 8.0, bottom: 2.0, top: 2.0),
          //      decoration: BoxDecoration(
          //          color: ColorsManager.gray17,
          //          borderRadius: BorderRadius.circular(5)),
          //      child: Row(
          //        children: [
          //          //Icon(Icons.message),
          //          Image(image: AssetImage("assets/images/whatsapp.gif")),
          //          Gap(15.w),
          //          Text("Unisciti al gruppo Whatsapp",
          //              style: TextStyle(fontWeight: FontWeight.normal)),
          //        ],
          //      ),
          //    ),
          //  ),
          //),
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
      );
      //} else {
      //  return Container(
      //    color: ColorsManager.gray17,
      //    child: Center(
      //      child: GestureDetector(
      //        onTap: _toggleTapQr,
      //        child: PrettyQrPlus(
      //          data: _qrData,
      //          size: MediaQuery.of(context).size.width - 10,
      //          elementColor: Colors.black,
      //          roundEdges: false,
      //          typeNumber: null,
      //          //decoration: const PrettyQrDecoration(
      //          //  background: ColorsManager.gray17,
      //          //),
      //        ),
      //      ),
      //    ),
      //  );
      //}
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
              controller: _tabController,
              indicatorColor: ColorsManager.gray17,
              padding: EdgeInsets.only(bottom: 10),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: TabBarView(
              children: _tabBarViewWidgets(),
              controller: _tabController,
            ), // Associa il TabController,)),
          ),
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

class CustomCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String imagePath;
  final int persons;
  final int children;

  // Costruttore per accettare argomenti
  const CustomCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.imagePath,
    required this.persons,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10, // Ombra intorno alla card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Angoli arrotondati
      ),
      shadowColor: Colors.black.withOpacity(0.3), // Colore ombra
      child: Container(
        width: 300,
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue[100]!,
              Colors.lightBlue[300]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            // Immagine in basso a destra con trasparenza
            Positioned(
              top: 5,
              right: 10,
              child: Opacity(
                opacity: 0.2, // Imposta la trasparenza
                child: Image.asset(
                  imagePath,
                  width: 210,
                  height: 350,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              top: 5,
              right: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: persons != 0,
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 40,
                          color: Colors.white,
                        ),
                        Gap(3.w),
                        Text(
                          "x ${persons}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: persons != 0,
                    child: Gap(5.h),
                  ),
                  Visibility(
                    visible: children != 0,
                    child: Row(
                      children: [
                        Icon(
                          Icons.child_care_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                        Gap(3.w),
                        Text(
                          "x ${children}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Contenuto della card
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black45,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
