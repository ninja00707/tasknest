import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'api.dart';
import 'backtest_panel.dart';
import 'binance_stream.dart';
import 'tv_chart.dart';

final _money = NumberFormat('#,##0.00');
final _btcFmt = NumberFormat('#,##0.0000');
final _timeFmt = DateFormat('MM/dd HH:mm');

const _bg = Color(0xFF0E1116);
const _panel = Color(0xFF161B22);
const _up = Color(0xFF26A69A);
const _down = Color(0xFFEF5350);
const _textDim = Color(0xFF8B949E);

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  static const _intervals = ['15m', '1h', '4h', '1d'];
  String _interval = '1h';

  final _stream = BinanceStream();

  Wallet? _wallet;
  List<Trade> _trades = [];
  List<Decision> _decisions = [];

  bool _botRunning = false;
  bool _togglingBot = false;
  String? _error;

  String _strategyMode = 'structure';
  String _structureTf = '4h';
  StructureState? _structure;

  late final ZoomPanBehavior _zoom;
  final _crosshair = CrosshairBehavior(
    enable: true,
    lineType: CrosshairLineType.vertical,
    lineColor: const Color(0xFF5A6472),
    lineDashArray: <double>[4, 3],
  );

  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _zoom = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      enableDoubleTapZooming: true,
      enableSelectionZooming: true,
      zoomMode: ZoomMode.x,
      selectionRectBorderColor: _up,
      selectionRectBorderWidth: 1,
      selectionRectColor: _up.withValues(alpha: 0.08),
    );
    _startFeed(_interval);
    _refreshHistory();
    _loadStrategy();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _refreshHistory());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _stream.dispose();
    super.dispose();
  }

  Future<void> _startFeed(String interval) async {
    _stream.candles.value = [];
    _stream.start(interval);
    try {
      final snapshot = await fetchCandles(interval, limit: 300);
      if (!mounted) return;
      if (interval == _interval && _stream.candles.value.isEmpty) {
        _stream.candles.value = snapshot;
      }
    } catch (_) {}
  }

  Future<void> _refreshHistory() async {
    try {
      final results = await Future.wait([
        fetchWallet(),
        fetchTrades(),
        fetchDecisions(),
        fetchBotRunning(),
        if (_strategyMode == 'structure') fetchStructure(interval: _structureTf),
      ]);
      if (!mounted) return;
      setState(() {
        _wallet = results[0] as Wallet;
        _trades = results[1] as List<Trade>;
        _decisions = results[2] as List<Decision>;
        _botRunning = results[3] as bool;
        if (results.length > 4) _structure = results[4] as StructureState;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  Future<void> _loadStrategy() async {
    try {
      final s = await fetchStrategy();
      if (!mounted) return;
      setState(() {
        _strategyMode = s['mode'] as String;
        _structureTf = (s['timeframe'] ?? '4h') as String;
      });
    } catch (_) {}
  }

  Future<void> _changeStrategy(String mode, {String? tf}) async {
    try {
      final s = await setStrategy(mode, timeframe: tf);
      if (!mounted) return;
      setState(() {
        _strategyMode = s['mode'] as String;
        _structureTf = (s['timeframe'] ?? _structureTf) as String;
        _structure = null;
      });
      _refreshHistory();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _toggleBot(bool value) async {
    setState(() => _togglingBot = true);
    try {
      final running = await setBotRunning(value);
      if (!mounted) return;
      setState(() => _botRunning = running);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
    if (mounted) setState(() => _togglingBot = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _walletStrip(),
            _positionBanner(),
            Expanded(flex: 6, child: _chartPanel()),
            Expanded(
              flex: 4,
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      indicatorColor: _up,
                      labelColor: Colors.white,
                      unselectedLabelColor: _textDim,
                      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      tabs: [
                        Tab(text: 'Paper Trades'),
                        Tab(text: 'AI Log'),
                        Tab(text: 'Backtest'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [_tradeList(), _decisionList(), BacktestPanel()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final change = _stream.ticker.value?.changePct ?? 0;
    final price = _stream.ticker.value?.price ?? 0.0;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: const BoxDecoration(color: _panel),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('BTC/USDT',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  ValueListenableBuilder<Ticker?>(
                    valueListenable: _stream.ticker,
                    builder: (_, t, _) => Text(
                      t == null ? '…' : '\$${_money.format(t.price)}',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: t == null || change >= 0 ? _up : _down),
                    ),
                  ),
                ],
              ),
              Text(price == 0 ? 'Binance live · paper trading' : '\$${_money.format(price)} live · paper trading',
                  style: const TextStyle(fontSize: 11, color: _textDim)),
            ],
          ),
          const Spacer(),
          ValueListenableBuilder<Ticker?>(
            valueListenable: _stream.ticker,
            builder: (_, t, _) {
              final ch = t?.changePct ?? 0;
              final up = ch >= 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (up ? _up : _down).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${up ? '+' : ''}${ch.toStringAsFixed(2)}% 24h',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: up ? _up : _down),
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          Column(
            children: [
              Row(children: [
                Text('AI Bot', style: const TextStyle(fontSize: 12, color: _textDim)),
                const SizedBox(width: 6),
                SizedBox(
                  height: 24,
                  width: 44,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Switch(
                      value: _botRunning,
                      onChanged: _togglingBot ? null : _toggleBot,
                      activeThumbColor: _up,
                    ),
                  ),
                ),
              ]),
              Text(
                _botRunning ? 'auto-trading' : 'paused',
                style: TextStyle(fontSize: 10, color: _botRunning ? _up : _textDim),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletStrip() {
    final w = _wallet;
    final pnlUp = (w?.pnlUsd ?? 0) >= 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _stat('Equity', w == null ? '…' : '\$${_money.format(w.equityUsd)}'),
              _divider(),
              _stat('USDT', w == null ? '…' : '\$${_money.format(w.usdt)}'),
              _divider(),
              _stat('BTC', w == null ? '…' : _btcFmt.format(w.btc)),
              _divider(),
              _stat(
                'PnL',
                w == null ? '…' : '${pnlUp ? '+' : ''}\$${_money.format(w.pnlUsd)}',
                color: pnlUp ? _up : _down,
              ),
              _divider(),
              _stat('Trades', '${_trades.length}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(
      width: 1,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: const Color(0xFF2A3038));

  Widget _positionBanner() {
    final pos = _wallet?.position;
    if (pos == null) return const SizedBox.shrink();
    final uplUp = pos.upl >= 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2431),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _up.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            const Text('LONG',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _up)),
            const SizedBox(width: 10),
            Text('${_btcFmt.format(pos.qty)} BTC',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 14),
            _posLevel('ENTRY', '\$${_money.format(pos.entry)}', Colors.lightBlueAccent),
            if (pos.sl != null) _posLevel('SL', '\$${_money.format(pos.sl!)}', _down),
            if (pos.tp != null) _posLevel('TP', '\$${_money.format(pos.tp!)}', _up),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('uPnL ${uplUp ? '+' : ''}\$${_money.format(pos.upl)}',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: uplUp ? _up : _down)),
                Text('${pos.uplPct >= 0 ? '+' : ''}${pos.uplPct}%',
                    style: TextStyle(fontSize: 10, color: uplUp ? _up : _down)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _posLevel(String label, String value, Color c) => Padding(
        padding: const EdgeInsets.only(left: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$label ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c)),
            Text(value, style: const TextStyle(fontSize: 11)),
          ],
        ),
      );

  Widget _stat(String label, String value, {Color? color}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 10, color: _textDim, letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: color ?? Colors.white)),
        ],
      );

  Widget _chartPanel() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _strategyChip('ai', 'AI'),
                _strategyChip('structure', 'Structure · ${_structureTf.toUpperCase()}'),
                if (_strategyMode == 'structure') ...[
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    onSelected: (tf) => _changeStrategy('structure', tf: tf),
                    icon: const Icon(Icons.more_vert, size: 16, color: _textDim),
                    padding: EdgeInsets.zero,
                    itemBuilder: (_) => [
                      for (final tf in ['15m', '30m', '1h', '4h', '1d'])
                        PopupMenuItem(value: tf, height: 34, child: Text(tf.toUpperCase(), style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                ],
                const SizedBox(width: 10),
                for (final i in _intervals)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(i),
                      selected: _interval == i,
                      onSelected: (_) => _changeInterval(i),
                      selectedColor: _up.withValues(alpha: 0.25),
                      labelStyle: TextStyle(
                          fontSize: 12,
                          color: _interval == i ? _up : _textDim,
                          fontWeight:
                              _interval == i ? FontWeight.bold : FontWeight.normal),
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                const Spacer(),
                if (_strategyMode == 'structure') _biasBadge(),
                const SizedBox(width: 8),
                ValueListenableBuilder<FeedState>(
                  valueListenable: _stream.state,
                  builder: (_, s, _) => _feedBadge(s),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [_liveChart(), TvChart(interval: _interval)],
            ),
          ),
          TabBar(
            indicatorColor: _up,
            labelColor: Colors.white,
            unselectedLabelColor: _textDim,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            tabs: const [Tab(text: 'Live Candles'), Tab(text: 'TradingView')],
          ),
        ],
      ),
    );
  }

  void _changeInterval(String i) {
    if (_interval == i) return;
    setState(() => _interval = i);
    _startFeed(i);
  }

  Widget _strategyChip(String mode, String label) {
    final selected = _strategyMode == mode ||
        (mode == 'structure' && _strategyMode == 'structure');
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => _changeStrategy(mode),
        selectedColor: Colors.amber.withValues(alpha: 0.25),
        labelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.amber : _textDim),
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _biasBadge() {
    final st = _structure;
    final bias = st?.bias ?? 'neutral';
    final (label, color) = switch (bias) {
      'bullish' => ('LONG', _up),
      'bearish' => ('SHORT', _down),
      _ => ('WAIT', _textDim),
    };
    return Tooltip(
      message: st == null
          ? 'Loading structure…'
          : 'Structure ${bias.toUpperCase()} since ${_timeFmt.format(st.trendSinceLocal)}\n'
              'Flip level: ${st.flipLevel == null ? '-' : '\$${_money.format(st.flipLevel!)}'}\n'
              'Signal stays active until next shift',
      waitDuration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: color)),
            if (st?.flipLevel != null) ...[
              const SizedBox(width: 5),
              Text('flip \$${_money.format(st!.flipLevel!)}',
                  style: const TextStyle(fontSize: 9, color: _textDim)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _feedBadge(FeedState s) {
    final (label, color) = switch (s) {
      FeedState.live => ('LIVE', _up),
      FeedState.connecting => ('CONNECTING', Colors.amber),
      FeedState.reconnecting => ('RECONNECTING', Colors.orange),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: color)),
        ],
      ),
    );
  }

  Widget _liveChart() {
    return ValueListenableBuilder<List<Candle>>(
      valueListenable: _stream.candles,
      builder: (_, candles, _) {
        if (candles.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 42, color: _textDim),
                const SizedBox(height: 8),
                Text(_error ?? 'Connecting to Binance stream…',
                    style: const TextStyle(color: _textDim)),
              ],
            ),
          );
        }
        return SfCartesianChart(
          backgroundColor: _bg,
          plotAreaBorderColor: const Color(0xFF22272F),
          primaryXAxis: DateTimeAxis(
            majorGridLines: const MajorGridLines(width: 0.4, color: Color(0xFF1C2128)),
            axisLine: const AxisLine(width: 0),
            labelStyle: const TextStyle(fontSize: 10, color: _textDim),
            dateFormat: DateFormat.MMMd(),
            intervalType: DateTimeIntervalType.auto,
          ),
          primaryYAxis: NumericAxis(
            opposedPosition: true,
            majorGridLines: const MajorGridLines(width: 0.4, color: Color(0xFF1C2128)),
            axisLine: const AxisLine(width: 0),
            labelStyle: const TextStyle(fontSize: 10, color: _textDim),
            numberFormat: NumberFormat('#,##0'),
          ),
          axes: [
            NumericAxis(name: 'vol', isVisible: false, maximum: _volAxisMax(candles), minimum: 0),
          ],
          crosshairBehavior: _crosshair,
          tooltipBehavior: TooltipBehavior(enable: true, shared: true),
          zoomPanBehavior: _zoom,
          series: <CartesianSeries>[
            ..._positionLines(candles),
            ..._structureOverlays(candles),
            CandleSeries<Candle, DateTime>(
              dataSource: candles,
              xValueMapper: (c, _) => c.time,
              openValueMapper: (c, _) => c.open,
              highValueMapper: (c, _) => c.high,
              lowValueMapper: (c, _) => c.low,
              closeValueMapper: (c, _) => c.close,
              bearColor: _down,
              bullColor: _up,
              name: 'BTC/USDT',
              animationDuration: 0,
            ),
            ColumnSeries<Candle, DateTime>(
              dataSource: candles,
              xValueMapper: (c, _) => c.time,
              yValueMapper: (c, _) => c.volume,
              pointColorMapper: (c, _) => (c.isUp ? _up : _down).withValues(alpha: 0.35),
              yAxisName: 'vol',
              width: 0.7,
              name: 'Volume',
              animationDuration: 0,
            ),
            ScatterSeries<_TradePoint, DateTime>(
              dataSource: _markers('buy', candles),
              xValueMapper: (m, _) => m.time,
              yValueMapper: (m, _) => m.value,
              markerSettings: const MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.triangle,
                height: 13,
                width: 13,
                borderWidth: 1.5,
                borderColor: Color(0xFF0E1116),
                color: _up,
              ),
              name: 'Buy',
              animationDuration: 0,
            ),
            ScatterSeries<_TradePoint, DateTime>(
              dataSource: _markers('sell', candles),
              xValueMapper: (m, _) => m.time,
              yValueMapper: (m, _) => m.value,
              markerSettings: const MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.invertedTriangle,
                height: 13,
                width: 13,
                borderWidth: 1.5,
                borderColor: Color(0xFF0E1116),
                color: _down,
              ),
              name: 'Sell',
              animationDuration: 0,
            ),
          ],
        );
      },
    );
  }

  List<_TradePoint> _markers(String side, List<Candle> candles) {
    final pts = <_TradePoint>[];
    for (final tr in _trades) {
      if (tr.side != side || candles.isEmpty) continue;
      Candle nearest = candles.first;
      var best = double.infinity;
      for (final c in candles) {
        final d =
            (c.time.millisecondsSinceEpoch - tr.ts.millisecondsSinceEpoch).abs().toDouble();
        if (d < best) {
          best = d;
          nearest = c;
        }
      }
      pts.add(side == 'buy'
          ? _TradePoint(nearest.time, nearest.low * 0.997)
          : _TradePoint(nearest.time, nearest.high * 1.003));
    }
    return pts;
  }

  double _volAxisMax(List<Candle> candles) {
    var maxV = 0.0;
    for (final c in candles) {
      if (c.volume > maxV) maxV = c.volume;
    }
    return maxV <= 0 ? 1 : maxV * 5;
  }

  List<CartesianSeries> _positionLines(List<Candle> candles) {
    final pos = _wallet?.position;
    if (pos == null || candles.length < 2) return [];
    final t0 = candles.first.time;
    final t1 = candles.last.time.add(const Duration(minutes: 30));
    final levels = <(String, double, Color)>[
      ('Entry', pos.entry, Colors.lightBlueAccent),
      if (pos.sl != null) ('SL', pos.sl!, _down),
      if (pos.tp != null) ('TP', pos.tp!, _up),
    ];
    return [
      for (final (name, value, color) in levels)
        LineSeries<_LevelPoint, DateTime>(
          dataSource: [_LevelPoint(t0, value), _LevelPoint(t1, value)],
          xValueMapper: (p, _) => p.time,
          yValueMapper: (p, _) => p.value,
          color: color,
          width: 1.4,
          dashArray: const [6, 4],
          name: '$name ${_money.format(value)}',
          animationDuration: 0,
          enableTooltip: false,
        ),
    ];
  }

  List<CartesianSeries> _structureOverlays(List<Candle> candles) {
    final st = _structure;
    if (st == null || candles.length < 2) return [];
    final t0 = candles.first.time;
    final t1 = candles.last.time.add(const Duration(minutes: 30));

    final overlays = <CartesianSeries>[];

    final highs = [
      for (final s in st.swings)
        if (s.kind == 'high') _TradePoint(s.t, s.price * 1.0015),
    ];
    final lows = [
      for (final s in st.swings)
        if (s.kind == 'low') _TradePoint(s.t, s.price * 0.9985),
    ];
    if (highs.isNotEmpty) {
      overlays.add(ScatterSeries<_TradePoint, DateTime>(
        dataSource: highs,
        xValueMapper: (m, _) => m.time,
        yValueMapper: (m, _) => m.value,
        markerSettings: const MarkerSettings(
          isVisible: true,
          shape: DataMarkerType.circle,
          height: 7,
          width: 7,
          borderWidth: 1,
          borderColor: Color(0xFF0E1116),
          color: Colors.amber,
        ),
        name: 'Swing High',
        animationDuration: 0,
        enableTooltip: false,
      ));
    }
    if (lows.isNotEmpty) {
      overlays.add(ScatterSeries<_TradePoint, DateTime>(
        dataSource: lows,
        xValueMapper: (m, _) => m.time,
        yValueMapper: (m, _) => m.value,
        markerSettings: const MarkerSettings(
          isVisible: true,
          shape: DataMarkerType.circle,
          height: 7,
          width: 7,
          borderWidth: 1,
          borderColor: Color(0xFF0E1116),
          color: Colors.deepPurpleAccent,
        ),
        name: 'Swing Low',
        animationDuration: 0,
        enableTooltip: false,
      ));
    }
    if (st.flipLevel != null) {
      overlays.add(LineSeries<_LevelPoint, DateTime>(
        dataSource: [_LevelPoint(t0, st.flipLevel!), _LevelPoint(t1, st.flipLevel!)],
        xValueMapper: (p, _) => p.time,
        yValueMapper: (p, _) => p.value,
        color: Colors.amber,
        width: 1.6,
        dashArray: const [10, 6],
        name: 'Structure flip ${_money.format(st.flipLevel!)}',
        animationDuration: 0,
        enableTooltip: false,
      ));
    }
    return overlays;
  }

  Widget _empty(String msg) =>
      Center(child: Text(msg, style: const TextStyle(color: _textDim)));

  Widget _tradeList() {
    if (_trades.isEmpty) {
      return _empty(
        _botRunning
            ? 'Bot is watching — no trade yet (needs a ≥55% confidence buy/sell signal)'
            : 'No trades yet — turn the AI bot on',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _trades.length,
      itemBuilder: (_, i) {
        final t = _trades[i];
        final buy = t.side == 'buy';
        final c = buy ? _up : _down;
        return ListTile(
          dense: true,
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(5)),
            child: Text(t.side.toUpperCase(),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c)),
          ),
          title: Text('${_btcFmt.format(t.qty)} BTC @ \$${_money.format(t.price)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          subtitle: Text(t.reason, style: const TextStyle(fontSize: 11, color: _textDim)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${_money.format(t.usdt)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text(_timeFmt.format(t.ts.toLocal()),
                  style: const TextStyle(fontSize: 10, color: _textDim)),
            ],
          ),
        );
      },
    );
  }

  Widget _decisionList() {
    if (_decisions.isEmpty) return _empty('The AI has not made any decisions yet');
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _decisions.length,
      itemBuilder: (_, i) {
        final d = _decisions[i];
        final c = d.action == 'buy' ? _up : (d.action == 'sell' ? _down : _textDim);
        return ListTile(
          dense: true,
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(5)),
            child: Text(d.action.toUpperCase(),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c)),
          ),
          title: Text('${d.confidence}% · \$${_money.format(d.price)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          subtitle: Text(d.reason, style: const TextStyle(fontSize: 11, color: _textDim)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (d.executed)
                const Text('executed', style: TextStyle(fontSize: 10, color: _up))
              else
                const Text('skipped', style: TextStyle(fontSize: 10, color: _textDim)),
              Text(_timeFmt.format(d.ts.toLocal()),
                  style: const TextStyle(fontSize: 10, color: _textDim)),
            ],
          ),
        );
      },
    );
  }
}

class _TradePoint {
  const _TradePoint(this.time, this.value);
  final DateTime time;
  final double value;
}

class _LevelPoint {
  const _LevelPoint(this.time, this.value);
  final DateTime time;
  final double value;
}
