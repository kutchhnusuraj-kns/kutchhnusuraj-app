import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

const ink = Color(0xFF14110F);
const gold = Color(0xFFC8941A);
const base =
    'https://firestore.googleapis.com/v1/projects/kutchhnusuraj-97c95/databases/(default)/documents';
const site = 'https://kutchhnusuraj-kns.github.io';

void main() => runApp(const KnsApp());

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
                    child: const Text('嗒曕獨喃嵿獩, 嗒椸珌嗒溹嗒距 嗒呧喃� 嗒︵珖嗒多喃€ 嗒栢嗒�',
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
                  title: '嗒喃€ 嗒栢嗒�, 嗒忇獣 嗒溹獥喃嵿嗒距獜',
                  desc: '嗒囙喃嵿嗒苦嗒� 嗒ム珋 嗒曕獨喃嵿獩 嗒膏珌嗒о珋嗒ㄠ 嗒膏嗒距獨嗒距, 嗒む嗒距喃€ 嗒嗒傕嗒ㄠ珋 嗒曕珖嗒熰珖嗒椸喃€ 嗒珌嗒溹 嗒掂嗒傕獨喃�.',
                  child: CatPop()),
              Slide(
                  title: '嗒掂嗒∴嗒珛 嗒溹珌嗒�, 嗒忇嗒嗒� 嗒�',
                  desc: 'YouTube 嗒呧喃� Instagram 嗒ㄠ 嗒掂嗒∴嗒珛 嗒膏珋嗒о 嗒忇嗒嗒� 嗒珝嗒侧珖 嗒ム嗒� 嗒涏珖.',
                  child: VideoCards()),
              Slide(
                  title: '嗒む嗒溹 嗒膏嗒距獨嗒距, 嗒膏珜嗒ム珋 嗒喃囙嗒�',
                  desc: '嗒ㄠ喃€ 嗒栢嗒� 嗒嗋嗒む 嗒� 嗒む嗒距喃€ 嗒膏珝嗒曕珝嗒班珋嗒� 嗒 嗒︵珖嗒栢嗒� 嗒涏珖.',
                  child: Ticker()),
              Slide(
                  title: '嗒膏 嗒曕珖嗒熰珖嗒椸喃€嗒ム珋 嗒膏獨喃嬥獰 嗒多珛嗒�',
                  desc: '嗒曕獨喃嵿獩嗒嗒� 嗒珌嗒�, 嗒獨嗒距獕, 嗒呧獋嗒溹嗒� 嗒溹珖嗒掂 嗒掂嗒膏珝嗒む嗒� 嗒珌嗒溹 嗒膏嗒距獨嗒距 嗒珖嗒赤喃�.',
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
                child: Text(i == 4 ? '嗒多喃� 嗒曕喃�' : '嗒嗋獥嗒�',
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
  static const items = ['BREAKING', '嗒曕獨喃嵿獩', '嗒椸珌嗒溹嗒距', '嗒囙喃嵿嗒苦嗒�', '嗒曕珝嗒班嗒囙', '嗒珛嗒侧嗒熰嗒曕珝嗒�'];
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
          pop(2, chip('嗒珌嗒�')),
          pop(3, chip('嗒獨嗒距獕')),
          pop(4, chip('嗒呧獋嗒溹嗒�')),
          pop(5, chip('嗒嗒傕嗒掂珋')),
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
                              itemCount: list.length,
                              itemBuilder: (_, i) => NewsCard(
                                  p: list[i],
                                  cat: catName(list[i]['categoryId']),
                                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) =>
                                          Detail(p: list[i], cat: catName(list[i]['categoryId'])))))),
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

class NewsCard extends StatelessWidget {
  final Map<String, String> p;
  final String cat;
  final VoidCallback onTap;
  const NewsCard({super.key, required this.p, required this.cat, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final img = p['imageUrl'] ?? '';
    final hasVideo = (p['videoUrl'] ?? '').isNotEmpty;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (img.isNotEmpty)
            Stack(children: [
              Image.network(img,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 0)),
              if (hasVideo)
                const Positioned(
                    right: 10,
                    bottom: 10,
                    child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40)),
            ]),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['title'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('$cat  ${(p['createdAt'] ?? '').split('T').first}${hasVideo && img.isEmpty ? '  VIDEO' : ''}',
                  style: const TextStyle(color: Colors.black54, fontSize: 13)),
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

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final img = p['imageUrl'] ?? '';
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: ink,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(widget.cat, style: const TextStyle(color: gold, fontWeight: FontWeight.w800))),
      body: ListView(children: [
        if (wc != null)
          SizedBox(height: w * ratio, child: WebViewWidget(controller: wc!))
        else if (img.isNotEmpty)
          Image.network(img,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(height: 0)),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p['title'] ?? '',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.3)),
            const SizedBox(height: 8),
            Text((p['createdAt'] ?? '').split('T').first,
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 14),
            Text(p['description'] ?? '', style: const TextStyle(fontSize: 17, height: 1.6)),
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
