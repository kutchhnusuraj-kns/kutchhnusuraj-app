import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

const ink = Color(0xFF14110F);
const gold = Color(0xFFC8941A);
const base =
    'https://firestore.googleapis.com/v1/projects/kutchhnusuraj-97c95/databases/(default)/documents';
const site = 'https://kutchhnusuraj-kns.github.io';

// AdMob IDs: abhi TEST IDs che. Real AdMob ID male tyare badlo.
const bannerId = 'ca-app-pub-3940256099942544/6300978111';
const interId = 'ca-app-pub-3940256099942544/1033173712';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  Ads.load();
  runApp(const KnsApp());
}

class Ads {
  static InterstitialAd? _i;
  static int _n = 0;
  static void load() {
    InterstitialAd.load(
      adUnitId: interId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (a) => _i = a, onAdFailedToLoad: (e) => _i = null),
    );
  }

  // darek 4th news kholta full screen ad
  static void maybeShow() {
    _n++;
    final a = _i;
    if (_n % 4 == 0 && a != null) {
      _i = null;
      a.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (x) {
          x.dispose();
          load();
        },
        onAdFailedToShowFullScreenContent: (x, e) {
          x.dispose();
          load();
        },
      );
      a.show();
    } else if (a == null) {
      load();
    }
  }
}

class AdCard extends StatefulWidget {
  const AdCard({super.key});
  @override
  State<AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<AdCard> {
  BannerAd? ad;
  bool ok = false;
  @override
  void initState() {
    super.initState();
    ad = BannerAd(
      adUnitId: bannerId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => ok = true);
        },
        onAdFailedToLoad: (a, e) => a.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ok
      ? Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            const Text('જાહેરાત', style: TextStyle(color: Colors.black45, fontSize: 11)),
            const SizedBox(height: 6),
            SizedBox(width: 300, height: 250, child: AdWidget(ad: ad!)),
          ]),
        )
      : const SizedBox.shrink();
}

class KnsApp extends StatelessWidget {
  const KnsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kutchhnusuraj',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: gold),
          scaffoldBackgroundColor: const Color(0xFFF4F3F0),
        ),
        home: const Boot(),
      );
}

// ---------- Boot: intro first time, short splash after ----------
class Boot extends StatefulWidget {
  const Boot({super.key});
  @override
  State<Boot> createState() => _BootState();
}

class _BootState extends State<Boot> {
  bool? seen;
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getBool('seen') ?? false;
    setState(() => seen = s);
    if (s) {
      await Future.delayed(const Duration(milliseconds: 2600));
      _home();
    }
  }

  void _home() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Home()));
  }

  Future<void> _done() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('seen', true);
    _home();
  }

  @override
  Widget build(BuildContext context) {
    if (seen == null) return const Scaffold(backgroundColor: ink);
    return seen! ? const LogoSplash() : Intro(onDone: _done);
  }
}

// ---------- Animated logo splash ----------
class LogoSplash extends StatefulWidget {
  const LogoSplash({super.key});
  @override
  State<LogoSplash> createState() => _LogoSplashState();
}

class _LogoSplashState extends State<LogoSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))
        ..repeat();
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
            gradient: RadialGradient(
                colors: [Color(0xFF2A2218), ink], radius: 1.0)),
        child: AnimatedBuilder(
          animation: c,
          builder: (_, __) => Stack(alignment: Alignment.center, children: [
            Positioned.fill(child: CustomPaint(painter: Sparks(c.value))),
            Column(mainAxisSize: MainAxisSize.min, children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutBack,
                builder: (_, v, child) => Opacity(
                    opacity: v.clamp(0.0, 1.0),
                    child: Transform.scale(scale: .5 + .5 * v, child: child)),
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(alignment: Alignment.center, children: [
                    CustomPaint(
                        size: const Size(220, 220), painter: Ring(c.value)),
                    Container(
                      width: 170,
                      height: 170,
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Image.asset('logo.png'),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 28),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1800),
                curve: Curves.easeOut,
                builder: (_, v, __) => Opacity(
                  opacity: v,
                  child: Text('KUTCHHNUSURAJ',
                      style: TextStyle(
                          color: gold,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2 + 10 * (1 - v))),
                ),
              ),
              const SizedBox(height: 10),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 2600),
                curve: Curves.easeIn,
                builder: (_, v, __) => Opacity(
                    opacity: v,
                    child: const Text('કચ્છ, ગુજરાત અને દેશની ખબર',
                        style: TextStyle(color: Colors.white70, fontSize: 15))),
              ),
            ]),
          ]),
        ),
      );
}

