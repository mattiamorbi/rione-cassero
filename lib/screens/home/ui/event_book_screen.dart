import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:rione_cassero/core/widgets/app_text_form_field.dart';
import 'package:rione_cassero/models/participant_data.dart';
import 'package:rione_cassero/models/upper_event.dart';
import 'package:rione_cassero/models/user.dart' as up;
import 'package:rione_cassero/theming/colors.dart';

import '../../../routing/routes.dart';

import 'package:flutter/services.dart'; // Necessario per rootBundle
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'dart:html' as html; // Importante
import 'package:flutter/foundation.dart' show kIsWeb;

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
  List<ParticipantDataCassero> _preFilteredBook = [];
  int toBeConfirmedBook = 0;

  //List<up.User?>? bookedUsers = [];
  //List<up.User?>? participantsUsers = [];

  final TextEditingController _searchController = TextEditingController();

  bool _allergyFilter = false;
  bool _alphabetSort = false;
  bool _dateSort = false;
  bool _toBeConfirmedSort = true;

  //bool _isUsersLoading = true;

  //StreamSubscription<List<up.User>?>? _presenceSubscription;
  //StreamSubscription<List<up.User>?>? _bookSubscription;

  @override
  void initState() {
    super.initState();

    _loadFilteredBook();
  }

  void _loadFilteredBook() {
    if (_preFilteredBook.length > 0) {
      _preFilteredBook.clear();
      toBeConfirmedBook = 0;
    }
    if (widget.isMoneyScreen &&
        widget.upperEvent.confirmation != null &&
        widget.upperEvent.confirmation!) {
      for (int i = 0; i < widget.bookData.length; i++) {
        if (widget.bookData[i].confirmed!) {
          _preFilteredBook.add(widget.bookData[i]);
        }
      }
    } else {
      for (int i = 0; i < widget.bookData.length; i++) {
        if (!widget.bookData[i].confirmed!) {
          _preFilteredBook.add(widget.bookData[i]);
          toBeConfirmedBook++;
        }
      }
      for (int i = 0; i < widget.bookData.length; i++) {
        if (widget.bookData[i].confirmed!) {
          _preFilteredBook.add(widget.bookData[i]);
        }
      }
    }

    applyListSorting(_preFilteredBook);
  }

  // Funzione per filtrare la lista degli utenti in base al testo inserito
  void filterUsers(String query) {
    List<ParticipantDataCassero> filtered = _preFilteredBook.where((book) {
      String fullName =
          '${book.name.toLowerCase()} ${book.bookUserName.toLowerCase()}';

      bool result = fullName.contains(query.toLowerCase());
      if (_allergyFilter) result = result && book.allergy == true;
      //if (widget.isMoneyScreen || widget.upperEvent.confirmation != null) result = result && book.confirmed != null && book.confirmed!;
      return result;
    }).toList();

    applyListSorting(filtered);
  }

  void applyListSorting(List<ParticipantDataCassero> list) {
    // Ordinamento con `sortBy()` usando il nome

    if (_dateSort) {
      list.sortBy((u) => u.date!);
      list = list.reversed.toList();
    } else if (_alphabetSort) {
      list.sortBy((u) => u.name.toUpperCase());
    } else if (_toBeConfirmedSort) {
      if (widget.isMoneyScreen) {
        list.sortBy((u) => u.paied.toString());
      } else {
        list.sortBy((u) => u.confirmed.toString());
      }
    }

    setState(() {
      _filteredBook = list;
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

  int getTotalBookChild(List<ParticipantDataCassero> list, bool paied, bool countInfant) {
    int sum = 0;
    for (var book in list) {
      //var event = UpperEvent.fromJson(doc.data());
      //print(doc.id);
      sum += paied
          ? book.childrenPaied ?? 0
          : countInfant ? (book.childrenNumber + book.infantBookNumber) : book.childrenNumber;
    }
    return sum;
  }

  int getTotalBookInfant(List<ParticipantDataCassero> list) {
    int sum = 0;
    for (var book in list) {
      //var event = UpperEvent.fromJson(doc.data());
      //print(doc.id);
      sum += book.infantBookNumber;
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
                          suffixIcon: GestureDetector(
                            onTap: () {
                              if (_searchController.text.length > 0) {
                                setState(() {
                                  _searchController.text = "";
                                  filterUsers("");
                                });
                              }
                            },
                            child: Icon(
                              _searchController.text.length == 0
                                  ? Icons.search
                                  : Icons.cancel,
                              color: Colors.black38,
                            ),
                          ),
                          onChanged: (value) {
                            filterUsers(value);
                          },
                        ),
                      ),
                    ),
                    Text(
                      widget.isMoneyScreen
                          ? "Prenotazioni: ${_preFilteredBook.length}"
                          : toBeConfirmedBook > 0
                              ? "Prenotazioni: ${_preFilteredBook.length} (Da confermare: ${toBeConfirmedBook})"
                              : "Prenotazioni: ${_preFilteredBook.length}",
                      style: TextStyle(color: ColorsManager.gray17),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin!,
                      child: Text(
                        "Persone totali: ${getTotalBookPeople(_preFilteredBook, false) + getTotalBookChild(_preFilteredBook, false, true)}",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin!,
                      child: Text(
                        getTotalBookInfant(_preFilteredBook) == 0
                            ? "Adulti: ${getTotalBookPeople(_preFilteredBook, false)} / Bambini totali: ${getTotalBookChild(_preFilteredBook, false, true)}"
                            : "Adulti: ${getTotalBookPeople(_preFilteredBook, false)} / Bambini totali: ${getTotalBookChild(_preFilteredBook, false, true)} (${getTotalBookInfant(_preFilteredBook)} neonati)",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin! &&
                          widget.upperEvent.price != null &&
                          widget.upperEvent.childrenPrice != null,
                      child: Text(
                        "Incasso previsto: ${(widget.upperEvent.price! * getTotalBookPeople(_preFilteredBook, false)) + (widget.upperEvent.childrenPrice! * getTotalBookChild(_preFilteredBook, false, false))} €",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Visibility(
                      visible: widget.loggedUser.isAdmin! &&
                          widget.upperEvent.price != null &&
                          widget.upperEvent.childrenPrice != null,
                      child: Text(
                        "Incasso attuale: ${(widget.upperEvent.price! * getTotalBookPeople(_preFilteredBook, true)) + (widget.upperEvent.childrenPrice! * getTotalBookChild(_preFilteredBook, true, false))} €",
                        style: TextStyle(color: ColorsManager.gray17),
                      ),
                    ),
                    Gap(10.h),
                    Visibility(
                      visible: widget.loggedUser.isAdmin!,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: widget.loggedUser.isAdmin! &&
                                !widget.isMoneyScreen,
                            child: GestureDetector(
                                onTap: () => setState(() {
                                      _allergyFilter = !_allergyFilter;
                                      filterUsers(_searchController.text);
                                    }),
                                child: Icon(
                                  _allergyFilter
                                      ? Icons.no_food
                                      : Icons.no_food_outlined,
                                  size: 30,
                                  color: _allergyFilter
                                      ? Colors.lightGreen
                                      : Colors.black,
                                )),
                          ),
                          Visibility(
                              visible: widget.loggedUser.isAdmin! &&
                                  !widget.isMoneyScreen,
                              child: Gap(20.w)),
                          GestureDetector(
                              onTap: () => setState(() {
                                    _alphabetSort = false;
                                    _dateSort = false;
                                    _toBeConfirmedSort = true;
                                    //applyListSorting(_filteredBook);
                                    filterUsers(_searchController.text);
                                  }),
                              child: Icon(
                                _toBeConfirmedSort
                                    ? Icons.confirmation_num_outlined
                                    : Icons.confirmation_num_outlined,
                                size: 30,
                                color: _toBeConfirmedSort
                                    ? Colors.lightGreen
                                    : Colors.black,
                              )),
                          Gap(20.w),
                          GestureDetector(
                              onTap: () => setState(() {
                                    _alphabetSort = true;
                                    _dateSort = false;
                                    _toBeConfirmedSort = false;
                                    applyListSorting(_filteredBook);
                                  }),
                              child: Icon(
                                _alphabetSort
                                    ? Icons.sort_by_alpha
                                    : Icons.sort_by_alpha_rounded,
                                size: 30,
                                color: _alphabetSort
                                    ? Colors.lightGreen
                                    : Colors.black,
                              )),
                          Gap(20.w),
                          GestureDetector(
                              onTap: () => setState(() {
                                    _alphabetSort = false;
                                    _dateSort = true;
                                    _toBeConfirmedSort = false;
                                    applyListSorting(_filteredBook);
                                  }),
                              child: Icon(
                                _dateSort
                                    ? Icons.date_range
                                    : Icons.date_range_outlined,
                                size: 30,
                                color: _dateSort
                                    ? Colors.lightGreen
                                    : Colors.black,
                              )),
                          Gap(20.w),
                          GestureDetector(
                              onTap: () => setState(() async {

                                try {
                                  await generateAdvancedBookingPdf(upperEvent: widget.upperEvent, prenotazioni:  this.widget.bookData, );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Errore durante la creazione del PDF: $e"))
                                  );
                                }


                              }),
                              child: Icon(Icons.download,
                                size: 30,
                                color: Colors.black,
                              )),
                        ],
                      ),
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
                          int totalBook = widget.isMoneyScreen ? calcTotalBook(user) : calcTotalBook(user) + user.infantBookNumber;

                          late Color bgShade1;
                          late Color bgShade2;
                          late Color textColor;
                          late Color subTextColor;

                          if (widget.isMoneyScreen) {
                            if (notPaied == 0) {
                              // verde
                              bgShade1 = Colors.lightGreen[100]!;
                              bgShade2 = Colors.lightGreen[300]!;
                              textColor = Colors.lightGreen[900]!;
                              subTextColor = Colors.lightGreen[700]!;
                            } else {
                              //rosso
                              bgShade1 = Colors.red[100]!;
                              bgShade2 = Colors.red[300]!;
                              textColor = Colors.red[900]!;
                              subTextColor = Colors.red[700]!;
                            }
                          } else {
                            if (user.confirmed!) {
                              bgShade1 = Colors.lightBlue[100]!;
                              bgShade2 = Colors.lightBlue[300]!;
                              textColor = Colors.blue[900]!;
                              subTextColor = Colors.blue[700]!;
                            } else {
                              bgShade1 = Colors.orange[100]!;
                              bgShade2 = Colors.orange[300]!;
                              textColor = Colors.orange[900]!;
                              subTextColor = Colors.orange[700]!;
                            }
                          }

                          return GestureDetector(
                            onTap: () => widget.isMoneyScreen
                                ? _managePayment(_filteredBook[index], index)
                                : _manageBook(
                                    _filteredBook[index],
                                    index,
                                    notPaied != totalBook &&
                                        !widget.loggedUser.isAdmin!),
                            child: Card(
                              elevation: 10,
                              // Ombra intorno alla card
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    20), // Angoli arrotondati
                              ),
                              shadowColor: Colors.black.withOpacity(0.3),
                              // Colore ombra
                              child: Container(
                                padding:
                                    EdgeInsets.all(10), // Spaziatura interna
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      //notPaied == 0 ? Colors.lightGreen[100]! : !widget.isMoneyScreen ? Colors.blue[100]! : Colors.red[100]!,
                                      //notPaied == 0 ? Colors.lightGreen[300]! : !widget.isMoneyScreen ? Colors.blue[300]! : Colors.red[300]!,
                                      //notPaied == 0
                                      //    ? Colors.lightGreen[100]!
                                      //    : widget.isMoneyScreen
                                      //        ? Colors.red[100]!
                                      //        : (user.confirmed != null &&
                                      //                user.confirmed! &&
                                      //                widget
                                      //                    .loggedUser.isAdmin!)
                                      //            ? Colors.green[100]!
                                      //            : Colors.blue[100]!,
                                      //notPaied == 0
                                      //    ? Colors.lightGreen[300]!
                                      //    : widget.isMoneyScreen
                                      //        ? Colors.red[300]!
                                      //        : (user.confirmed != null &&
                                      //                user.confirmed! &&
                                      //                widget
                                      //                    .loggedUser.isAdmin!)
                                      //            ? Colors.green[300]!
                                      //            : Colors.blue[300]!,
                                      bgShade1,
                                      bgShade2,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  leading: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      // Sfondo per l'icona
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _filteredBook[index].allergy != null &&
                                              _filteredBook[index].allergy ==
                                                  true
                                          ? Icons.no_food
                                          : Icons.bookmark_border,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  title: Text(
                                    totalBook > 1
                                        ? user.infantBookNumber > 0 && widget.isMoneyScreen ? "${user.name} (${totalBook} persone, ${user.infantBookNumber} neonato)" : "${user.name} (${totalBook} persone)"
                                        : user.infantBookNumber > 0 && widget.isMoneyScreen ? "${user.name} (${totalBook} persona, ${user.infantBookNumber} neonato)" : "${user.name} (${totalBook} persona)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    widget.isMoneyScreen && user.date != null
                                        ? "Prenotazione effettuata da: ${user.bookUserName}"
                                        : widget.loggedUser.isAdmin!
                                            ? "Effettuata da: ${user.bookUserName}\r\n${user.date!.day}/${user.date!.month}/${user.date!.year} ${user.date!.hour}:${user.date!.minute}"
                                            : "Effettuata da: ${user.bookUserName}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      //color: notPaied == 0
                                      //    ? Colors.green[700]
                                      //    : widget.isMoneyScreen
                                      //        ? Colors.red[700]
                                      //        : (user.confirmed != null &&
                                      //                user.confirmed! &&
                                      //                widget
                                      //                    .loggedUser.isAdmin!)
                                      //            ? Colors.green[700]
                                      //            : Colors.blue[700],
                                      color: textColor,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Text(
                                      widget.isMoneyScreen
                                          ? notPaied == 0
                                              ? "PAGATO"
                                              : "${notPaied} DA PAGARE"
                                          : notPaied == 0
                                              ? "PAGATO"
                                              : notPaied != totalBook - user.infantBookNumber
                                                  ? "${notPaied} DA PAGARE"
                                                  : (user.confirmed != null &&
                                                          user.confirmed! &&
                                                          widget.loggedUser
                                                              .isAdmin!)
                                                      ? "MODIFICA"
                                                      : "GESTISCI",
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
                                  tileColor: Colors
                                      .transparent, // Lascia il colore trasparente
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

  Future<void> _manageBook(ParticipantDataCassero currentBookData, int index,
      bool alreadyPaied) async {
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
    _loadFilteredBook();
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



  Future<void> generateAdvancedBookingPdf({
    required UpperEvent upperEvent,
    required List<ParticipantDataCassero> prenotazioni,
  }) async {
    final pdf = pw.Document();
    final formatValuta = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    // Caricamento Font per simboli € e accentate
    final fontData = await rootBundle.load("assets/fonts/Roboto.ttf");
    final fontBoldData = await rootBundle.load("assets/fonts/Roboto.ttf");
    final myFont = pw.Font.ttf(fontData);
    final myFontBold = pw.Font.ttf(fontBoldData);

    prenotazioni.sortBy((u) => u.name.toUpperCase());

    // Calcolo riepilogo generale
    double incassoTotale = 0;//prenotazioni.fold(0, (sum, item) => sum + item.totaleDovuto);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.portrait,
        theme: pw.ThemeData.withFont(base: myFont, bold: myFontBold),
        build: (context) => [
          // --- HEADER EVENTO ---
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(upperEvent.title.toUpperCase(),
                        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Data: ${upperEvent.date} ore ${upperEvent.time}"),
                    pw.Text("Luogo: ${upperEvent.place}"),
                    pw.Text("Data stampa: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}")
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(color: PdfColors.grey100),
                child: pw.Column(
                  children: [
                    pw.Text("PARTECIPANTI", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text((getTotalBookPeople(prenotazioni, false) + getTotalBookChild(prenotazioni, false, true)).toString(), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                    //pw.Text("INCASSO ATTESO", style: const pw.TextStyle(fontSize: 10)),
                    //pw.Text(formatValuta.format((widget.upperEvent.price! * getTotalBookPeople(prenotazioni, false)) + (widget.upperEvent.childrenPrice! * getTotalBookChild(prenotazioni, false, false))),
                    //    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // --- TABELLA PRENOTAZIONI ---
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2), // Nome
              1: const pw.FlexColumnWidth(2), // Cognome
              2: const pw.FlexColumnWidth(3), // Dettaglio Partecipanti
              3: const pw.FlexColumnWidth(1.5), // Totale Dovuto
              4: const pw.FlexColumnWidth(2.5), // Note a penna
            },
            children: [
              // Header Tabella
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
                children: [
                  headerCell("Nome"),
                  headerCell("Utente"),
                  headerCell("Dettaglio Partecipanti"),
                  headerCell("Totale"),
                  headerCell("Note"),
                ],
              ),
              // Righe Dinamiche
              ...prenotazioni.map((p) {
                return pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    cellText(p.name),
                    cellText(p.bookUserName),
                    // COLONNA DETTAGLIO (Logica richiesta)
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (p.number > 0)
                            pw.Text("Adulti: ${p.number} (${formatValuta.format(p.number * (upperEvent.price ?? 0))})", style: const pw.TextStyle(fontSize: 9)),
                          if (p.childrenNumber > 0)
                            pw.Text("Ridotti: ${p.childrenNumber} (${formatValuta.format(p.childrenNumber * (upperEvent.childrenPrice ?? 0))})", style: const pw.TextStyle(fontSize: 9)),
                          if (p.infantBookNumber > 0)
                            pw.Text("Neonati: ${p.infantBookNumber} (Gratis)", style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                    // COLONNA TOTALE
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(formatValuta.format(p.number * (upperEvent.price ?? 0) + p.childrenNumber * (upperEvent.childrenPrice ?? 0)), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    // SPAZIO NOTE
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(""),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );

    final Uint8List bytes = await pdf.save();

    if (kIsWeb) {
      // Usiamo direttamente il DOM del browser senza passare dal plugin 'printing'
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "lista_prenotazioni_${upperEvent.title}.pdf")
        ..click(); // Questo forza il download immediato

      html.Url.revokeObjectUrl(url);
      print("Download avviato tramite Blob");
    } else {
      // Solo qui usiamo il plugin (per app Android/iOS native)
      await Printing.sharePdf(bytes: bytes, filename: 'lista.pdf');
    }
  }

// Widget helper per le celle header
  pw.Widget headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 11)),
    );
  }

// Widget helper per le celle testo
  pw.Widget cellText(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }
}
