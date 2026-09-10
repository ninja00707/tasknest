import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TvChart extends StatelessWidget {
  const TvChart({super.key, required this.interval});

  final String interval;

  static const _tvIntervals = {'15m': '15', '1h': '60', '4h': '240', '1d': 'D'};
  static const _taIntervals = {'15m': '15m', '1h': '1h', '4h': '4h', '1d': '1D'};

  String get _html {
    final iv = _tvIntervals[interval] ?? '60';
    final taIv = _taIntervals[interval] ?? '1h';
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  html,body{margin:0;padding:0;height:100%;background:#131722;overflow:hidden}
  body{display:flex;flex-direction:column}
  .chartwrap{flex:1;min-height:0}
  .tawrap{height:400px;flex:none;border-top:1px solid #2a2e39}
  .tradingview-widget-container,.tradingview-widget-container__widget{height:100%;width:100%}
</style>
</head>
<body>
<div class="chartwrap">
  <div class="tradingview-widget-container">
    <div id="tv_chart" class="tradingview-widget-container__widget"></div>
  </div>
</div>
<div class="tawrap">
  <div class="tradingview-widget-container">
    <div class="tradingview-widget-container__widget"></div>
  </div>
</div>
<script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
<script type="text/javascript">
new TradingView.widget({
  container_id: "tv_chart",
  autosize: true,
  symbol: "BINANCE:BTCUSDT",
  interval: "$iv",
  timezone: "Etc/UTC",
  theme: "dark",
  style: "1",
  locale: "en",
  hide_side_toolbar: false,
  allow_symbol_change: false,
  save_image: false,
  withdateranges: true,
  details: false,
  calendar: false
});
</script>
<script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-technical-analysis.js" async>
{
  "interval": "$taIv",
  "width": "100%",
  "height": "100%",
  "isTransparent": true,
  "symbol": "BINANCE:BTCUSDT",
  "showIntervalTabs": true,
  "displayMode": "single",
  "locale": "en",
  "colorTheme": "dark"
}
</script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(interval),
      child: InAppWebView(
        initialData: InAppWebViewInitialData(
          data: _html,
          mimeType: 'text/html',
          encoding: 'utf-8',
        ),
        initialSettings: InAppWebViewSettings(
          transparentBackground: true,
          supportZoom: true,
          disableContextMenu: false,
        ),
      ),
    );
  }
}