class Ring extends CustomPainter {
  final double t;
  Ring(this.t);
  @override
  void paint(Canvas cv, Size s) {
    final r = Rect.fromCircle(center: s.center(Offset.zero), radius: s.width / 2 - 4);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..shader = SweepGradient(
        colors: const [Colors.transparent, gold, Colors.transparent],
        transform: GradientRotation(t * 2 * math.pi),
      ).createShader(r);
    cv.drawArc(r, 0, 2 * math.pi, false, p);
  }

  @override
  bool shouldRepaint(Ring o) => o.t != t;
}

class Sparks extends CustomPainter {
  final double t;
  Sparks(this.t);
  @override
  void paint(Canvas cv, Size s) {
    for (int i = 0; i < 28; i++) {
      final x = ((i * 37) % 100) / 100 * s.width;
      final sp = 1 + (i % 3);
      final y = s.height - ((t * sp + i / 28) % 1) * s.height;
      cv.drawCircle(Offset(x, y), 1.0 + (i % 3),
          Paint()..color = gold.withOpacity(.15 + (i % 4) * .1));
    }
  }

  @override
  bool shouldRepaint(Sparks o) => true;
}

// ---------- Intro slides ----------
class Intro extends StatefulWidget {
  final VoidCallback onDone;
  const Intro({super.key, required this.onDone});
  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  final pc = PageController();
  int i = 0;
  Timer? t;
  @override
  void initState() {
    super.initState();
    t = Timer(const Duration(milliseconds: 3400), () {
      if (mounted && i == 0) {
        pc.nextPage(
            duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    t?.cancel();
    pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: ink,
        body: Stack(children: [
          PageView(
            controller: pc,
            onPageChanged: (v) => setState(() => i = v),
            children: const [
              LogoSplash(),
              Slide(
                  title: 'બધી ખબર, એક જગ્યાએ',
                  desc: 'ઇન્ડિયા થી કચ્છ સુધીના સમાચાર, તમારી પસંદની કેટેગરી મુજબ વાંચો.',
                  child: CatPop()),
              Slide(
                  title: 'વિડિયો જુઓ, એપમાં જ',
                  desc: 'YouTube અને Instagram ના વિડિયો સીધા એપમાં પ્લે થાય છે.',
                  child: VideoCards()),
              Slide(
                  title: 'તાજા સમાચાર, સૌથી પહેલા',
                  desc: 'નવી ખબર આવતા જ તમારી સ્ક્રીન પર દેખાય છે.',
                  child: Ticker()),
              Slide(
                  title: 'સબ કેટેગરીથી સચોટ શોધ',
                  desc: 'કચ્છમાં ભુજ, ભચાઉ, અંજાર જેવા વિસ્તાર મુજબ સમાચાર મેળવો.',
                  child: SubTree()),
            ],
          ),
          Positioned(
            top: 44,
            right: 16,
            child: TextButton(
                onPressed: widget.onDone,
                child: const Text('Skip', style: TextStyle(color: Colors.white70))),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Column(children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      5,
                      (k) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: k == i ? 26 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: k == i ? gold : Colors.white24,
                                borderRadius: BorderRadius.circular(4)),
                          ))),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: ink,
                    minimumSize: const Size(220, 50)),
                onPressed: () => i == 4
                    ? widget.onDone()
                    : pc.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut),
                child: Text(i == 4 ? 'શરૂ કરો' : 'આગળ',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ]),
          ),
        ]),
      );
}

