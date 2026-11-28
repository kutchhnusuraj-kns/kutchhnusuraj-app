import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

const ink = Color(0xFF14110F);
const gold = Color(0xFFC8941A);
const base =
    'https://firestore.googleapis.com/v1/projects/kutchhnusuraj-97c95/databases/(default)/documents';
const site = 'https://kutchhnusuraj-kns.github.io';

// Ads abhi band che (test mate). Pachhi ek ek karine add karishu.
void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const KnsApp());
  }, (e, s) {});
}

class KnsApp extends StatelessWidget {
  const KnsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kutchhnusuraj',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Hind',
          colorScheme: ColorScheme.fromSeed(seedColor: red),
          scaffoldBackgroundColor: bgc,
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
        MaterialPageRoute(builder: (_) => const Shell()));
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
                    child: const Text('\u0A95\u0A9A\u0ACD\u0A9B, \u0A97\u0AC1\u0A9C\u0AB0\u0ABE\u0AA4 \u0A85\u0AA8\u0AC7 \u0AA6\u0AC7\u0AB6\u0AA8\u0AC0 \u0A96\u0AAC\u0AB0',
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
                  title: '\u0AAC\u0AA7\u0AC0 \u0A96\u0AAC\u0AB0, \u0A8F\u0A95 \u0A9C\u0A97\u0ACD\u0AAF\u0ABE\u0A8F',
                  desc: '\u0A87\u0AA8\u0ACD\u0AA1\u0ABF\u0AAF\u0ABE \u0AA5\u0AC0 \u0A95\u0A9A\u0ACD\u0A9B \u0AB8\u0AC1\u0AA7\u0AC0\u0AA8\u0ABE \u0AB8\u0AAE\u0ABE\u0A9A\u0ABE\u0AB0, \u0AA4\u0AAE\u0ABE\u0AB0\u0AC0 \u0AAA\u0AB8\u0A82\u0AA6\u0AA8\u0AC0 \u0A95\u0AC7\u0A9F\u0AC7\u0A97\u0AB0\u0AC0 \u0AAE\u0AC1\u0A9C\u0AAC \u0AB5\u0ABE\u0A82\u0A9A\u0ACB.',
                  child: CatPop()),
              Slide(
                  title: '\u0AB5\u0ABF\u0AA1\u0ABF\u0AAF\u0ACB \u0A9C\u0AC1\u0A93, \u0A8F\u0AAA\u0AAE\u0ABE\u0A82 \u0A9C',
                  desc: 'YouTube \u0A85\u0AA8\u0AC7 Instagram \u0AA8\u0ABE \u0AB5\u0ABF\u0AA1\u0ABF\u0AAF\u0ACB \u0AB8\u0AC0\u0AA7\u0ABE \u0A8F\u0AAA\u0AAE\u0ABE\u0A82 \u0AAA\u0ACD\u0AB2\u0AC7 \u0AA5\u0ABE\u0AAF \u0A9B\u0AC7.',
                  child: VideoCards()),
              Slide(
                  title: '\u0AA4\u0ABE\u0A9C\u0ABE \u0AB8\u0AAE\u0ABE\u0A9A\u0ABE\u0AB0, \u0AB8\u0ACC\u0AA5\u0AC0 \u0AAA\u0AB9\u0AC7\u0AB2\u0ABE',
                  desc: '\u0AA8\u0AB5\u0AC0 \u0A96\u0AAC\u0AB0 \u0A86\u0AB5\u0AA4\u0ABE \u0A9C \u0AA4\u0AAE\u0ABE\u0AB0\u0AC0 \u0AB8\u0ACD\u0A95\u0ACD\u0AB0\u0AC0\u0AA8 \u0AAA\u0AB0 \u0AA6\u0AC7\u0A96\u0ABE\u0AAF \u0A9B\u0AC7.',
                  child: Ticker()),
              Slide(
                  title: '\u0AB8\u0AAC \u0A95\u0AC7\u0A9F\u0AC7\u0A97\u0AB0\u0AC0\u0AA5\u0AC0 \u0AB8\u0A9A\u0ACB\u0A9F \u0AB6\u0ACB\u0AA7',
                  desc: '\u0A95\u0A9A\u0ACD\u0A9B\u0AAE\u0ABE\u0A82 \u0AAD\u0AC1\u0A9C, \u0AAD\u0A9A\u0ABE\u0A89, \u0A85\u0A82\u0A9C\u0ABE\u0AB0 \u0A9C\u0AC7\u0AB5\u0ABE \u0AB5\u0ABF\u0AB8\u0ACD\u0AA4\u0ABE\u0AB0 \u0AAE\u0AC1\u0A9C\u0AAC \u0AB8\u0AAE\u0ABE\u0A9A\u0ABE\u0AB0 \u0AAE\u0AC7\u0AB3\u0AB5\u0ACB.',
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
                child: Text(i == 4 ? '\u0AB6\u0AB0\u0AC2 \u0A95\u0AB0\u0ACB' : '\u0A86\u0A97\u0AB3',
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
  static const items = ['BREAKING', '\u0A95\u0A9A\u0ACD\u0A9B', '\u0A97\u0AC1\u0A9C\u0AB0\u0ABE\u0AA4', '\u0A87\u0AA8\u0ACD\u0AA1\u0ABF\u0AAF\u0ABE', '\u0A95\u0ACD\u0AB0\u0ABE\u0A87\u0AAE', '\u0AAA\u0ACB\u0AB2\u0ABF\u0A9F\u0ABF\u0A95\u0ACD\u0AB8'];
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
          pop(2, chip('\u0AAD\u0AC1\u0A9C')),
          pop(3, chip('\u0AAD\u0A9A\u0ABE\u0A89')),
          pop(4, chip('\u0A85\u0A82\u0A9C\u0ABE\u0AB0')),
          pop(5, chip('\u0AAE\u0ABE\u0A82\u0AA1\u0AB5\u0AC0')),
        ]),
      ]);
}

// ---------- Design colors (red / white) ----------
const red = Color(0xFFB70011);
const redC = Color(0xFFDC2626);
const bgc = Color(0xFFFAF8FF);
const onSurf = Color(0xFF131B2E);
const outV = Color(0xFFE6BDB8);
const muted = Color(0xFF5C403C);

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

const wPlaces = [
  ('\u0AAD\u0AC1\u0A9C', 23.242, 69.667),
  ('\u0A97\u0ABE\u0A82\u0AA7\u0AC0\u0AA7\u0ABE\u0AAE', 23.075, 70.134),
  ('\u0AAE\u0ABE\u0A82\u0AA1\u0AB5\u0AC0', 22.833, 69.350),
  ('\u0A85\u0A82\u0A9C\u0ABE\u0AB0', 23.113, 70.027),
  ('\u0AAD\u0A9A\u0ABE\u0A89', 23.290, 70.340),
  ('\u0AAE\u0AC1\u0AA8\u0ACD\u0AA6\u0ACD\u0AB0\u0ABE', 22.839, 69.722),
];

String wIcon(int c) => c == 0
    ? '\u2600\uFE0F'
    : c <= 3
        ? '\u26C5'
        : c <= 48
            ? '\u{1F32B}\uFE0F'
            : c <= 67
                ? '\u{1F327}\uFE0F'
                : c <= 77
                    ? '\u2744\uFE0F'
                    : c <= 82
                        ? '\u{1F326}\uFE0F'
                        : '\u26C8\uFE0F';

