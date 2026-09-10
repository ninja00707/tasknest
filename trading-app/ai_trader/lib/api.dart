import 'dart:convert';

import 'package:http/http.dart' as http;

const String apiBase = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://127.0.0.1:8321',
);

class Candle {
  Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  bool get isUp => close >= open;
}

class Ticker {
  Ticker({
    required this.price,
    required this.changePct,
    required this.high,
    required this.low,
  });

  final double price;
  final double changePct;
  final double high;
  final double low;
}

class Wallet {
  Wallet({
    required this.usdt,
    required this.btc,
    required this.equityUsd,
    required this.pnlUsd,
    required this.pnlPct,
    required this.position,
  });

  factory Wallet.fromJson(Map<String, dynamic> j) => Wallet(
        usdt: (j['usdt'] as num).toDouble(),
        btc: (j['btc'] as num).toDouble(),
        equityUsd: (j['equity_usd'] as num).toDouble(),
        pnlUsd: (j['pnl_usd'] as num).toDouble(),
        pnlPct: (j['pnl_pct'] as num).toDouble(),
        position: j['position'] == null
            ? null
            : PositionInfo(
                entry: (j['position']['entry'] as num).toDouble(),
                sl: (j['position']['sl'] as num?)?.toDouble(),
                tp: (j['position']['tp'] as num?)?.toDouble(),
                qty: (j['position']['qty'] as num).toDouble(),
                upl: (j['position']['upl'] as num).toDouble(),
                uplPct: (j['position']['upl_pct'] as num).toDouble(),
              ),
      );

  final double usdt;
  final double btc;
  final double equityUsd;
  final double pnlUsd;
  final double pnlPct;
  final PositionInfo? position;
}

class PositionInfo {
  PositionInfo({
    required this.entry,
    required this.sl,
    required this.tp,
    required this.qty,
    required this.upl,
    required this.uplPct,
  });

  final double entry;
  final double? sl;
  final double? tp;
  final double qty;
  final double upl;
  final double uplPct;
}

class Trade {
  Trade({
    required this.ts,
    required this.side,
    required this.price,
    required this.qty,
    required this.usdt,
    required this.reason,
  });

  factory Trade.fromJson(Map<String, dynamic> j) => Trade(
        ts: DateTime.fromMillisecondsSinceEpoch(j['ts'] as int),
        side: j['side'] as String,
        price: (j['price'] as num).toDouble(),
        qty: (j['qty'] as num).toDouble(),
        usdt: (j['usdt'] as num).toDouble(),
        reason: (j['reason'] ?? '') as String,
      );

  final DateTime ts;
  final String side;
  final double price;
  final double qty;
  final double usdt;
  final String reason;
}

class Decision {
  Decision({
    required this.ts,
    required this.price,
    required this.action,
    required this.confidence,
    required this.reason,
    required this.executed,
  });

  factory Decision.fromJson(Map<String, dynamic> j) => Decision(
        ts: DateTime.fromMillisecondsSinceEpoch(j['ts'] as int),
        price: (j['price'] as num).toDouble(),
        action: j['action'] as String,
        confidence: (j['confidence'] as num).toInt(),
        reason: (j['reason'] ?? '') as String,
        executed: (j['executed'] as num?)?.toInt() == 1,
      );

  final DateTime ts;
  final double price;
  final String action;
  final int confidence;
  final String reason;
  final bool executed;
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

Future<T> _get<T>(String path, T Function(dynamic) parse) async {
  final uri = Uri.parse('$apiBase$path');
  late http.Response resp;
  try {
    resp = await http.get(uri).timeout(const Duration(seconds: 15));
  } catch (e) {
    throw ApiException('Backend unreachable at $apiBase');
  }
  if (resp.statusCode != 200) {
    throw ApiException('HTTP ${resp.statusCode}: ${resp.body}');
  }
  return parse(jsonDecode(utf8.decode(resp.bodyBytes)));
}

Future<List<Candle>> fetchCandles(String interval, {int limit = 200}) =>
    _get('/api/candles?interval=$interval&limit=$limit', (data) => [
          for (final k in data as List)
            Candle(
              time: DateTime.fromMillisecondsSinceEpoch(k['t'] as int),
              open: (k['o'] as num).toDouble(),
              high: (k['h'] as num).toDouble(),
              low: (k['l'] as num).toDouble(),
              close: (k['c'] as num).toDouble(),
              volume: (k['v'] as num).toDouble(),
            ),
        ]);

Future<Ticker> fetchTicker() => _get('/api/ticker', (data) => Ticker(
      price: (data['price'] as num).toDouble(),
      changePct: (data['change_pct'] as num).toDouble(),
      high: (data['high'] as num).toDouble(),
      low: (data['low'] as num).toDouble(),
    ));

Future<Wallet> fetchWallet() => _get('/api/wallet', (data) => Wallet.fromJson(data));

Future<List<Trade>> fetchTrades() =>
    _get('/api/trades', (data) => [for (final t in data as List) Trade.fromJson(t)]);

Future<List<Decision>> fetchDecisions() =>
    _get('/api/decisions', (data) => [for (final d in data as List) Decision.fromJson(d)]);

Future<bool> setBotRunning(bool running) async {
  final uri = Uri.parse('$apiBase/api/bot');
  late http.Response resp;
  try {
    resp = await http
        .post(uri, headers: {'Content-Type': 'application/json'}, body: '{"running": $running}')
        .timeout(const Duration(seconds: 10));
  } catch (_) {
    throw ApiException('Backend unreachable at $apiBase');
  }
  if (resp.statusCode != 200) throw ApiException('HTTP ${resp.statusCode}');
  return jsonDecode(resp.body)['running'] as bool;
}

Future<bool> fetchBotRunning() =>
    _get('/api/bot', (data) => data['running'] as bool);

class EquityPoint {
  EquityPoint({required this.time, required this.equity});
  final DateTime time;
  final double equity;
}

class BacktestTrade {
  BacktestTrade({
    required this.t,
    required this.side,
    required this.price,
    required this.usdt,
    required this.reason,
    required this.pnl,
  });