class Slide extends StatelessWidget {
  final String title, desc;
  final Widget child;
  const Slide({super.key, required this.title, required this.desc, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        color: ink,
        padding: const EdgeInsets.fromLTRB(28, 90, 28, 150),
        child: Column(children: [
          Expanded(child: Center(child: child)),
          const SizedBox(height: 24),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
        ]),
      );
}

Widget pop(int i, Widget w) => TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: Interval(i * .12, 1, curve: Curves.easeOutBack),
      builder: (_, v, c) => Opacity(
          opacity: v.clamp(0.0, 1.0), child: Transform.scale(scale: v, child: c)),
      child: w,
    );

class Pulse extends StatefulWidget {
  final Widget child;
  const Pulse({super.key, required this.child});
  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true);
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
      scale: Tween(begin: .88, end: 1.12)
          .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
      child: widget.child);
}

const cats = ['INDIA', 'GUJARAT', 'KUTCH', 'CRIME', 'POLITICS'];
const catIcons = [
  Icons.public,
  Icons.location_city,
  Icons.landscape,
  Icons.gavel,
  Icons.account_balance,
];

class CatPop extends StatelessWidget {
  const CatPop({super.key});
  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 14,
        children: List.generate(
            5,
            (i) => pop(
                i,
                Container(
                  width: 130,
                  height: 90,
                  decoration: BoxDecoration(
                      border: Border.all(color: gold, width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0xFF211C16)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(catIcons[i], color: gold, size: 30),
                    const SizedBox(height: 6),
                    Text(cats[i],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1)),
                  ]),
                ))),
      );
}

class VideoCards extends StatelessWidget {
  const VideoCards({super.key});
  Widget card(String name, List<Color> g) => Container(
        width: 270,
        height: 110,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: g),
            borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          const SizedBox(width: 22),
          const Pulse(child: Icon(Icons.play_circle_fill, size: 58, color: Colors.white)),
          const SizedBox(width: 16),
          Text(name,
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        ]),
      );
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        pop(0, card('YouTube', const [Color(0xFFD32F2F), Color(0xFFFF5252)])),
        const SizedBox(height: 22),
        pop(2, card('Instagram', const [Color(0xFF8E24AA), Color(0xFFFF7043)])),
      ]);
}

class Ticker extends StatefulWidget {
  const Ticker({super.key});
  @override
  State<Ticker> createState() => _TickerState();
}

class _TickerState extends State<Ticker> {
  final sc = ScrollController();
  Timer? t;
  static const items = ['BREAKING', 'કચ્છ', 'ગુજરાત', 'ઇન્ડિયા', 'ક્રાઇમ', 'પોલિટિક્સ'];
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (sc.hasClients) sc.jumpTo(sc.offset + 1.6);
    });
  }

  @override
  void dispose() {
    t?.cancel();
    sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        Pulse(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
                color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(30)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.circle, size: 12, color: Colors.white),
              SizedBox(width: 8),
              Text('LIVE',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
            ]),
          ),
        ),
        const SizedBox(height: 26),
        Container(
          height: 58,
          decoration: BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide(color: gold, width: 1.5))),
          child: ListView.builder(
            controller: sc,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) => Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(items[i % items.length],
                  style: const TextStyle(
                      color: gold, fontSize: 20, fontWeight: FontWeight.w800)),
            )),
          ),
        ),
      ]);
}

class SubTree extends StatelessWidget {
  const SubTree({super.key});
  Widget chip(String s, {bool big = false}) => Container(
        padding: EdgeInsets.symmetric(horizontal: big ? 30 : 18, vertical: big ? 14 : 10),
        decoration: BoxDecoration(
            color: big ? gold : const Color(0xFF211C16),
            border: Border.all(color: gold),
            borderRadius: BorderRadius.circular(30)),
        child: Text(s,
            style: TextStyle(
                color: big ? ink : Colors.white,
                fontSize: big ? 22 : 17,
                fontWeight: FontWeight.w800)),
      );
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        pop(0, chip('KUTCH', big: true)),
        pop(1, const Icon(Icons.keyboard_double_arrow_down, color: gold, size: 40)),
        Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: [
          pop(2, chip('ભુજ')),
          pop(3, chip('ભચાઉ')),
          pop(4, chip('અંજાર')),
          pop(5, chip('માંડવી')),
        ]),
      ]);
}