Future<List<Map<String, String>>> fetchWeather() async {
  final lat = wPlaces.map((p) => p.$2).join(',');
  final lon = wPlaces.map((p) => p.$3).join(',');
  final r = await http.get(Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code&timezone=Asia%2FKolkata'));
  if (r.statusCode != 200) throw Exception('HTTP ${r.statusCode}');
  final j = jsonDecode(r.body);
  final list = j is List ? j : [j];
  return [
    for (int i = 0; i < list.length && i < wPlaces.length; i++)
      {
        'name': wPlaces[i].$1,
        'temp': '${(list[i]['current']['temperature_2m'] as num).round()}',
        'icon': wIcon((list[i]['current']['weather_code'] as num).toInt()),
      }
  ];
}

class Store extends ChangeNotifier {
  List<Map<String, String>> cs = [], subs = [], posts = [], shorts = [], weather = [];
  Set<String> saved = {};
  Set<String> likedShorts = {};
  bool loading = true;
  String? err;

  Future<void> load() async {
    loading = true;
    err = null;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      saved = (p.getStringList('saved') ?? []).toSet();
      likedShorts = (p.getStringList('liked') ?? []).toSet();
      final r = await Future.wait([
        fetch('categories'),
        fetch('subcategories'),
        fetch('posts'),
        fetch('shorts').catchError((_) => <Map<String, String>>[]),
        fetchWeather().catchError((_) => <Map<String, String>>[]),
      ]);
      int ord(Map<String, String> m) => int.tryParse(m['order'] ?? '0') ?? 0;
      int newer(Map<String, String> a, Map<String, String> b) =>
          (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? '');
      cs = r[0]..sort((a, b) => ord(a).compareTo(ord(b)));
      subs = r[1];
      bool live(Map<String, String> m) => (m['status'] ?? 'approved') == 'approved';
      posts = r[2].where(live).toList()..sort(newer);
      shorts = r[3].where(live).toList()..sort(newer);
      weather = r[4];
    } catch (e) {
      err = 'Data load na thayo. Internet check karo.';
    }
    loading = false;
    notifyListeners();
  }

  Future<void> toggleSave(String id) async {
    saved.contains(id) ? saved.remove(id) : saved.add(id);
    final p = await SharedPreferences.getInstance();
    await p.setStringList('saved', saved.toList());
    notifyListeners();
  }

  // real like count: shared in Firestore, one like per device
  Future<void> toggleLike(Map<String, String> s) async {
    final id = s['id']!;
    final wasLiked = likedShorts.contains(id);
    final d = wasLiked ? -1 : 1;
    void apply(int x) {
      x > 0 ? likedShorts.add(id) : likedShorts.remove(id);
      final n = (int.tryParse(s['likes'] ?? '0') ?? 0) + x;
      s['likes'] = (n < 0 ? 0 : n).toString();
    }

    apply(d);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setStringList('liked', likedShorts.toList());
    try {
      final r = await http.post(Uri.parse('$base:commit'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'writes': [
              {
                'transform': {
                  'document': 'projects/kutchhnusuraj-97c95/databases/(default)/documents/shorts/$id',
                  'fieldTransforms': [
                    {
                      'fieldPath': 'likes',
                      'increment': {'integerValue': '$d'}
                    }
                  ]
                }
              }
            ]
          }));
      if (r.statusCode != 200) throw Exception(r.body);
    } catch (_) {
      apply(-d);
      await p.setStringList('liked', likedShorts.toList());
      notifyListeners();
    }
  }

  String catName(String? id) =>
      cs.firstWhere((c) => c['id'] == id, orElse: () => {'name': ''})['name'] ?? '';
}

final store = Store();

// ---------- Helpers ----------
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: red, borderRadius: BorderRadius.circular(4)),
      child: Text(t,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .6)),
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
                  child: const Center(child: CircularProgressIndicator(color: red, strokeWidth: 2)))),
    );

class Embed {
  final String html;
  final double ratio;
  Embed(this.html, this.ratio);
}

String frame(String src) =>
    '<html><head><meta name="viewport" content="width=device-width,initial-scale=1">'
    '<style>html,body{margin:0;height:100%;background:#000}iframe{width:100%;height:100%;border:0}</style></head>'
    '<body><iframe src="$src" allow="autoplay; encrypted-media; fullscreen" allowfullscreen></iframe></body></html>';

Embed? embedOf(String u, {bool auto = false}) {
  final y = RegExp(r'(?:v=|youtu\.be/|shorts/|embed/)([\w-]{11})').firstMatch(u);
  if (y != null) {
    final id = y.group(1);
    final extra = auto ? '&autoplay=1&mute=1&loop=1&playlist=$id' : '';
    return Embed(frame('https://www.youtube.com/embed/$id?playsinline=1&rel=0$extra'), .5625);
  }
  final ig = RegExp(r'instagram\.com/(p|reel|reels|tv)/([\w-]+)').firstMatch(u);
  if (ig != null) {
    final k = ig.group(1) == 'reels' ? 'reel' : ig.group(1);
    return Embed(frame('https://www.instagram.com/$k/${ig.group(2)}/embed'), 1.5);
  }
  return null;
}

WebViewController webFor(String html) => WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..loadHtmlString(html, baseUrl: site);

void shareText(String t) => SharePlus.instance.share(ShareParams(text: t));

class ShortSrc {
  final String type;
  final String html;
  ShortSrc(this.type, this.html);
}

ShortSrc? shortOf(String u) {
  final y = RegExp(r'(?:v=|youtu\.be/|shorts/|embed/)([\w-]{11})').firstMatch(u);
  if (y != null) {
    final id = y.group(1);
    return ShortSrc('yt',
        '<html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>html,body{margin:0;height:100%;background:#000;overflow:hidden}#p{position:absolute;top:0;left:0;width:100%;height:100%}</style></head><body><div id="p"></div><script src="https://www.youtube.com/iframe_api"></script><script>var pl;function onYouTubeIframeAPIReady(){pl=new YT.Player("p",{width:"100%",height:"100%",videoId:"$id",playerVars:{autoplay:1,controls:0,playsinline:1,rel:0,modestbranding:1,fs:0,iv_load_policy:3,disablekb:1},events:{onReady:function(e){e.target.playVideo();},onStateChange:function(e){if(e.data===0){Ended.postMessage("end");}},onError:function(e){Ended.postMessage("err");}}});}function toggle(){if(!pl)return;var s=pl.getPlayerState();if(s===1){pl.pauseVideo();}else{pl.playVideo();}}</script></body></html>');
  }
  if (RegExp(r'\.(mp4|webm|mov)(\?|$)', caseSensitive: false).hasMatch(u) || u.contains('/video/upload/')) {
    return ShortSrc('video',
        '<html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>html,body{margin:0;height:100%;background:#000;overflow:hidden}video{width:100%;height:100%;object-fit:contain}</style></head><body><video id="v" src="$u" autoplay playsinline onended="Ended.postMessage(\'end\')" onerror="Ended.postMessage(\'err\')"></video><script>function toggle(){var v=document.getElementById("v");if(v.paused){v.play();}else{v.pause();}}</script></body></html>');
  }
  final ig = RegExp(r'instagram\.com/(p|reel|reels|tv)/([\w-]+)').firstMatch(u);
  if (ig != null) {
    final k = ig.group(1) == 'reels' ? 'reel' : ig.group(1);
    return ShortSrc('ig',
        '<html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>html,body{margin:0;height:100%;background:#000;overflow:hidden}#w{position:absolute;left:0;right:0;top:0;bottom:0;overflow:hidden}iframe{position:absolute;left:0;top:-58px;width:100%;height:calc(100% + 400px);border:0}</style></head><body><div id="w"><iframe src="https://www.instagram.com/$k/${ig.group(2)}/embed" allow="autoplay; encrypted-media; fullscreen"></iframe></div></body></html>');
  }
  return null;
}