  factory BacktestTrade.fromJson(Map<String, dynamic> j) => BacktestTrade(
        t: DateTime.fromMillisecondsSinceEpoch(j['t'] as int),
        side: j['side'] as String,
        price: (j['price'] as num).toDouble(),
        usdt: (j['usdt'] as num).toDouble(),
        reason: (j['reason'] ?? '') as String,
        pnl: (j['pnl'] as num?)?.toDouble(),
      );

  final DateTime t;
  final String side;
  final double price;
  final double usdt;
  final String reason;
  final double? pnl;
}

class BacktestResult {
  BacktestResult({
    required this.initialUsdt,
    required this.finalEquity,
    required this.pnl,
    required this.pnlPct,
    required this.trades,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.maxDrawdownPct,
    required this.equityCurve,
    required this.tradeLog,
  });

  factory BacktestResult.fromJson(Map<String, dynamic> j) => BacktestResult(
        initialUsdt: (j['initial_usdt'] as num).toDouble(),
        finalEquity: (j['final_equity'] as num).toDouble(),
        pnl: (j['pnl'] as num).toDouble(),
        pnlPct: (j['pnl_pct'] as num).toDouble(),
        trades: (j['trades'] as num).toInt(),
        wins: (j['wins'] as num).toInt(),
        losses: (j['losses'] as num).toInt(),
        winRate: (j['win_rate'] as num).toDouble(),
        maxDrawdownPct: (j['max_drawdown_pct'] as num).toDouble(),
        equityCurve: [
          for (final p in j['equity_curve'] as List)
            EquityPoint(
              time: DateTime.fromMillisecondsSinceEpoch(p['t'] as int),
              equity: (p['e'] as num).toDouble(),
            ),
        ],
        tradeLog: [for (final t in j['trade_log'] as List) BacktestTrade.fromJson(t)],
      );

  final double initialUsdt;
  final double finalEquity;
  final double pnl;
  final double pnlPct;
  final int trades;
  final int wins;
  final int losses;
  final double winRate;
  final double maxDrawdownPct;
  final List<EquityPoint> equityCurve;
  final List<BacktestTrade> tradeLog;
}

class BacktestRun {
  BacktestRun({
    required this.id,
    required this.status,
    required this.progress,
    required this.error,
    required this.result,
    required this.params,
  });

  factory BacktestRun.fromJson(Map<String, dynamic> j) {
    final paramsRaw = j['params'] as Map<String, dynamic>?;
    return BacktestRun(
      id: j['id'] as String,
      status: j['status'] as String,
      progress: ((j['progress'] ?? 0) as num).toDouble(),
      error: j['error'] as String?,
      result: j['result'] == null ? null : BacktestResult.fromJson(j['result']),
      params: paramsRaw == null
          ? null
          : BacktestParams(
              interval: (paramsRaw['interval'] ?? '1h') as String,
              lookback: (paramsRaw['lookback'] ?? 300) as int,
              step: (paramsRaw['step'] ?? 6) as int,
              slPct: ((paramsRaw['sl_pct'] ?? 2) as num).toDouble(),
              tpPct: ((paramsRaw['tp_pct'] ?? 4) as num).toDouble(),
            ),
    );
  }

  final String id;
  final String status;
  final double progress;
  final String? error;
  final BacktestResult? result;
  final BacktestParams? params;
}

class BacktestParams {
  BacktestParams({
    required this.interval,
    required this.lookback,
    required this.step,
    required this.slPct,
    required this.tpPct,
    this.mode = 'ai',
  });

