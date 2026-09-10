import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'api.dart';

enum FeedState { connecting, live, reconnecting }

class BinanceStream {
  BinanceStream({this.symbol = 'btcusdt'});

  final String symbol;

  final ValueNotifier<Ticker?> ticker = ValueNotifier(null);
  final ValueNotifier<List<Candle>> candles = ValueNotifier([]);
  final ValueNotifier<FeedState> state = ValueNotifier(FeedState.connecting);

  WebSocketChannel? _channel;
  Timer? _retry;
  String _interval = '1h';
  int _failures = 0;
  bool _disposed = false;

  static const _primaryHost = 'stream.binance.com:9443';
  static const _mirrorHost = 'data-stream.binance.vision';
  static const _maxCandles = 300;

  String get _host => (_failures ~/ 3).isOdd ? _mirrorHost : _primaryHost;

  void start(String interval) {
    if (_disposed) return;
    _interval = interval;
    _failures = 0;
    state.value = FeedState.connecting;
    _connect();
  }

  void setInterval(String interval) {
    if (interval == _interval) return;
    start(interval);
  }

  void _connect() {
    if (_disposed) return;
    _retry?.cancel();
    final streams = '$symbol@ticker/$symbol@kline_$_interval';
    final uri = Uri.parse('wss://$_host/stream?streams=$streams');
    try {
      _channel = WebSocketChannel.connect(uri);
      _channel!.stream.listen(_onData, onError: (_) => _onDown(), onDone: _onDown);
    } catch (_) {
      _onDown();
    }
  }

  void _onData(dynamic raw) {
    if (_disposed) return;
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final streamName = msg['stream'] as String? ?? '';
      final data = msg['data'] as Map<String, dynamic>?;

      if (data == null) return;

      if (streamName.endsWith('@ticker')) {
        ticker.value = Ticker(
          price: double.parse(data['c'] as String),
          changePct: double.parse(data['P'] as String),
          high: double.parse(data['h'] as String),
          low: double.parse(data['l'] as String),
        );
        if (state.value != FeedState.live) {
          state.value = FeedState.live;
          _failures = 0;
        }
      } else if (data['e'] == 'kline') {
        _upsertCandle(data['k'] as Map<String, dynamic>);
        if (state.value != FeedState.live) {
          state.value = FeedState.live;
          _failures = 0;
        }
      }
    } catch (_) {}
  }

  void _upsertCandle(Map<String, dynamic> k) {
    final c = Candle(
      time: DateTime.fromMillisecondsSinceEpoch(k['t'] as int),
      open: double.parse(k['o'] as String),
      high: double.parse(k['h'] as String),
      low: double.parse(k['l'] as String),
      close: double.parse(k['c'] as String),
      volume: double.parse(k['v'] as String),
    );
    final list = List<Candle>.of(candles.value);
    if (list.isEmpty || list.last.time.isBefore(c.time)) {
      list.add(c);
      if (list.length > _maxCandles) list.removeAt(0);
    } else {
      for (var i = list.length - 1; i >= 0; i--) {
        if (list[i].time == c.time) {
          list[i] = c;
          break;
        }
        if (list[i].time.isBefore(c.time)) break;
      }
    }
    candles.value = list;
  }

  void _onDown() {
    if (_disposed) return;
    state.value = FeedState.reconnecting;
    _channel?.sink.close();
    _channel = null;
    _failures++;
    final delay = Duration(seconds: _failures > 5 ? 30 : 2 * _failures);
    _retry?.cancel();
    _retry = Timer(delay, _connect);
  }

  void dispose() {
    _disposed = true;
    _retry?.cancel();
    _channel?.sink.close();
    ticker.dispose();
    state.dispose();
  }
}