// ---------- Data (Firestore REST, public read) ----------
Future<List<Map<String, String>>> fetch(String col) async {
  final r = await http.get(Uri.parse('$base/$col?pageSize=300'));
  if (r.statusCode != 200) throw Exception('HTTP ${r.statusCode}');
  final docs = (jsonDecode(r.body)['documents'] as List?) ?? [];
  return docs.map<Map<String, String>>((d) {
    final f = (d['fields'] as Map?) ?? {};
    final m = <String, String>{'id': (d['name'] as String).split('/').last};
    f.forEach((k, v) => m[k as String] = (v as Map).values.first.toString());
    return m;
  }).toList();
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, String>> cs = [], subs = [], posts = [];
  bool loading = true;
  String? err, cat, sub;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      err = null;
    });
    try {
      final r = await Future.wait([fetch('categories'), fetch('subcategories'), fetch('posts')]);
      cs = r[0]
        ..sort((a, b) => (int.tryParse(a['order'] ?? '0') ?? 0)
            .compareTo(int.tryParse(b['order'] ?? '0') ?? 0));
      subs = r[1];
      posts = r[2]..sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
    } catch (e) {
      err = 'Data load na thayo. Internet check karo.';
    }
    if (mounted) setState(() => loading = false);
  }

  String catName(String? id) =>
      cs.firstWhere((c) => c['id'] == id, orElse: () => {'name': ''})['name'] ?? '';

  @override
  Widget build(BuildContext context) {
    final list = posts
        .where((p) =>
            (cat == null || p['categoryId'] == cat) &&
            (sub == null || p['subCategoryId'] == sub))
        .toList();
    final subList = subs.where((s) => s['categoryId'] == cat).toList();
    final rows = <int>[];
    for (int k = 0; k < list.length; k++) {
      rows.add(k);
      if ((k + 1) % 4 == 0) rows.add(-1);
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ink,
        title: Row(children: [
          Container(
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Image.asset('logo.png')),
          const SizedBox(width: 10),
          const Text('KUTCHHNUSURAJ',
              style: TextStyle(color: gold, fontWeight: FontWeight.w800, letterSpacing: 1)),
        ]),
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh, color: Colors.white))
        ],
      ),
      body: Column(children: [
        if (!loading && err == null)
          NewsTicker(
            items: posts.take(8).toList(),
            onTap: (p) => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => Detail(p: p, cat: catName(p['categoryId'])))),
          ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            children: [
              chip('ALL', cat == null, () => setState(() {
                    cat = null;
                    sub = null;
                  })),
              for (final c in cs)
                chip(c['name'] ?? '', cat == c['id'], () => setState(() {
                      cat = c['id'];
                      sub = null;
                    })),
            ],
          ),
        ),
        if (subList.isNotEmpty)
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                for (final s in subList)
                  chip(s['name'] ?? '', sub == s['id'],
                      () => setState(() => sub = sub == s['id'] ? null : s['id'])),
              ],
            ),
          ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator(color: gold))
              : err != null
                  ? Center(child: Text(err!))
                  : RefreshIndicator(
                      onRefresh: load,
                      child: list.isEmpty
                          ? ListView(children: const [
                              SizedBox(height: 120),
                              Center(child: Text('Haji koi news nathi.'))
                            ])
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: rows.length,
                              itemBuilder: (_, r) {
                                final i = rows[r];
                                if (i < 0) return const AdCard();
                                return NewsCard(
                                    big: i == 0,
                                    p: list[i],
                                    cat: catName(list[i]['categoryId']),
                                    onTap: () {
                                      Ads.maybeShow();
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (_) => Detail(
                                              p: list[i], cat: catName(list[i]['categoryId']))));
                                    });
                              }),
                    ),
        ),
      ]),
    );
  }

  Widget chip(String label, bool on, VoidCallback f) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label,
              style: TextStyle(fontWeight: FontWeight.w700, color: on ? ink : Colors.black87)),
          selected: on,
          selectedColor: gold,
          onSelected: (_) => f(),
        ),
      );
}