  final String interval;
  final int lookback;
  final int step;
  final double slPct;
  final double tpPct;
  final String mode;

  Map<String, dynamic> toJson() => {
        'interval': interval,
        'lookback': lookback,
        'step': step,
        'sl_pct': slPct,
        'tp_pct': tpPct,
        'mode': mode,
      };
}

Future<String> startBacktest(BacktestParams p) async {
  final uri = Uri.parse('$apiBase/api/backtest');
  late http.Response resp;
  try {
    resp = await http
        .post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(p.toJson()))
        .timeout(const Duration(seconds: 15));
  } catch (_) {
    throw ApiException('Backend unreachable at $apiBase');
  }
  if (resp.statusCode != 200) throw ApiException('HTTP ${resp.statusCode}: ${resp.body}');
  return jsonDecode(resp.body)['id'] as String;
}

Future<BacktestRun> fetchBacktest(String id) =>
    _get('/api/backtest/$id', (data) => BacktestRun.fromJson(data));

Future<List<BacktestRun>> fetchBacktests() =>
    _get('/api/backtests', (data) => [for (final r in data as List) BacktestRun.fromJson(r)]);

class SwingPoint {
  SwingPoint({required this.t, required this.price, required this.kind});
  final DateTime t;
  final double price;
  final String kind;
}

class StructureEvent {
  StructureEvent({
    required this.t,
    required this.type,
    required this.level,
    required this.price,
  });

  factory StructureEvent.fromJson(Map<String, dynamic> j) => StructureEvent(
        t: DateTime.fromMillisecondsSinceEpoch(j['t'] as int),
        type: j['type'] as String,
        level: (j['level'] as num).toDouble(),
        price: (j['price'] as num).toDouble(),
      );

  final DateTime t;
  final String type;
  final double level;
  final double price;
}

class StructureState {
  StructureState({
    required this.bias,
    required this.trendSinceMs,
    required this.flipLevel,
    required this.lastSwingHigh,
    required this.lastSwingLow,
    required this.events,
    required this.swings,
    required this.currentPrice,
  });

  factory StructureState.fromJson(Map<String, dynamic> j) => StructureState(
        bias: (j['bias'] ?? 'neutral') as String,
        trendSinceMs: (j['trend_since'] ?? 0) as int,
        flipLevel: (j['flip_level'] as num?)?.toDouble(),
        lastSwingHigh: j['last_swing_high'] == null
            ? null
            : SwingPoint(
                t: DateTime.fromMillisecondsSinceEpoch(j['last_swing_high']['t'] as int),
                price: (j['last_swing_high']['price'] as num).toDouble(),
                kind: 'high',
              ),
        lastSwingLow: j['last_swing_low'] == null
            ? null
            : SwingPoint(
                t: DateTime.fromMillisecondsSinceEpoch(j['last_swing_low']['t'] as int),
                price: (j['last_swing_low']['price'] as num).toDouble(),
                kind: 'low',
              ),
        events: [for (final e in (j['events'] ?? []) as List) StructureEvent.fromJson(e)],
        swings: [
          for (final s in (j['swings'] ?? []) as List)
            SwingPoint(
              t: DateTime.fromMillisecondsSinceEpoch(s['t'] as int),
              price: (s['price'] as num).toDouble(),
              kind: s['kind'] as String,
            ),
        ],
        currentPrice: (j['current_price'] as num).toDouble(),
      );

  final String bias;
  final int trendSinceMs;
  final double? flipLevel;
  final SwingPoint? lastSwingHigh;
  final SwingPoint? lastSwingLow;
  final List<StructureEvent> events;
  final List<SwingPoint> swings;
  final double currentPrice;

  DateTime get trendSinceLocal =>
      DateTime.fromMillisecondsSinceEpoch(trendSinceMs).toLocal();

  bool get isBullish => bias == 'bullish';
  bool get isBearish => bias == 'bearish';
}

Future<StructureState> fetchStructure({String interval = '4h', int k = 2}) =>
    _get('/api/structure?interval=$interval&k=$k', (data) => StructureState.fromJson(data));

Future<Map<String, dynamic>> fetchStrategy() => _get('/api/strategy', (data) => data);

Future<Map<String, dynamic>> setStrategy(String mode, {String? timeframe}) async {
  final uri = Uri.parse('$apiBase/api/strategy');
  final body = '{"mode": "$mode"${timeframe != null ? ', "timeframe": "$timeframe"' : ''}}';
  late http.Response resp;
  try {
    resp = await http
        .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
        .timeout(const Duration(seconds: 10));
  } catch (_) {
    throw ApiException('Backend unreachable at $apiBase');
  }
  if (resp.statusCode != 200) throw ApiException('HTTP ${resp.statusCode}');
  return jsonDecode(resp.body);
}