WebViewController shortWeb(ShortSrc s, VoidCallback onEnd) {
  final c = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.black)
    ..addJavaScriptChannel('Ended', onMessageReceived: (_) => onEnd());
  final p = c.platform;
  if (p is AndroidWebViewController) p.setMediaPlaybackRequiresUserGesture(false);
  c.loadHtmlString(s.html, baseUrl: site);
  return c;
}

void snack(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m), duration: const Duration(seconds: 2)));

void openPost(BuildContext c, Map<String, String> p) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => Detail(p: p)));

PreferredSizeWidget kAppBar() => AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      titleSpacing: 12,
      title: Row(children: [
        Container(
            width: 34,
            height: 34,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle, border: Border.all(color: outV)),
            child: Image.asset('logo.png')),
        const SizedBox(width: 10),
        const Text('KUTCHHNUSURAJ',
            style: TextStyle(color: red, fontWeight: FontWeight.w800, letterSpacing: .5, fontSize: 18)),
        const SizedBox(width: 8),
        Pulse(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: redC, borderRadius: BorderRadius.circular(4)),
            child: const Text('LIVE',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
      actions: [
        IconButton(onPressed: store.load, icon: const Icon(Icons.refresh, color: onSurf))
      ],
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: outV.withOpacity(.5))),
    );

class Pill extends StatelessWidget {
  final String t;
  final bool on;
  final VoidCallback f;
  const Pill(this.t, this.on, this.f, {super.key});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: f,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
              color: on ? red : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: on ? red : outV)),
          child: Text(t,
              style: TextStyle(
                  color: on ? Colors.white : onSurf, fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      );
}

Widget feed(BuildContext context, List<Map<String, String>> list,
    {String empty = 'Haji koi news nathi.'}) {
  if (store.loading) return const Center(child: CircularProgressIndicator(color: red));
  if (store.err != null) return Center(child: Text(store.err!));
  return RefreshIndicator(
    color: red,
    onRefresh: store.load,
    child: list.isEmpty
        ? ListView(children: [const SizedBox(height: 120), Center(child: Text(empty))])
        : ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: list.length,
            itemBuilder: (_, i) => NewsCard(p: list[i], big: i == 0)),
  );
}

// ---------- Breaking ticker ----------
class Breaking extends StatefulWidget {
  final List<Map<String, String>> items;
  const Breaking({super.key, required this.items});
  @override
  State<Breaking> createState() => _BreakingState();
}

class _BreakingState extends State<Breaking> {
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
      height: 38,
      color: redC,
      child: Row(children: [
        Container(
          color: const Color(0xFF93000B),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: const Text('\u0AAC\u0ACD\u0AB0\u0AC7\u0A95\u0ABF\u0A82\u0A97',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
        ),
        Expanded(
          child: ListView.builder(
            controller: sc,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) {
              final p = it[i % it.length];
              return GestureDetector(
                onTap: () => openPost(context, p),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('\u2022  ${p['title'] ?? ''}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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

// ---------- Shell with bottom bar ----------
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeTab(),
      const KutchTab(),
      ShortsTab(onClose: () => setState(() => tab = 0)),
      const SavedTab(),
      const EpaperTab(),
    ];
    return Scaffold(
      body: pages[tab],
      bottomNavigationBar: tab == 2 ? null : NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFFDAD6),
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: red), label: '\u0AB9\u0ACB\u0AAE'),
          NavigationDestination(
              icon: Icon(Icons.location_on_outlined),
              selectedIcon: Icon(Icons.location_on, color: red),
              label: '\u0A95\u0A9A\u0ACD\u0A9B'),
          NavigationDestination(
              icon: Icon(Icons.play_circle_outline),
              selectedIcon: Icon(Icons.play_circle, color: red),
              label: '\u0AB6\u0ACB\u0AB0\u0ACD\u0A9F\u0ACD\u0AB8'),
          NavigationDestination(
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.bookmark, color: red),
              label: '\u0AB8\u0ABE\u0A9A\u0AB5\u0AC7\u0AB2'),
          NavigationDestination(
              icon: Icon(Icons.newspaper_outlined),
              selectedIcon: Icon(Icons.newspaper, color: red),
              label: '\u0A88-\u0AAA\u0AC7\u0AAA\u0AB0'),
        ],
      ),
    );
  }
}

class WeatherStrip extends StatelessWidget {
  final List<Map<String, String>> items;
  const WeatherStrip({super.key, required this.items});
  @override
  Widget build(BuildContext context) => Container(
        height: 42,
        color: Colors.white,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            const Center(
                child: Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Text('\u0AAE\u0ACC\u0AB8\u0AAE',
                        style: TextStyle(color: red, fontWeight: FontWeight.w800, fontSize: 13)))),
            for (final w in items)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF3F4FA), borderRadius: BorderRadius.circular(14)),
                  child: Text('${w['name']}  ${w['icon']} ${w['temp']}\u00B0',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: onSurf)),
                ),
              ),
          ],
        ),
      );
}

// ---------- Home ----------
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? cat;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (_, __) {
          final list = store.posts.where((p) => cat == null || p['categoryId'] == cat).toList();
          return Scaffold(
            backgroundColor: bgc,
            appBar: kAppBar(),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: red,
              foregroundColor: Colors.white,
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubmitPage())),
              icon: const Icon(Icons.add),
              label: const Text('\u0AB8\u0AAE\u0ABE\u0A9A\u0ABE\u0AB0 \u0AAE\u0ACB\u0A95\u0AB2\u0ACB'),
            ),
            body: Column(children: [
              if (!store.loading && store.err == null)
                Breaking(items: store.posts.take(8).toList()),
              if (!store.loading && store.weather.isNotEmpty) WeatherStrip(items: store.weather),
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                  children: [
                    Pill('\u0AAC\u0AA7\u0ABE \u0AB8\u0AAE\u0ABE\u0A9A\u0ABE\u0AB0', cat == null, () => setState(() => cat = null)),
                    for (final c in store.cs)
                      Pill(c['name'] ?? '', cat == c['id'], () => setState(() => cat = c['id'])),
                  ],
                ),
              ),
              Expanded(child: feed(context, list)),
            ]),
          );
        },
      );
}

// ---------- Kutch hub ----------
class KutchTab extends StatefulWidget {
  const KutchTab({super.key});
  @override
  State<KutchTab> createState() => _KutchTabState();
}