String fdate(String? iso) {
  final d = DateTime.tryParse(iso ?? '');
  if (d == null) return '';
  final l = d.toLocal();
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${l.day} ${m[l.month - 1]} ${l.year}';
}

List<String> imgsOf(Map<String, String> p) {
  final s = (p['images'] ?? '')
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  if (s.isEmpty && (p['imageUrl'] ?? '').isNotEmpty) s.add(p['imageUrl']!);
  return s;
}

Widget badge(String t) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(4)),
      child: Text(t,
          style: const TextStyle(
              color: ink, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .8)),
    );

Widget netImg(String u) => ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(u,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          loadingBuilder: (c, w, pr) => pr == null
              ? w
              : Container(
                  height: 200,
                  color: Colors.black12,
                  child: const Center(
                      child: CircularProgressIndicator(color: gold, strokeWidth: 2)))),
    );

class NewsCard extends StatelessWidget {
  final Map<String, String> p;
  final String cat;
  final VoidCallback onTap;
  final bool big;
  const NewsCard(
      {super.key, required this.p, required this.cat, required this.onTap, this.big = false});
  @override
  Widget build(BuildContext context) {
    final imgs = imgsOf(p);
    final hasVideo = (p['videoUrl'] ?? '').isNotEmpty;
    final desc = (p['description'] ?? '').replaceAll(RegExp(r'\[img\d+\]'), '').trim();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (imgs.isNotEmpty)
            Stack(children: [
              AspectRatio(
                aspectRatio: big ? 16 / 10 : 16 / 9,
                child: Image.network(imgs.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: ink)),
              ),
              Positioned.fill(
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(.45)])))),
              Positioned(left: 12, top: 12, child: badge(cat)),
              if (hasVideo)
                const Positioned.fill(
                    child: Center(
                        child: Icon(Icons.play_circle_fill, color: Colors.white, size: 58))),
              if (imgs.length > 1)
                Positioned(
                    right: 12,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        const Icon(Icons.photo_library, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('${imgs.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ]),
                    )),
            ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (imgs.isEmpty) ...[badge(cat), const SizedBox(height: 10)],
              Text(p['title'] ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: big ? 22 : 19, fontWeight: FontWeight.w800, height: 1.3)),
              if (desc.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(desc,
                    maxLines: big ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 15, height: 1.45)),
              ],
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.access_time, size: 15, color: Colors.black45),
                const SizedBox(width: 5),
                Text(fdate(p['createdAt']),
                    style: const TextStyle(color: Colors.black54, fontSize: 13)),
                const Spacer(),
                const Text('વાંચો ',
                    style: TextStyle(color: gold, fontWeight: FontWeight.w800)),
                const Icon(Icons.arrow_forward, size: 16, color: gold),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class Detail extends StatefulWidget {
  final Map<String, String> p;
  final String cat;
  const Detail({super.key, required this.p, required this.cat});
  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  WebViewController? wc;
  double ratio = .5625;
  String frame(String src) =>
      '<html><head><meta name="viewport" content="width=device-width,initial-scale=1">'
      '<style>html,body{margin:0;height:100%;background:#000}iframe{width:100%;height:100%;border:0}</style></head>'
      '<body><iframe src="$src" allow="autoplay; encrypted-media; fullscreen" allowfullscreen></iframe></body></html>';
  @override
  void initState() {
    super.initState();
    final u = widget.p['videoUrl'] ?? '';
    String? html;
    final y = RegExp(r'(?:v=|youtu\.be/|shorts/|embed/)([\w-]{11})').firstMatch(u);
    final ig = RegExp(r'instagram\.com/(p|reel|reels|tv)/([\w-]+)').firstMatch(u);
    if (y != null) {
      html = frame('https://www.youtube.com/embed/${y.group(1)}?playsinline=1&rel=0');
    } else if (ig != null) {
      final k = ig.group(1) == 'reels' ? 'reel' : ig.group(1);
      ratio = 1.5;
      html = frame('https://www.instagram.com/$k/${ig.group(2)}/embed');
    }
    if (html != null) {
      wc = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString(html, baseUrl: site);
    }
  }

  Widget imgBlock(String u) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: netImg(u));

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final imgs = imgsOf(p);
    final w = MediaQuery.of(context).size.width;
    final marker = RegExp(r'^\[img(\d+)\]$');
    final paras = (p['description'] ?? '')
        .split(RegExp(r'\n+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final used = <int>{};
    for (final s in paras) {
      final m = marker.firstMatch(s);
      if (m != null) used.add(int.parse(m.group(1)!));
    }
    final free = [
      for (int k = 2; k <= imgs.length; k++)
        if (!used.contains(k)) k
    ];
    final body = <Widget>[];
    int fi = 0;
    for (final s in paras) {
      final m = marker.firstMatch(s);
      if (m != null) {
        final n = int.parse(m.group(1)!);
        if (n >= 1 && n <= imgs.length) body.add(imgBlock(imgs[n - 1]));
        continue;
      }
      body.add(Text(s, style: const TextStyle(fontSize: 18, height: 1.7)));
      body.add(const SizedBox(height: 8));
      if (fi < free.length) {
        body.add(imgBlock(imgs[free[fi] - 1]));
        fi++;
      }
    }
    while (fi < free.length) {
      body.add(imgBlock(imgs[free[fi] - 1]));
      fi++;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: ink,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('KUTCHHNUSURAJ',
              style: TextStyle(color: gold, fontWeight: FontWeight.w800, letterSpacing: 1))),
      body: ListView(children: [
        if (wc != null)
          SizedBox(height: w * ratio, child: WebViewWidget(controller: wc!))
        else if (imgs.isNotEmpty)
          Image.network(imgs.first,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            badge(widget.cat),
            const SizedBox(height: 12),
            Text(p['title'] ?? '',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.3)),
            const SizedBox(height: 14),
            Row(children: [
              Container(
                  width: 30,
                  height: 30,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: gold)),
                  child: Image.asset('logo.png')),
              const SizedBox(width: 10),
              const Text('KUTCHHNUSURAJ',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const Text('  •  ', style: TextStyle(color: Colors.black38)),
              Text(fdate(p['createdAt']),
                  style: const TextStyle(color: Colors.black54, fontSize: 13)),
            ]),
            const SizedBox(height: 14),
            Container(height: 3, width: 60, color: gold),
            const SizedBox(height: 18),
            ...body,
          ]),
        ),
      ]),
    );
  }
}

// ---------- Latest news ticker (Home) ----------
class NewsTicker extends StatefulWidget {
  final List<Map<String, String>> items;
  final void Function(Map<String, String>) onTap;
  const NewsTicker({super.key, required this.items, required this.onTap});
  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> {
  final sc = ScrollController();
  Timer? t;
  @override
  void initState() {
    super.initState();
    t = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (sc.hasClients) sc.jumpTo(sc.offset + 1.2);
    });
  }

  @override
  void dispose() {
    t?.cancel();
    sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final it = widget.items;
    if (it.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 40,
      color: ink,
      child: Row(children: [
        Container(
          color: const Color(0xFFD32F2F),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: const Pulse(
            child: Text('LATEST',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: sc,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) {
              final p = it[i % it.length];
              return GestureDetector(
                onTap: () => widget.onTap(p),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(children: [
                      const Icon(Icons.circle, size: 7, color: gold),
                      const SizedBox(width: 8),
                      Text(p['title'] ?? '',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
