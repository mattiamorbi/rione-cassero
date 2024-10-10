import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
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
  const HomeScreen({super.key});

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
  final TextEditingController _searchController = TextEditingController(); // Controller per il campo di ricerca

  late up.User _loggedUser;

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
    if (_isAdmin) _loadUsers();
  }

  void _loadEvents() async {
    var tmpEvents = await context.read<AppCubit>().getUpperEvents();
    setState(() {
      _events = tmpEvents;
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
    if (_events.isNotEmpty) {
      return Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: EventTile(upperEvents: _events, isAdmin: _isAdmin, allUsers: _users, loggedUser: _loggedUser),
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
  void _filterUsers(String query) {
    List<up.User> filtered = _users.where((utente) {
      String fullName = '${utente.name.toLowerCase()} ${utente.surname.toLowerCase()}';
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
                              color: Colors.black,
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
                  data: _qrData,
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
}