class _KutchTabState extends State<KutchTab> {
  String? sub;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (_, __) {
          final kid = store.cs.firstWhere((c) => (c['name'] ?? '').toUpperCase() == 'KUTCH',
              orElse: () => {'id': 'kutch'})['id'];
          final talukas = store.subs.where((s) => s['categoryId'] == kid).toList();
          final list = store.posts
              .where((p) => p['categoryId'] == kid && (sub == null || p['subCategoryId'] == sub))
              .toList();
          return Scaffold(
            backgroundColor: bgc,
            appBar: kAppBar(),
            body: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(children: [
                  const Text('\u0AA4\u0ABE\u0AB2\u0AC1\u0A95\u0ABE \u0AAA\u0AB8\u0A82\u0AA6 \u0A95\u0AB0\u0ACB',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: onSurf)),
                  const Spacer(),
                  Text('${talukas.length} \u0AA4\u0ABE\u0AB2\u0AC1\u0A95\u0ABE', style: const TextStyle(color: muted)),
                ]),
              ),
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                  children: [
                    Pill('\u0AB8\u0AAE\u0A97\u0ACD\u0AB0 \u0A95\u0A9A\u0ACD\u0A9B', sub == null, () => setState(() => sub = null)),
                    for (final s in talukas)
                      Pill(s['name'] ?? '', sub == s['id'], () => setState(() => sub = s['id'])),
                  ],
                ),
              ),
              Expanded(child: feed(context, list, empty: 'Aa taluka ni haji koi news nathi.')),
            ]),
          );
        },
      );
}

// ---------- Saved ----------
class SavedTab extends StatelessWidget {
  const SavedTab({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (_, __) {
          final list = store.posts.where((p) => store.saved.contains(p['id'])).toList();
          return Scaffold(
            backgroundColor: bgc,
            appBar: kAppBar(),
            body: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Row(children: [
                  const Text('\u0AB8\u0ABE\u0A9A\u0AB5\u0AC7\u0AB2\u0ABE \u0AB8\u0AAE\u0ABE\u0A9A\u0ABE\u0AB0',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: onSurf)),
                  const Spacer(),
                  Text('${list.length} \u0AB2\u0AC7\u0A96\u0ACB', style: const TextStyle(color: muted)),
                ]),
              ),
              Expanded(
                  child: feed(context, list,
                      empty: 'Koi news save nathi. News ma bookmark nishan dabavo.')),
            ]),
          );
        },
      );
}

// ---------- E-paper (auto generated from latest news) ----------
const epaperBase = 'https://kutchhnusuraj-kns.github.io/kutchhnusuraj-epaper';

Future<void> openLink(String u) => launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);

class EpaperTab extends StatefulWidget {
  const EpaperTab({super.key});
  @override
  State<EpaperTab> createState() => _EpaperTabState();
}

class _EpaperTabState extends State<EpaperTab> {
  List<Map<String, dynamic>> eds = [];
  bool loading = true;
  String? err;
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
      final r = await http.get(Uri.parse('$epaperBase/editions.json?t=${DateTime.now().millisecondsSinceEpoch}'));
      if (r.statusCode != 200) throw Exception('HTTP ${r.statusCode}');
      final l = (jsonDecode(r.body)['editions'] as List?) ?? [];
      eds = l.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      err = '\u0A88-\u0AAA\u0AC7\u0AAA\u0AB0 \u0AB2\u0ACB\u0AA1 \u0AA8 \u0AA5\u0AAF\u0AC1\u0A82. \u0A87\u0AA8\u0ACD\u0A9F\u0AB0\u0AA8\u0AC7\u0A9F \u0AA4\u0AAA\u0ABE\u0AB8\u0ACB.';
    }
    if (mounted) setState(() => loading = false);
  }

  void open(Map<String, dynamic> e) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => EpaperReader(e: e)));

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (loading) {
      body = const Center(child: CircularProgressIndicator(color: red));
    } else if (err != null) {
      body = Center(child: Text(err!));
    } else if (eds.isEmpty) {
      body = const Center(
          child: Padding(
              padding: EdgeInsets.all(30),
              child: Text('\u0A88-\u0AAA\u0AC7\u0AAA\u0AB0 \u0AB9\u0A9C\u0AC0 \u0AA4\u0AC8\u0AAF\u0ABE\u0AB0 \u0AA8\u0AA5\u0AC0. \u0AA5\u0ACB\u0AA1\u0ABE \u0AB8\u0AAE\u0AAF \u0AAA\u0A9B\u0AC0 \u0A9C\u0AC1\u0A93.',
                  textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 16))));
    } else {
      final e = eds.first;
      final pages = (e['pages'] as List).cast<String>();
      body = RefreshIndicator(
        color: red,
        onRefresh: load,
        child: ListView(padding: const EdgeInsets.all(14), children: [
          const Text('\u0AA4\u0ABE\u0A9C\u0ACB \u0A85\u0A82\u0A95',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: onSurf)),
          const SizedBox(height: 10),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: outV.withOpacity(.5)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InkWell(
                onTap: () => open(e),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(pages.first,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (_, __, ___) => Container(color: Colors.black12)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${e['title']}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: onSurf)),
                  const SizedBox(height: 4),
                  Text('${e['count']} \u0AB8\u0AAE\u0ABE\u0A9A\u0ABE\u0AB0 \u2022 ${pages.length} \u0AAA\u0ABE\u0AA8\u0ABE',
                      style: const TextStyle(color: muted, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: red),
                        onPressed: () => open(e),
                        icon: const Icon(Icons.menu_book),
                        label: const Text('\u0AB5\u0ABE\u0A82\u0A9A\u0ACB'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: red)),
                        onPressed: () => openLink('${e['pdf']}'),
                        icon: const Icon(Icons.picture_as_pdf, color: red),
                        label: const Text('PDF', style: TextStyle(color: red)),
                      ),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
          if (eds.length > 1) ...[
            const SizedBox(height: 22),
            const Text('\u0A9C\u0AC2\u0AA8\u0ABE \u0A85\u0A82\u0A95',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: onSurf)),
            const SizedBox(height: 6),
            for (final o in eds.skip(1))
              Card(
                color: Colors.white,
                margin: const EdgeInsets.only(top: 8),
                child: ListTile(
                  leading: const Icon(Icons.newspaper, color: red),
                  title: Text('${o['title']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${o['count']} \u0AB8\u0AAE\u0ABE\u0A9A\u0ABE\u0AB0'),
                  trailing: IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: red),
                      onPressed: () => openLink('${o['pdf']}')),
                  onTap: () => open(o),
                ),
              ),
          ],
          const SizedBox(height: 30),
        ]),
      );
    }
    return Scaffold(backgroundColor: bgc, appBar: kAppBar(), body: body);
  }
}

class EpaperReader extends StatefulWidget {
  final Map<String, dynamic> e;
  const EpaperReader({super.key, required this.e});
  @override
  State<EpaperReader> createState() => _EpaperReaderState();
}

class _EpaperReaderState extends State<EpaperReader> {
  final pc = PageController();
  int cur = 0;
  bool crop = false, busy = false;
  ui.Image? src;
  Rect box = Rect.zero;
  Rect bounds = Rect.zero;
  @override
  void dispose() {
    pc.dispose();
    super.dispose();
  }

