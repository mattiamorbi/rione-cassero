import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:upper/core/widgets/app_text_button.dart';
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
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String qrData = "";
  late bool isAdmin = false;
  List<UpperEvent> events = [];
  List<up.User> users = [];
  bool isUsersLoading = true;
  List<up.User> filteredUsers = [];  // Lista filtrata da visualizzare
  TextEditingController searchController = TextEditingController();  // Controller per il campo di ricerca


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OfflineBuilder(
        connectivityBuilder: (context, value, child) {
          final bool connected = value.any((element) => element != ConnectivityResult.none);
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
    if (isAdmin) _loadUsers();
  }

  void _loadUsers() async {
    setState(() {
      isUsersLoading = true;
    });
    users = await context.read<AppCubit>().getUsers();
    setState(() {
      isUsersLoading = false;
      filteredUsers = users;
    });
  }
  
  void _loadQr() async {
    var user = await context.read<AppCubit>().getUser();
    setState(() {
      qrData = user.getQrData();
    });
  }

  void _loadUserLevel() async {
    var level = await context.read<AppCubit>().getUserLevel();
    setState(() {
      isAdmin = level == "admin";
    });
  }

  void _loadEvents() async {
    var tmpEvents = await context.read<AppCubit>().getUpperEvents();
    setState(() {
      events = tmpEvents;
    });
  }

  List<Widget> _getTabBars() {
    var widgets = <Widget>[
      Icon(Icons.calendar_month_rounded, color: Colors.white),
      Icon(Icons.account_circle_outlined, color: Colors.white),
    ];

    if (isAdmin) widgets.add(Icon(Icons.account_circle_outlined, color: Colors.orange));
    return widgets;
  }

  List<Widget> _tabBarViewWidgets() {
    var widgets = <Widget>[_eventsWidget(), _profileWidget()];
    if (isAdmin)  widgets.add(_userManagementWidget());
    return widgets;
  }

  Widget _eventsWidget() {
    if (events.isNotEmpty) {
      return Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: EventTile(upperEvent: events, isAdmin: isAdmin),
          ),
        ],
      );
    } else {
      return Center(
        child: Image(image: AssetImage("assets/images/loading.gif")),
      );
    }
  }

   // Funzione per filtrare la lista degli utenti in base al testo inserito
  void filterUtenti(String query) {
    List<up.Users> filtered = users.where((utente) {
      String fullName = '${utente.nome.toLowerCase()} ${utente.cognome.toLowerCase()}';
      return fullName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUsers = filtered;
    });
  }

  Widget _userManagementWidget() {
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Cerca per nome o cognome',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                filterUtenti(value);  // Filtra la lista ogni volta che il testo cambia
              },
            ),
          ),
          Expanded(
            child: isUsersLoading 
                ? Center(child: Text('Caricamento utenti in corso...')) : filteredUsers.isEmpty
                ? Center(child: Text('Nessun utente trovato'))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final utente = filteredUsers[index];
                      return ListTile(
                        title: Text('${utente.nome} ${utente.cognome}'),
                        subtitle: Text('UID: ${utente.uid}'),
                      );
                    },
                  ),
          ),
        ],
      );
  }

  Widget _profileWidget() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(FirebaseAuth.instance.currentUser!.displayName!, style: TextStyle(fontSize: 30, color: Colors.white)),
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
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: SizedBox(
                width: 250,
                child: PrettyQrView.data(
                  data: qrData,
                  decoration: const PrettyQrDecoration(
                    background: Colors.white,
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
  }

  SafeArea _homePage(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        initialIndex: 1,
        length: isAdmin ? 3 : 2,
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
}
