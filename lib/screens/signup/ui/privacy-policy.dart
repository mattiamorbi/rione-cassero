import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PrivacyPolicy extends StatefulWidget {
  PrivacyPolicy();

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'rione-cassero.web.app tutela la privacy dei propri utenti e garantisce che il trattamento dei dati '
              'sia conforme a quanto previsto dalla normativa sulla privacy di cui al d.lgs. 30 giugno 2003, n. 196 e al '
              'nuovo Regolamento UE 2016/679 noto come GDPR.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            _buildSectionTitle(
                'Informativa resa ai sensi del GDPR 2016/679 (General Data Protection Regulation)'),
            _buildSectionText(
              "Gentile Signore/a, ai sensi del Regolamento UE 2016/679 ed in relazione alle informazioni di cui si entrerà in possesso, ai fini della tutela delle persone e altri soggetti in materia di trattamento di dati personali, si informa quanto segue:\r\n\r\n"
              "rione-cassero.web.app rispetta la Privacy dei propri utenti e si impegna a proteggere i dati personali che gli stessi conferiscono a rione-cassero.web.app.\r\nIn generale, l’utente può navigare sul sito web rione-cassero.web.app senza fornire alcun tipo di informazione personale. La raccolta ed il trattamento di dati personali avvengono quando necessarie a rione-cassero.web.app in relazione all’esecuzione di servizi richiesti dall’utente, o quando l’utente stesso decide di comunicare i propri dati personali; in tali circostanze, la presente politica della privacy illustra le modalità ed i caratteri di raccolta e trattamento dei dati personali dell’utente. Gruppocassero.it tratta i dati personali forniti dagli utenti in conformità alla normativa vigente.",
            ),
            _buildSectionTitle('Titolare del Trattamento Dati'),
            _buildSectionText(
              "Rione Cassero,"
              "Via S. Michele, 97/A\r\n"
              "Castiglion Fiorentino – 52043 (AR) – Italia\r\n"
              "info@gruppocassero.it",
            ),
            _buildSectionTitle('Raccolta dei Dati Personali'),
            _buildSectionText(
                "Dati personali significa qualsiasi informazione che possa essere impiegata per identificare un individuo, una società od altro ente.\r\nA titolo puramente esemplificativo e non esaustivo viene raccolto ad esempio il nome ed il cognome, l’indirizzo di posta elettronica (e-mail), l’indirizzo, un recapito telefonico, queste informazioni sono necessarie per la prestazione di servizi richiesti dall’utente.\r\nLa navigazione sul sito avviene in forma anonima, (a meno che l’utente abbia precedentemente specificato che desidera che rione-cassero.web.app ricordi l’identificativo con cui si è registrato e la relativa password).\r\nrione-cassero.web.app non compie operazioni di raccolta dati dell’utente con modalità automatiche, incluso l’indirizzo di posta elettronica (e-mail).\r\nGruppocassero.it registra l’indirizzo IP dell’utente (Internet Protocol, vale a dire l’indirizzo Internet del computer dell’utente) per avere un’idea dell’area del sito che l’utente visita e della durata della visita, nel rispetto della normativa vigente in tema di tutela di dati personali.\r\nTuttavia, Gruppocassero.it non mette in relazione l’indirizzo IP dell’utente con altre informazioni personali relative allo stesso se non dopo averlo debitamente informato del relativo trattamento ed avere ottenuto il suo consenso al trattamento, e solo rispetto ad utenti registrati al sito."),
            _buildSectionTitle('Comunicazione dei Dati Personali'),
            _buildSectionText(
              'In caso di raccolta di dati personali, rione-cassero.web.app informerà l\'utente delle finalità della raccolta e, ove necessario, richiederà il consenso.',
            ),
            _buildSectionTitle('Finalità e Modalità di Trattamento dei Dati'),
            _buildSectionText(
                "rione-cassero.web.app tratta i dati personali dell’utente per le seguenti finalità di carattere generale:\r\n\r\n"
                "- Gestione delle prenotazioni agli eventi proposti\r\n"
                "- Attività di assistenza alla clientela\r\n"
                "- Archiviazione e la conservazione\r\n\r\n"
                "I dati personali dell’utente non vengono comunicati al di fuori della realtà di rione-cassero.web.app senza il consenso dell’interessato, salvo quanto di seguito specificato.\r\nNell’ambito dell’organizzazione di rione-cassero.web.app, i dati sono conservati in server controllati cui è consentito un accesso limitato in conformità alla normativa vigente a tutela di dati personali.\r\nGruppocassero.it inoltre divulgherà i dati personali dell’utente in caso ciò sia richiesto dalla legge. "),
            _buildSectionTitle('Sicurezza dei Dati'),
            _buildSectionText(
                "rione-cassero.web.app adotta tutte le misure di sicurezza e le procedure fisiche, elettroniche, ed organizzative richieste dalla normativa vigente.\r\nAnche se viene fatto quanto ragionevolmente possibile per proteggere i dati personali dell’utente, Gruppocassero.it non può garantire la completa totale sicurezza dei dati trasmessi dagli utenti durante la comunicazione, quindi si invita l’utente ad adottare tutte misure precauzionali per proteggere i propri dati personali quando navigano su Internet.\r\nAd esempio, l’utente è invitato a cambiare spesso la propria password, usare una combinazione di lettere e numeri, ed assicurarsi di fare uso di un browser sicuro." ),
            _buildSectionTitle('Periodo di conservazione dati'),
            _buildSectionText(
              "I Dati sono trattati e conservati per il tempo richiesto dalle finalità per le quali sono stati raccolti.\r\n"
            "\r\n"
            "Pertanto:\r\n"
            "\r\n"
            "- I Dati Personali raccolti per scopi collegati all’esecuzione di un contratto tra rione-cassero.web.app e l’Utente saranno trattenuti sino a quando sia completata l’esecuzione di tale contratto.\r\n"
            "- I Dati Personali raccolti per finalità riconducibili all’interesse legittimo di rione-cassero.web.app saranno trattenuti sino al soddisfacimento di tale interesse. L’Utente può ottenere ulteriori informazioni in merito all’interesse legittimo perseguito dal Titolare nelle relative sezioni di questo documento o contattando il Titolare.\r\n"
            "\r\nQuando il trattamento è basato sul consenso dell’Utente, il Titolare può conservare i Dati Personali più a lungo sino a quando detto consenso non venga revocato. Inoltre, il Titolare potrebbe essere obbligato a conservare i Dati Personali per un periodo più lungo in ottemperanza ad un obbligo di legge o per ordine di un’autorità.\r\n"
            "\r\n"
            "Al termine del periodo di conservazione i Dati Personali saranno cancellati. Pertanto, allo spirare di tale termine il diritto di accesso, cancellazione, rettificazione ed il diritto alla portabilità dei Dati non potranno più essere esercitati."
              ,
            ),
            _buildSectionTitle('Diritti dell\'Utente'),
            _buildSectionText(
                "Gli Utenti possono esercitare determinati diritti con riferimento ai Dati trattati da rione-cassero.web.app.\r\n"
            "\r\n"
            "In particolare, l’Utente ha il diritto di:\r\n"
            "\r\n"
            "- revocare il consenso in ogni momento. L’Utente può revocare il consenso al trattamento dei propri Dati Personali precedentemente espresso.\r\n"
            "- opporsi al trattamento dei propri Dati. L’Utente può opporsi al trattamento dei propri Dati quando esso avviene su una base giuridica diversa dal consenso.\r\n"
            "- accedere ai propri Dati. L’Utente ha diritto ad ottenere informazioni sui Dati trattati da rione-cassero.web.app, su determinati aspetti del trattamento ed a ricevere una copia dei Dati trattati.\r\n"
            "- verificare e chiedere la rettificazione. L’Utente può verificare la correttezza dei propri Dati e richiederne l’aggiornamento o la correzione.\r\n"
            "- ottenere la limitazione del trattamento. Quando ricorrono determinate condizioni, l’Utente può richiedere la limitazione del trattamento dei propri Dati. In tal caso rione-cassero.web.app non tratterà i Dati per alcun altro scopo se non la loro conservazione.\r\n"
                "- ottenere la cancellazione o rimozione dei propri Dati Personali. Quando ricorrono determinate condizioni, l’Utente può richiedere la cancellazione dei propri Dati da parte di rione-cassero.web.app.\r\n"
                "- ricevere i propri Dati o farli trasferire ad altro titolare. L’Utente ha diritto di ricevere i propri Dati in formato strutturato, di uso comune e leggibile da dispositivo automatico e, ove tecnicamente fattibile, di ottenerne il trasferimento senza ostacoli ad un altro titolare. Questa disposizione è applicabile quando i Dati sono trattati con strumenti automatizzati ed il trattamento è basato sul consenso dell’Utente, su un contratto di cui l’Utente è parte o su misure contrattuali ad esso connesse.\r\n"
            "- proporre reclamo. L’Utente può proporre un reclamo all’autorità di controllo della protezione dei dati personali competente o agire in sede giudiziale.\r\n\r\n"
                "Per esercitare i diritti dell’Utente, gli Utenti possono indirizzare una richiesta all’indirizzo di posta elettronica info@gruppocassero.it. Le richieste sono depositate a titolo gratuito e evase da rione-cassero.web.app nel più breve tempo possibile, in ogni caso entro un mese."

            ),
            _buildSectionTitle('Modifiche alla Privacy Policy'),
            _buildSectionText(
              'rione-cassero.web.app si riserva il diritto di apportare modifiche alla presente Privacy Policy in qualsiasi momento.',
            ),
            _buildSectionTitle('Domande e Contatti'),
            _buildSectionText(
              'Per qualsiasi domanda o dubbio relativo alla presente Privacy Policy, l\'utente può contattare il Titolare del trattamento all\'indirizzo email: info@gruppocassero.it.',
            ),
            SizedBox(height: 20),
            _buildSectionText(
              'Data di aggiornamento: 25/02/2025',
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