  void go(int d) {
    final n = (widget.e['pages'] as List).length;
    final t = cur + d;
    if (t < 0 || t >= n) return;
    pc.animateToPage(t, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> startCrop() async {
    setState(() => busy = true);
    try {
      final pages = (widget.e['pages'] as List).cast<String>();
      final r = await http.get(Uri.parse(pages[cur]));
      final img = await decodeImageFromList(r.bodyBytes);
      src = img;
      box = Rect.zero;
      crop = true;
    } catch (_) {
      if (mounted) snack(context, '\u0AAA\u0ABE\u0AA8\u0AC1\u0A82 \u0AB2\u0ACB\u0AA1 \u0AA8 \u0AA5\u0AAF\u0AC1\u0A82');
    }
    if (mounted) setState(() => busy = false);
  }

  void stopCrop() => setState(() {
        crop = false;
        src = null;
      });

  Rect resize(Rect r, Rect b, {double l = 0, double t = 0, double rt = 0, double bt = 0}) {
    final L = (r.left + l).clamp(b.left, math.max(b.left, r.right - 60)).toDouble();
    final T = (r.top + t).clamp(b.top, math.max(b.top, r.bottom - 60)).toDouble();
    final R = (r.right + rt).clamp(math.min(b.right, L + 60), b.right).toDouble();
    final B = (r.bottom + bt).clamp(math.min(b.bottom, T + 60), b.bottom).toDouble();
    return Rect.fromLTRB(L, T, R, B);
  }

  Rect move(Rect r, Rect b) {
    var dx = 0.0, dy = 0.0;
    if (r.left < b.left) dx = b.left - r.left;
    if (r.right > b.right) dx = b.right - r.right;
    if (r.top < b.top) dy = b.top - r.top;
    if (r.bottom > b.bottom) dy = b.bottom - r.bottom;
    return r.shift(Offset(dx, dy));
  }

  Future<void> shareClip() async {
    final s = src;
    if (s == null) return;
    setState(() => busy = true);
    try {
      final sc = bounds.width / s.width;
      final sx = (box.left - bounds.left) / sc, sy = (box.top - bounds.top) / sc;
      final sw = box.width / sc, sh = box.height / sc;
      final band = math.max(44.0, sw * 0.055);
      final rec = ui.PictureRecorder();
      final cv = ui.Canvas(rec);
      cv.drawRect(Rect.fromLTWH(0, 0, sw, sh + band), Paint()..color = Colors.white);
      cv.drawImageRect(s, Rect.fromLTWH(sx, sy, sw, sh), Rect.fromLTWH(0, 0, sw, sh),
          Paint()..filterQuality = FilterQuality.high);
      cv.drawRect(Rect.fromLTWH(0, sh, sw, band), Paint()..color = red);
      final tp = TextPainter(
        text: TextSpan(
            text: 'KUTCHHNUSURAJ  \u0A88-\u0AAA\u0AC7\u0AAA\u0AB0 \u2022 ${widget.e['title']}',
            style: TextStyle(
                color: Colors.white, fontFamily: 'Hind', fontWeight: FontWeight.w700, fontSize: band * 0.42)),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '\u2026',
      )..layout(maxWidth: sw - band * 0.6);
      tp.paint(cv, Offset(band * 0.3, sh + (band - tp.height) / 2));
      final out = await rec.endRecording().toImage(sw.round(), (sh + band).round());
      final bd = await out.toByteData(format: ui.ImageByteFormat.png);
      final f = File('${Directory.systemTemp.path}/kns_clip_${DateTime.now().millisecondsSinceEpoch}.png');
      await f.writeAsBytes(bd!.buffer.asUint8List());
      await SharePlus.instance.share(ShareParams(files: [XFile(f.path)], text: 'KUTCHHNUSURAJ \u0A88-\u0AAA\u0AC7\u0AAA\u0AB0'));
    } catch (_) {
      if (mounted) snack(context, '\u0AB6\u0AC7\u0AB0 \u0AA8 \u0AA5\u0AAF\u0AC1\u0A82');
    }
    if (mounted) setState(() => busy = false);
  }

  Widget handle(Offset c, void Function(Offset d) onDrag) => Positioned(
        left: c.dx - 20,
        top: c.dy - 20,
        child: GestureDetector(
          onPanUpdate: (d) => onDrag(d.delta),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            color: Colors.transparent,
            child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    color: red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
          ),
        ),
      );

  Widget cropView() => Column(children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text('\u0A96\u0AC2\u0AA3\u0ABE \u0A96\u0AC7\u0A82\u0A9A\u0AC0\u0AA8\u0AC7 \u0AAD\u0ABE\u0A97 \u0AAA\u0AB8\u0A82\u0AA6 \u0A95\u0AB0\u0ACB, \u0AB5\u0A9A\u0ACD\u0A9A\u0AC7 \u0AAA\u0A95\u0AA1\u0AC0\u0AA8\u0AC7 \u0A96\u0AB8\u0AC7\u0AA1\u0ACB',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ),
        Expanded(
          child: LayoutBuilder(builder: (ctx, c) {
            final s = src!;
            final iw = s.width.toDouble(), ih = s.height.toDouble();
            final sc = math.min(c.maxWidth / iw, c.maxHeight / ih);
            final dw = iw * sc, dh = ih * sc;
            bounds = Rect.fromLTWH((c.maxWidth - dw) / 2, (c.maxHeight - dh) / 2, dw, dh);
            if (box == Rect.zero) {
              box = Rect.fromLTWH(bounds.left + dw * .08, bounds.top + dh * .08, dw * .84, dh * .3);
            }
            return Stack(children: [
              Positioned.fromRect(rect: bounds, child: RawImage(image: s, fit: BoxFit.fill)),
              Positioned.fromRect(
                rect: box,
                child: GestureDetector(
                  onPanUpdate: (d) => setState(() => box = move(box.shift(d.delta), bounds)),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: red, width: 2), color: red.withOpacity(.12)),
                  ),
                ),
              ),
              handle(box.topLeft, (d) => setState(() => box = resize(box, bounds, l: d.dx, t: d.dy))),
              handle(box.topRight, (d) => setState(() => box = resize(box, bounds, rt: d.dx, t: d.dy))),
              handle(box.bottomLeft, (d) => setState(() => box = resize(box, bounds, l: d.dx, bt: d.dy))),
              handle(box.bottomRight, (d) => setState(() => box = resize(box, bounds, rt: d.dx, bt: d.dy))),
            ]);
          }),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54)),
                  onPressed: busy ? null : stopCrop,
                  child: const Text('\u0AB0\u0AA6 \u0A95\u0AB0\u0ACB', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: red),
                  onPressed: busy ? null : shareClip,
                  icon: const Icon(Icons.share),
                  label: const Text('\u0AB6\u0AC7\u0AB0 \u0A95\u0AB0\u0ACB'),
                ),
              ),
            ]),
          ),
        ),
      ]);

  Widget readerView(List<String> pages) => Stack(children: [
        PageView.builder(
          controller: pc,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pages.length,
          onPageChanged: (i) => setState(() => cur = i),
          itemBuilder: (_, i) => InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: Image.network(pages[i],
                  fit: BoxFit.contain,
                  loadingBuilder: (c, w, pr) =>
                      pr == null ? w : const Center(child: CircularProgressIndicator(color: red)),
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.white54, size: 60)),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 14,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
                onPressed: () => go(-1),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                icon: const Icon(Icons.chevron_left, color: Colors.white)),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: Text('${cur + 1} / ${pages.length}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            IconButton(
                onPressed: () => go(1),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                icon: const Icon(Icons.chevron_right, color: Colors.white)),
          ]),
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    final pages = (widget.e['pages'] as List).cast<String>();
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${widget.e['title']}',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
              tooltip: '\u0A95\u0ABE\u0AAA\u0ACB',
              onPressed: busy ? null : (crop ? stopCrop : startCrop),
              icon: Icon(Icons.content_cut, color: crop ? redC : Colors.white)),
          IconButton(
              onPressed: () => openLink('${widget.e['pdf']}'),
              icon: const Icon(Icons.download, color: Colors.white)),
          IconButton(
              onPressed: () => shareText('KUTCHHNUSURAJ ${widget.e['title']}\n${widget.e['pdf']}'),
              icon: const Icon(Icons.share, color: Colors.white)),
        ],
        bottom: busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(color: red, backgroundColor: Colors.black, minHeight: 3))
            : null,
      ),
      body: crop && src != null ? cropView() : readerView(pages),
    );
  }
}

