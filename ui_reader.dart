import 'package:flutter/material.dart';
import 'common.dart';
import 'native.dart';
import 'ui_book.dart' show safePdfName;
import 'state.dart';

class ReaderScreen extends StatefulWidget {
  final String bookId;
  final String title;
  final String path;
  const ReaderScreen({super.key, required this.bookId, required this.title, required this.path});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  int count = 0;
  int page = 0;
  bool loading = true;
  String? error;
  bool vertical = false;
  bool zoomed = false;
  double? drag;
  PageController? ctl;
  final Map<int, RenderedPage> cache = <int, RenderedPage>{};

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    try {
      final List<dynamic> info = await Native.pdfOpen(widget.path);
      final int n = (info.isNotEmpty && info[0] is int) ? info[0] as int : 0;
      if (!mounted) return;
      if (n <= 0) {
        setState(() {
          loading = false;
          error = 'اس کتاب میں کوئی صفحہ نہیں ملا';
        });
        return;
      }
      int start = lib.lastPage(widget.bookId);
      if (start < 0) start = 0;
      if (start >= n) start = n - 1;
      setState(() {
        count = n;
        page = start;
        ctl = PageController(initialPage: start);
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'یہ فائل کھل نہیں سکی۔ ہو سکتا ہے فائل خراب ہو یا پاس ورڈ والی ہو۔';
      });
    }
  }

  @override
  void dispose() {
    ctl?.dispose();
    Native.pdfClose();
    super.dispose();
  }

  void _toggleDirection() {
    setState(() {
      ctl?.dispose();
      vertical = !vertical;
      zoomed = false;
      ctl = PageController(initialPage: page);
    });
  }

  Future<void> _openExternal() async {
    try {
      await Native.viewPdf(widget.path, safePdfName(widget.title));
    } catch (_) {
      if (mounted) snack(context, 'دوسری ایپ میں نہیں کھل سکی۔ "Downloads میں محفوظ کریں" استعمال کریں۔');
    }
  }

  Future<void> _askPage() async {
    final TextEditingController t = TextEditingController();
    final String? r = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('صفحہ نمبر'),
        content: TextField(
          controller: t,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: '1 سے $count تک'),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('منسوخ')),
          FilledButton(onPressed: () => Navigator.pop(ctx, t.text.trim()), child: const Text('جائیں')),
        ],
      ),
    );
    final int? n = int.tryParse(r ?? '');
    if (n != null && n >= 1 && n <= count) {
      ctl?.jumpToPage(n - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final int renderWidth = (mq.size.width * mq.devicePixelRatio * 1.5).clamp(800.0, 2000.0).round();

    Widget body;
    if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      body = EmptyState(Icons.error_outline, error!);
    } else {
      body = PageView.builder(
        key: ValueKey<bool>(vertical),
        controller: ctl,
        scrollDirection: vertical ? Axis.vertical : Axis.horizontal,
        physics: zoomed ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
        itemCount: count,
        onPageChanged: (int i) {
          setState(() {
            page = i;
            zoomed = false;
          });
          lib.setLastPage(widget.bookId, i);
        },
        itemBuilder: (BuildContext context, int i) => _PdfPage(
          key: ValueKey<int>(i),
          path: widget.path,
          index: i,
          width: renderWidth,
          cache: cache,
          onZoom: (bool z) {
            if (mounted && z != zoomed) setState(() => zoomed = z);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      appBar: appBar(
        widget.title,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'دوسری PDF ایپ میں کھولیں',
            onPressed: _openExternal,
          ),
          if (!loading && error == null)
            IconButton(
              icon: Icon(vertical ? Icons.swap_horiz : Icons.swap_vert),
              tooltip: vertical ? 'افقی ورق گردانی' : 'اوپر نیچے ورق گردانی',
              onPressed: _toggleDirection,
            ),
        ],
      ),
      body: body,
      bottomNavigationBar: (loading || error != null)
          ? null
          : Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 52,
                  child: Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: _askPage,
                      child: Text('${page + 1} / $count', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    if (count > 1)
                      Expanded(
                        child: Slider(
                          value: (drag ?? (page + 1).toDouble()).clamp(1.0, count.toDouble()).toDouble(),
                          min: 1,
                          max: count.toDouble(),
                          onChanged: (double v) => setState(() => drag = v),
                          onChangeEnd: (double v) {
                            setState(() => drag = null);
                            ctl?.jumpToPage(v.round() - 1);
                          },
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _PdfPage extends StatefulWidget {
  final String path;
  final int index;
  final int width;
  final Map<int, RenderedPage> cache;
  final ValueChanged<bool> onZoom;

  const _PdfPage({
    super.key,
    required this.path,
    required this.index,
    required this.width,
    required this.cache,
    required this.onZoom,
  });

  @override
  State<_PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<_PdfPage> {
  RenderedPage? page;
  String? err;
  bool zoomed = false;
  Offset tapPos = Offset.zero;
  final TransformationController tc = TransformationController();

  @override
  void initState() {
    super.initState();
    tc.addListener(_onTransform);
    page = widget.cache[widget.index];
    if (page == null) _load();
  }

  Future<void> _load() async {
    try {
      final RenderedPage r = await Native.pdfRender(widget.path, widget.index, widget.width);
      widget.cache[widget.index] = r;
      while (widget.cache.length > 8) {
        widget.cache.remove(widget.cache.keys.first);
      }
      if (mounted) setState(() => page = r);
    } catch (e) {
      if (mounted) setState(() => err = 'یہ صفحہ نہیں کھل سکا\n$e');
    }
  }

  void _onTransform() {
    final bool z = tc.value.getMaxScaleOnAxis() > 1.02;
    if (z != zoomed) {
      setState(() => zoomed = z);
      widget.onZoom(z);
    }
  }

  void _doubleTap() {
    if (zoomed) {
      tc.value = Matrix4.identity();
    } else {
      tc.value = Matrix4.translationValues(tapPos.dx, tapPos.dy, 0) *
          Matrix4.diagonal3Values(2.2, 2.2, 1) *
          Matrix4.translationValues(-tapPos.dx, -tapPos.dy, 0);
    }
  }

  @override
  void dispose() {
    tc.removeListener(_onTransform);
    tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RenderedPage? pg = page;
    if (pg == null) {
      return Center(
        child: err != null
            ? Text(err!, style: const TextStyle(color: Colors.black54))
            : const CircularProgressIndicator(),
      );
    }
    return GestureDetector(
      onDoubleTapDown: (TapDownDetails d) => tapPos = d.localPosition,
      onDoubleTap: _doubleTap,
      child: InteractiveViewer(
        transformationController: tc,
        minScale: 1,
        maxScale: 4,
        panEnabled: zoomed,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Center(
              child: Image.memory(
                pg.bytes,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (BuildContext c, Object e, StackTrace? st) =>
                    const Text('تصویر دکھانے میں خرابی', style: TextStyle(color: Colors.red)),
              ),
            ),
            if (pg.blank)
              const Positioned(
                bottom: 14,
                left: 16,
                right: 16,
                child: Text(
                  'یہ صفحہ خالی بنا ہے۔ اوپر دائیں "دوسری PDF ایپ میں کھولیں" کا بٹن دبائیں۔',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, height: 1.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
