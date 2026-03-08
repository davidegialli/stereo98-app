// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IstruzioniScreen extends StatelessWidget {
  const IstruzioniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.close(1),
        ),
        title: const Text(
          'Come funziona',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).cardColor,
              Theme.of(context).canvasColor,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              icon: Icons.music_note,
              title: '1. Ascoltare la Radio',
              items: [
                'Premi il pulsante ▶️ Play al centro in basso per avviare lo streaming',
                'Premi di nuovo per mettere in ⏸ Pausa',
                'La riproduzione continua anche in background quando chiudi l\'app',
                'Usa i controlli nella barra delle notifiche per Play/Pausa senza riaprire l\'app',
              ],
            ),
            _buildSection(
              icon: Icons.nightlight_round,
              title: '2. Sleep Timer',
              items: [
                'Tocca l\'icona 🌙 Luna in basso a sinistra',
                'Scegli la durata: 15, 30, 45, 60 o 90 minuti',
                'Il countdown apparirà in alto a sinistra nella barra',
                'Tocca il timer per modificarlo o disattivarlo',
                'Allo scadere del tempo, la radio si fermerà automaticamente',
              ],
            ),
            _buildSection(
              icon: Icons.star,
              title: '3. Mi Piace — Vota il Brano',
              items: [
                'Tocca il pulsante ⭐ Stella nella barra in basso',
                'Ogni stella viene contata nella classifica settimanale',
                'Le canzoni più votate salgono nella Chart Settimanale',
                'Più voti dai, più sali nella classifica fan!',
                'Le canzoni votate le ritrovi nella sezione Le Mie Canzoni nel menu laterale',
              ],
            ),
            _buildSection(
              icon: Icons.library_music,
              title: '4. Le Mie Canzoni',
              items: [
                'Apri il menu laterale (☰ in alto a sinistra)',
                'Tocca 🎶 Le Mie Canzoni',
                'Troverai l\'elenco di tutte le canzoni che hai votato',
                'Per ogni canzone puoi toccare il pulsante ▶ Ascolta per cercarla su Apple Music',
                'Scorri verso il basso per aggiornare la lista',
              ],
            ),
            _buildSection(
              icon: Icons.emoji_events,
              title: '5. Il Tuo Codice Fan',
              items: [
                'Il tuo codice fan appare nella schermata principale sotto le informazioni del brano',
                'È generato automaticamente al primo avvio dell\'app',
                'Tocca il codice fan per aprire il tuo profilo',
                'Nel profilo puoi inserire il tuo nome per farti riconoscere in classifica',
                'Vedrai la tua posizione in classifica e quanti voti hai dato',
                'Più voti e interazioni fai, più sali nella classifica fan',
                'I fan più attivi possono ricevere premi e riconoscimenti dalla redazione!',
              ],
            ),
            _buildSection(
              icon: Icons.history,
              title: '6. Hai Ascoltato',
              items: [
                'Apri il menu laterale e tocca Hai ascoltato',
                'Troverai la cronologia degli ultimi 50 brani ascoltati',
                'Per ogni brano vedrai artista, titolo e orario',
                'Tocca ▶ per ascoltare il brano su Apple Music',
              ],
            ),
            _buildSection(
              icon: Icons.poll,
              title: '7. Sondaggi',
              items: [
                'Apri il menu laterale (☰ in alto a sinistra)',
                'Tocca 📊 Sondaggi',
                'Vedrai i sondaggi attivi — possono essere a scelta singola o voto da 1 a 10',
                'Seleziona la tua risposta e tocca Vota',
                'Dopo il voto vedrai i risultati in tempo reale',
                'Puoi cambiare il tuo voto finché il sondaggio è attivo',
              ],
            ),
            _buildSection(
              icon: Icons.mail_outline,
              title: '8. Scrivici',
              items: [
                'Apri il menu laterale (☰ in alto a sinistra)',
                'Tocca 📨 Scrivici',
                'Inserisci il tuo nome e il messaggio',
                'L\'email è opzionale — inseriscila se vuoi ricevere una risposta',
                'Tocca Invia messaggio e la redazione lo riceverà!',
              ],
            ),
            _buildSection(
              icon: Icons.calendar_today,
              title: '9. Palinsesto e Programmi Preferiti',
              items: [
                'Apri il menu laterale e tocca Palinsesto',
                'Naviga tra i giorni della settimana',
                'Vedi gli orari e i nomi dei programmi',
                'Tocca il ❤️ cuore accanto a un programma per aggiungerlo ai preferiti',
                'Riceverai una notifica automatica prima dell\'inizio del programma',
                'Puoi scegliere quanto tempo prima ricevere la notifica nelle Impostazioni (5, 10, 15 o 30 minuti)',
                'Tocca di nuovo il cuore per rimuovere un programma dai preferiti',
              ],
            ),
            _buildSection(
              icon: Icons.mic,
              title: '10. Shows',
              items: [
                'Apri il menu laterale e tocca Shows',
                'Sfoglia tutti i programmi della radio',
                'Ogni show ha la sua descrizione e immagine',
              ],
            ),
            _buildSection(
              icon: Icons.podcasts,
              title: '11. Podcast',
              items: [
                'Apri il menu laterale e tocca Podcast',
                'Sfoglia gli episodi disponibili',
                'Tocca un episodio per ascoltarlo',
                'Puoi ascoltare i podcast in qualsiasi momento',
              ],
            ),
            _buildSection(
              icon: Icons.settings,
              title: '12. Impostazioni',
              items: [
                'Tema — Scegli tra Chiaro, Scuro o Automatico',
                'Qualità streaming — Alta (320 kbps), Media (256 kbps) o Bassa (128 kbps)',
                'Notifica programmi — Scegli quanto tempo prima ricevere la notifica per i tuoi programmi preferiti',
                'Lingua — Cambia la lingua dell\'app',
              ],
            ),
            _buildSection(
              icon: Icons.notifications,
              title: '13. Notifiche',
              items: [
                'Al primo avvio l\'app ti chiederà il permesso per le notifiche',
                'Accetta per ricevere aggiornamenti dalla redazione',
                'Ti avviseremo di nuovi sondaggi, premi e eventi speciali',
                'I programmi preferiti ti invieranno una notifica automatica prima dell\'inizio',
                'Puoi gestire le notifiche dalle impostazioni del telefono',
              ],
            ),
            const SizedBox(height: 16),
            _buildFaqSection(),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    '📻 Stereo 98 DAB+ — La radio che ti ascolta',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hai altri dubbi? Scrivici direttamente dall\'app!',
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16213E), Color(0xFF1A1A2E)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFD85D9D), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4EC8E8),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    final faqs = [
      {
        'q': 'La radio non parte, cosa faccio?',
        'a': 'Verifica la tua connessione internet (WiFi o dati mobili). Lo streaming richiede una connessione attiva. Prova a chiudere e riaprire l\'app.',
      },
      {
        'q': 'Posso ascoltare con gli auricolari Bluetooth?',
        'a': 'Sì! L\'app supporta tutti i dispositivi Bluetooth. Collega i tuoi auricolari e premi Play.',
      },
      {
        'q': 'L\'app consuma molti dati?',
        'a': 'Dipende dalla qualità scelta nelle Impostazioni: circa 60 MB/ora a 128 kbps, 100 MB/ora a 256 kbps e 140 MB/ora a 320 kbps. Consigliamo l\'uso del WiFi per un ascolto prolungato.',
      },
      {
        'q': 'Ho cambiato telefono, il mio codice fan è cambiato?',
        'a': 'Sì, il codice fan è legato al dispositivo. Se cambi telefono riceverai un nuovo codice. Contattaci tramite "Scrivici" se hai bisogno di assistenza.',
      },
      {
        'q': 'Come trovo le canzoni che ho votato?',
        'a': 'Apri il menu laterale e tocca "Le Mie Canzoni". Troverai tutte le canzoni a cui hai dato la stella, con la possibilità di ascoltarle su Apple Music.',
      },
      {
        'q': 'Come ricevo la notifica per un programma?',
        'a': 'Vai nel Palinsesto e tocca il cuore accanto al programma che ti interessa. Riceverai automaticamente una notifica prima dell\'inizio. Puoi scegliere quanto tempo prima nelle Impostazioni.',
      },
      {
        'q': 'Come posso lasciare una recensione?',
        'a': 'Apri il menu laterale e tocca "Valutaci". Verrai portato direttamente alla pagina dello store per lasciare la tua recensione. Ogni stella conta! ⭐',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16213E), Color(0xFF1A1A2E)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.help_outline, color: Color(0xFFD85D9D), size: 22),
              SizedBox(width: 10),
              Text(
                'Domande Frequenti',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...faqs.map((faq) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq['q']!,
                  style: const TextStyle(
                    color: Color(0xFFD85D9D),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  faq['a']!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