// ---------- Share card (image for WhatsApp etc.) ----------
class ShareCardPage extends StatefulWidget {
  final Map<String, String> p;
  const ShareCardPage({super.key, required this.p});
  @override
  State<ShareCardPage> createState() => _ShareCardPageState();
}

class _ShareCardPageState extends State<ShareCardPage> {
  final key = GlobalKey();
  bool busy = false;

  Future<void> send() async {
    setState(() => busy = true);
    try {
      final b = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await b.toImage(pixelRatio: 3);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      final f = File('${Directory.systemTemp.path}/kns_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await f.writeAsBytes(bd!.buffer.asUint8List());
      await SharePlus.instance
          .share(ShareParams(files: [XFile(f.path)], text: '${widget.p['title'] ?? ''}\n\nKUTCHHNUSURAJ'));
    } catch (_) {
      if (mounted) snack(context, '\u0AB6\u0AC7\u0AB0 \u0AA8 \u0AA5\u0AAF\u0AC1\u0A82');
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final imgs = imgsOf(p);
    final cat = store.catName(p['categoryId']);
    final desc = (p['description'] ?? '').replaceAll(RegExp(r'\[img\d+\]'), '').trim();
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDF2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: onSurf),
        title: const Text('\u0AB6\u0AC7\u0AB0 \u0A95\u0ABE\u0AB0\u0ACD\u0AA1',
            style: TextStyle(color: red, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: RepaintBoundary(
                key: key,
                child: Container(
                  width: 360,
                  color: Colors.white,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      color: red,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(children: [
                        Container(
                            width: 34,
                            height: 34,
                            padding: const EdgeInsets.all(2),
                            decoration:
                                const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Image.asset('logo.png')),
                        const SizedBox(width: 10),
                        const Text('KUTCHHNUSURAJ',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: .5)),
                      ]),
                    ),
                    if (imgs.isNotEmpty)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(imgs.first,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.black12)),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (cat.isNotEmpty) badge(cat),
                        const SizedBox(height: 10),
                        Text(p['title'] ?? '',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800, height: 1.3, color: onSurf)),
                        if (desc.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(desc,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, height: 1.5, color: muted)),
                        ],
                      ]),
                    ),
                    Container(
                      color: const Color(0xFF14110F),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(children: [
                        const Expanded(
                          child: Text('\u0AB5\u0AA7\u0AC1 \u0AB5\u0ABF\u0A97\u0AA4 \u0AAE\u0ABE\u0A9F\u0AC7 KUTCHHNUSURAJ \u0A8F\u0AAA',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                        Text(fdate(p['createdAt']),
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                onPressed: busy ? null : send,
                icon: busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Icon(Icons.share),
                label: const Text('WhatsApp / \u0AAC\u0AC0\u0A9C\u0AC7 \u0AB6\u0AC7\u0AB0 \u0A95\u0AB0\u0ACB',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ---------- News card ----------
class NewsCard extends StatelessWidget {
  final Map<String, String> p;
  final bool big;
  const NewsCard({super.key, required this.p, this.big = false});
  @override
  Widget build(BuildContext context) {
    final imgs = imgsOf(p);
    final hasVideo = (p['videoUrl'] ?? '').isNotEmpty;
    final cat = store.catName(p['categoryId']);
    final desc = (p['description'] ?? '').replaceAll(RegExp(r'\[img\d+\]'), '').trim();
    final saved = store.saved.contains(p['id']);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: outV.withOpacity(.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 3))
        ],
      ),
      child: InkWell(
        onTap: () => openPost(context, p),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (imgs.isNotEmpty)
            Stack(children: [
              AspectRatio(
                aspectRatio: big ? 16 / 10 : 16 / 9,
                child: Image.network(imgs.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.black12)),
              ),
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
                      decoration:
                          BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        const Icon(Icons.photo_library, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('${imgs.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ]),
                    )),
            ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (imgs.isEmpty) ...[badge(cat), const SizedBox(height: 10)],
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(p['title'] ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: big ? 22 : 18,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                        color: onSurf)),
              ),
              if (desc.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(desc,
                      maxLines: big ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: muted, fontSize: 15, height: 1.45)),
                ),
              ],
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.access_time, size: 15, color: muted),
                const SizedBox(width: 5),
                Text(fdate(p['createdAt']), style: const TextStyle(color: muted, fontSize: 13)),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => store.toggleSave(p['id']!),
                  icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, color: red),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ---------- Article detail ----------
class Detail extends StatefulWidget {
  final Map<String, String> p;
  const Detail({super.key, required this.p});
  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  WebViewController? wc;
  double ratio = .5625;
  double fs = 18;
  @override
  void initState() {
    super.initState();
    final e = embedOf(widget.p['videoUrl'] ?? '');
    if (e != null) {
      ratio = e.ratio;
      wc = webFor(e.html);
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
      body.add(Text(s, style: TextStyle(fontSize: fs, height: 1.7, color: onSurf)));
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
    return ListenableBuilder(
      listenable: store,
      builder: (_, __) {
        final saved = store.saved.contains(p['id']);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            iconTheme: const IconThemeData(color: onSurf),
            title: const Text('KUTCHHNUSURAJ',
                style: TextStyle(color: red, fontWeight: FontWeight.w800, fontSize: 17)),
            actions: [
              IconButton(
                  onPressed: () => store.toggleSave(p['id']!),
                  icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, color: red)),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ShareCardPage(p: p)));
                  },
                  icon: const Icon(Icons.share, color: onSurf)),
            ],
          ),
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
                badge(store.catName(p['categoryId'])),
                const SizedBox(height: 12),
                Text(p['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w800, height: 1.3, color: onSurf)),
                const SizedBox(height: 14),
                Row(children: [
                  Container(
                      width: 30,
                      height: 30,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: red)),
                      child: Image.asset('logo.png')),
                  const SizedBox(width: 10),
                  const Text('KUTCHHNUSURAJ',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  const Text('  \u2022  ', style: TextStyle(color: Colors.black38)),
                  Text(fdate(p['createdAt']), style: const TextStyle(color: muted, fontSize: 13)),
                  const Spacer(),
                  TextButton(
                      onPressed: () => setState(() => fs = fs > 14 ? fs - 2 : fs),
                      child: const Text('A-', style: TextStyle(color: red, fontWeight: FontWeight.w800))),
                  TextButton(
                      onPressed: () => setState(() => fs = fs < 28 ? fs + 2 : fs),
                      child: const Text('A+', style: TextStyle(color: red, fontWeight: FontWeight.w800))),
                ]),
                if ((p['byName'] ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('\u0AA8\u0ABE\u0A97\u0AB0\u0ABF\u0A95 \u0AB0\u0ABF\u0AAA\u0ACB\u0AB0\u0ACD\u0A9F\u0AB0: ${p['byName']}',
                        style: const TextStyle(color: muted, fontSize: 13)),
                  ),
                const SizedBox(height: 10),
                Container(height: 3, width: 60, color: red),
                const SizedBox(height: 18),
                ...body,
              ]),
            ),
          ]),
        );
      },
    );
  }
}

// ---------- Shorts (full screen, auto play, auto next) ----------
class ShortsTab extends StatefulWidget {
  final VoidCallback onClose;
  const ShortsTab({super.key, required this.onClose});
  @override
  State<ShortsTab> createState() => _ShortsTabState();
}

class _ShortsTabState extends State<ShortsTab> {
  final pc = PageController();
  int cur = 0;
  @override
  void dispose() {
    pc.dispose();
    super.dispose();
  }

  void go(int d) {
    final n = store.shorts.length;
    if (n == 0 || !pc.hasClients) return;
    var t = cur + d;
    if (t >= n) t = 0;
    if (t < 0) return;
    pc.animateToPage(t, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (_, __) {
          final list = store.shorts;
          return Scaffold(
            backgroundColor: Colors.black,
            body: store.loading
                ? const Center(child: CircularProgressIndicator(color: red))
                : list.isEmpty
                    ? Center(
                        child: TextButton(
                            onPressed: widget.onClose,
                            child: const Text('Haji koi short nathi. Pachha jao.',
                                style: TextStyle(color: Colors.white70))))
                    : Stack(children: [
                        PageView.builder(
                          scrollDirection: Axis.vertical,
                          controller: pc,
                          itemCount: list.length,
                          onPageChanged: (i) => setState(() => cur = i),
                          itemBuilder: (_, i) => ShortPage(
                              key: ValueKey(list[i]['id']),
                              s: list[i],
                              active: i == cur,
                              onNext: () => go(1),
                              onPrev: () => go(-1)),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
                            child: Row(children: [
                              IconButton(
                                  onPressed: widget.onClose,
                                  style: IconButton.styleFrom(backgroundColor: Colors.black38),
                                  icon: const Icon(Icons.arrow_back, color: Colors.white)),
                              const SizedBox(width: 8),
                              const Text('\u0AB6\u0ACB\u0AB0\u0ACD\u0A9F\u0ACD\u0AB8',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                              const SizedBox(width: 10),
                              badge('KUTCHHNUSURAJ'),
                            ]),
                          ),
                        ),
                      ]),
          );
        },
      );
}

class ShortPage extends StatefulWidget {
  final Map<String, String> s;
  final bool active;
  final VoidCallback onNext, onPrev;
  const ShortPage(
      {super.key, required this.s, required this.active, required this.onNext, required this.onPrev});
  @override
  State<ShortPage> createState() => _ShortPageState();
}

class _ShortPageState extends State<ShortPage> {
  WebViewController? wc;
  ShortSrc? src;
  @override
  void initState() {
    super.initState();
    if (widget.active) _start();
  }

  @override
  void didUpdateWidget(ShortPage o) {
    super.didUpdateWidget(o);
    if (widget.active && wc == null) _start();
    if (!widget.active && wc != null) wc = null;
  }

  void _start() {
    src = shortOf(widget.s['url'] ?? '');
    if (src != null) wc = shortWeb(src!, widget.onNext);
  }

  Widget act(IconData i, String label, VoidCallback f, {Color c = Colors.white}) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(children: [
          IconButton(
              onPressed: f,
              style: IconButton.styleFrom(backgroundColor: Colors.black38),
              icon: Icon(i, color: c, size: 28)),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final cat = store.catName(s['categoryId']);
    final liked = store.likedShorts.contains(s['id']);
    final likes = int.tryParse(s['likes'] ?? '0') ?? 0;
    final bottom = MediaQuery.of(context).padding.bottom;
    return Stack(children: [
      Positioned.fill(
        child: wc == null
            ? const Center(child: Icon(Icons.play_circle_outline, color: Colors.white38, size: 80))
            : (src!.type == 'ig'
                ? WebViewWidget(controller: wc!)
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => wc!.runJavaScript('toggle()'),
                    child: IgnorePointer(child: WebViewWidget(controller: wc!)))),
      ),
      Positioned(
        left: 0,
        right: 70,
        bottom: 0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v < -200) {
              widget.onNext();
            } else if (v > 200) {
              widget.onPrev();
            }
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 40, 8, 22 + bottom),
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87, Colors.black])),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cat.isNotEmpty) badge(cat),
                  const SizedBox(height: 8),
                  Text(s['title'] ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.35)),
                  const SizedBox(height: 6),
                  Text('KUTCHHNUSURAJ \u2022 ${fdate(s['createdAt'])}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
          ),
        ),
      ),
      Positioned(
        right: 6,
        bottom: 40 + bottom,
        child: Column(children: [
          act(Icons.keyboard_arrow_up, '\u0A89\u0AAA\u0AB0', widget.onPrev),
          act(liked ? Icons.favorite : Icons.favorite_border, likes > 0 ? '$likes' : '\u0AAA\u0AB8\u0A82\u0AA6',
              () => store.toggleLike(s),
              c: liked ? redC : Colors.white),
          act(Icons.share, '\u0AB6\u0AC7\u0AB0', () => shareText('${s['title'] ?? ''}\n${s['url'] ?? ''}\n\nKUTCHHNUSURAJ')),
          act(Icons.keyboard_arrow_down, '\u0AA8\u0AC0\u0A9A\u0AC7', widget.onNext),
        ]),
      ),
    ]);
  }
}

// ---------- User submission (name + mobile, goes to admin approval) ----------
bool isYoutube(String u) =>
    RegExp(r'(youtube\.com|youtu\.be)/').hasMatch(u) && shortOf(u) != null;

Future<bool> submitItem(Map<String, String> f) async {
  final fields = <String, dynamic>{
    for (final e in f.entries) e.key: {'stringValue': e.value},
    'status': {'stringValue': 'pending'},
    'createdAt': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
  };
  try {
    final r = await http.post(Uri.parse('$base/submissions'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode({'fields': fields}));
    return r.statusCode == 200;
  } catch (_) {
    return false;
  }
}

class SubmitPage extends StatefulWidget {
  const SubmitPage({super.key});
  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  String kind = 'news';
  String? cat;
  final name = TextEditingController();
  final mobile = TextEditingController();
  final title = TextEditingController();
  final desc = TextEditingController();
  final link = TextEditingController();
  final img = TextEditingController();
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    final p = await SharedPreferences.getInstance();
    name.text = p.getString('me_name') ?? '';
    mobile.text = p.getString('me_mobile') ?? '';
  }

  @override
  void dispose() {
    for (final c in [name, mobile, title, desc, link, img]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> send() async {
    final n = name.text.trim(), m = mobile.text.trim(), t = title.text.trim(), u = link.text.trim();
    if (n.length < 2) return snack(context, '\u0AA4\u0AAE\u0ABE\u0AB0\u0AC1\u0A82 \u0AA8\u0ABE\u0AAE \u0AB2\u0A96\u0ACB');
    if (!RegExp(r'^\d{10}$').hasMatch(m)) return snack(context, '10 \u0A86\u0A82\u0A95\u0AA1\u0ABE\u0AA8\u0ACB \u0AAE\u0ACB\u0AAC\u0ABE\u0A87\u0AB2 \u0AA8\u0A82\u0AAC\u0AB0 \u0AB2\u0A96\u0ACB');
    if (cat == null) return snack(context, '\u0A95\u0AC7\u0A9F\u0AC7\u0A97\u0AB0\u0AC0 \u0AAA\u0AB8\u0A82\u0AA6 \u0A95\u0AB0\u0ACB');
    if (t.length < 3) return snack(context, '\u0AB6\u0AC0\u0AB0\u0ACD\u0AB7\u0A95 \u0AB2\u0A96\u0ACB');
    if (kind == 'news' && desc.text.trim().length < 10) return snack(context, '\u0AB8\u0AAE\u0ABE\u0A9A\u0ABE\u0AB0 \u0AB2\u0A96\u0ACB');
    if (kind == 'reel' && !isYoutube(u)) {
      return snack(context, '\u0AAB\u0A95\u0ACD\u0AA4 YouTube (Shorts) \u0AA8\u0AC0 \u0AB2\u0ABF\u0A82\u0A95 \u0AA8\u0ABE\u0A96\u0ACB');
    }
    setState(() => busy = true);
    final p = await SharedPreferences.getInstance();
    await p.setString('me_name', n);
    await p.setString('me_mobile', m);
    final f = <String, String>{'kind': kind, 'name': n, 'mobile': m, 'title': t, 'categoryId': cat!};
    if (desc.text.trim().isNotEmpty) f['description'] = desc.text.trim();
    if (u.isNotEmpty) f['url'] = u;
    if (kind == 'news' && img.text.trim().isNotEmpty) f['imageUrl'] = img.text.trim();
    final ok = await submitItem(f);
    if (!mounted) return;
    setState(() => busy = false);
    if (ok) {
      await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text('\u0A86\u0AAD\u0ABE\u0AB0!'),
                content: const Text(
                    '\u0AA4\u0AAE\u0ABE\u0AB0\u0AC0 \u0AB5\u0ABF\u0A97\u0AA4 \u0A8F\u0AA1\u0AAE\u0ABF\u0AA8\u0AA8\u0AC0 \u0AAE\u0A82\u0A9C\u0AC2\u0AB0\u0AC0 \u0AAE\u0ABE\u0A9F\u0AC7 \u0AAE\u0ACB\u0A95\u0AB2\u0ABE\u0A88 \u0A97\u0A88 \u0A9B\u0AC7. \u0AAE\u0A82\u0A9C\u0AC2\u0AB0\u0AC0 \u0AAE\u0AB3\u0ACD\u0AAF\u0ABE \u0AAA\u0A9B\u0AC0 \u0A9C \u0A8F\u0AAA\u0AAE\u0ABE\u0A82 \u0AA6\u0AC7\u0A96\u0ABE\u0AB6\u0AC7.'),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('\u0AAC\u0AB0\u0ABE\u0AAC\u0AB0'))],
              ));
      if (mounted) Navigator.pop(context);
    } else {
      snack(context, '\u0AAE\u0ACB\u0A95\u0AB2\u0ABE\u0AAF\u0AC1\u0A82 \u0AA8\u0AB9\u0AC0\u0A82. \u0A87\u0AA8\u0ACD\u0A9F\u0AB0\u0AA8\u0AC7\u0A9F \u0AA4\u0AAA\u0ABE\u0AB8\u0ACB \u0A85\u0AA8\u0AC7 \u0AAB\u0AB0\u0AC0 \u0AAA\u0ACD\u0AB0\u0AAF\u0AA4\u0ACD\u0AA8 \u0A95\u0AB0\u0ACB.');
    }
  }

  Widget tf(String label, TextEditingController c,
          {int lines = 1, TextInputType? type, String? hint, int? maxLen}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: c,
          minLines: lines,
          maxLines: lines == 1 ? 1 : lines + 4,
          keyboardType: type,
          maxLength: maxLen,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final reel = kind == 'reel';
    return Scaffold(
      backgroundColor: bgc,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: onSurf),
        title: const Text('\u0AB8\u0AAE\u0ABE\u0A9A\u0ABE\u0AB0 / \u0AB0\u0AC0\u0AB2 \u0AAE\u0ACB\u0A95\u0AB2\u0ACB',
            style: TextStyle(color: red, fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          Pill('\u0AB8\u0AAE\u0ABE\u0A9A\u0ABE\u0AB0', !reel, () => setState(() => kind = 'news')),
          Pill('\u0AB0\u0AC0\u0AB2 / \u0AB5\u0ABF\u0AA1\u0ABF\u0AAF\u0ACB', reel, () => setState(() => kind = 'reel')),
        ]),
        const SizedBox(height: 16),
        tf('\u0AA4\u0AAE\u0ABE\u0AB0\u0AC1\u0A82 \u0AA8\u0ABE\u0AAE', name),
        tf('\u0AAE\u0ACB\u0AAC\u0ABE\u0A87\u0AB2 \u0AA8\u0A82\u0AAC\u0AB0', mobile, type: TextInputType.phone, maxLen: 10),
        const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: Text('\u0AA4\u0AAE\u0ABE\u0AB0\u0ACB \u0AAE\u0ACB\u0AAC\u0ABE\u0A87\u0AB2 \u0AA8\u0A82\u0AAC\u0AB0 \u0AAB\u0A95\u0ACD\u0AA4 \u0A8F\u0AA1\u0AAE\u0ABF\u0AA8\u0AA8\u0AC7 \u0AA6\u0AC7\u0A96\u0ABE\u0AB6\u0AC7.',
              style: TextStyle(color: muted, fontSize: 12)),
        ),
        const Text('\u0A95\u0AC7\u0A9F\u0AC7\u0A97\u0AB0\u0AC0', style: TextStyle(fontWeight: FontWeight.w700, color: onSurf)),
        const SizedBox(height: 8),
        Wrap(runSpacing: 8, children: [
          for (final c in store.cs) Pill(c['name'] ?? '', cat == c['id'], () => setState(() => cat = c['id'])),
        ]),
        const SizedBox(height: 14),
        tf('\u0AB6\u0AC0\u0AB0\u0ACD\u0AB7\u0A95', title),
        tf(reel ? '\u0AB5\u0AB0\u0ACD\u0AA3\u0AA8 (\u0AB5\u0AC8\u0A95\u0AB2\u0ACD\u0AAA\u0ABF\u0A95)' : '\u0AB8\u0AAE\u0ABE\u0A9A\u0ABE\u0AB0 \u0AB2\u0A96\u0ACB', desc, lines: reel ? 2 : 6),
        tf(reel ? 'YouTube Shorts \u0AB2\u0ABF\u0A82\u0A95' : '\u0AB5\u0ABF\u0AA1\u0ABF\u0AAF\u0ACB \u0AB2\u0ABF\u0A82\u0A95 (\u0AB5\u0AC8\u0A95\u0AB2\u0ACD\u0AAA\u0ABF\u0A95)', link,
            type: TextInputType.url,
            hint: reel ? 'https://youtube.com/shorts/...' : 'https://...'),
        if (!reel) tf('\u0AAB\u0ACB\u0A9F\u0ABE\u0AA8\u0AC0 \u0AB2\u0ABF\u0A82\u0A95 (\u0AB5\u0AC8\u0A95\u0AB2\u0ACD\u0AAA\u0ABF\u0A95)', img, type: TextInputType.url, hint: 'https://...'),
        const SizedBox(height: 4),
        SizedBox(
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: red),
            onPressed: busy ? null : send,
            child: busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('\u0A8F\u0AA1\u0AAE\u0ABF\u0AA8\u0AA8\u0AC7 \u0AAE\u0A82\u0A9C\u0AC2\u0AB0\u0AC0 \u0AAE\u0ABE\u0A9F\u0AC7 \u0AAE\u0ACB\u0A95\u0AB2\u0ACB',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 30),
      ]),
    );
  }
}
