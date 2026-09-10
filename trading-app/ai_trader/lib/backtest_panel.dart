import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'api.dart';

final _money = NumberFormat('#,##0.00');
final _timeFmt = DateFormat('MM/dd HH:mm');

const _up = Color(0xFF26A69A);
const _down = Color(0xFFEF5350);
const _textDim = Color(0xFF8B949E);
const _panel = Color(0xFF161B22);

class BacktestPanel extends StatefulWidget {
  const BacktestPanel({super.key});

  @override
  State<BacktestPanel> createState() => _BacktestPanelState();
}

class _BacktestPanelState extends State<BacktestPanel> {
  List<BacktestRun> _runs = [];
  String? _activeId;
  Timer? _poll;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final runs = await fetchBacktests();
      if (!mounted) return;
      setState(() {
        _runs = runs;
        _loading = false;
        final running = runs.where((r) => r.status == 'running').toList();
        _activeId = running.isEmpty ? null : running.first.id;
      });
      if (_activeId != null && _poll == null) {
        _poll = Timer.periodic(const Duration(seconds: 4), (_) => _refresh());
      } else if (_activeId == null) {
        _poll?.cancel();
        _poll = null;
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openRunDialog() async {
    final started = await showDialog<bool>(
      context: context,
      builder: (_) => const _BacktestDialog(),
    );
    if (started == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _panel,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                FilledButton.icon(
                  onPressed: _openRunDialog,
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('New backtest', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    backgroundColor: _up,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 10),
                Text('AI walks history · simulated fills · SL/TP enforced',
                    style: const TextStyle(fontSize: 11, color: _textDim)),
              ],
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_runs.isEmpty) return Center(child: Text('No backtest runs yet', style: const TextStyle(color: _textDim)));
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      itemCount: _runs.length,
      itemBuilder: (_, i) => _runCard(_runs[i]),
    );
  }

  Widget _runCard(BacktestRun run) {
    final p = run.params;
    final isRunning = run.status == 'running';
    final failed = run.status == 'failed';
    final r = run.result;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('#${run.id.substring(0, 6)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 8),
                if (p != null)
                  Text('${p.interval} · ${p.lookback} candles · step ${p.step}h · SL ${_money.format(p.slPct)}% / TP ${_money.format(p.tpPct)}%',
                      style: const TextStyle(fontSize: 11, color: _textDim)),
                const Spacer(),
                if (isRunning)
                  Text('${run.progress.toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                if (failed)
                  const Text('FAILED', style: TextStyle(color: _down, fontSize: 11, fontWeight: FontWeight.bold)),
                if (r != null)
                  Text(
                    '${r.pnl >= 0 ? '+' : ''}\$${_money.format(r.pnl)} (${r.pnlPct >= 0 ? '+' : ''}${r.pnlPct}%)',
                    style: TextStyle(color: r.pnl >= 0 ? _up : _down, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
              ],
            ),
            if (isRunning)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: run.progress / 100, minHeight: 6, backgroundColor: Colors.white10, color: Colors.amber),
                ),
              ),
            if (failed && run.error != null)
              Padding(padding: const EdgeInsets.only(top: 6), child: Text(run.error!, style: const TextStyle(color: _down, fontSize: 11))),
            if (r != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  _stat('Final equity', '\$${_money.format(r.finalEquity)}'),
                  _stat('Trades', '${r.trades}'),
                  _stat('Win rate', '${r.winRate}%'),
                  _stat('W/L', '${r.wins}/${r.losses}'),
                  _stat('Max DD', '-${r.maxDrawdownPct}%'),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: _equityChart(r),
              ),
              if (r.tradeLog.isNotEmpty) ...[
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: r.tradeLog.length,
                    itemBuilder: (_, i) {
                      final t = r.tradeLog[r.tradeLog.length - 1 - i];
                      final buy = t.side == 'buy';
                      final c = buy ? _up : _down;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 42,
                              child: Text(t.side.toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c)),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text(_timeFmt.format(t.t.toLocal()),
                                  style: const TextStyle(fontSize: 10, color: _textDim)),
                            ),
                            SizedBox(
                              width: 90,
                              child: Text('\$${_money.format(t.price)}',
                                  style: const TextStyle(fontSize: 11)),
                            ),
                            Expanded(child: Text(t.reason, style: const TextStyle(fontSize: 10, color: _textDim), overflow: TextOverflow.ellipsis)),
                            if (!buy && t.pnl != null)
                              SizedBox(
                                width: 55,
                                child: Text('${t.pnl! >= 0 ? '+' : ''}${t.pnl!.toStringAsFixed(2)}%',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: t.pnl! >= 0 ? _up : _down)),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Padding(
        padding: const EdgeInsets.only(right: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: _textDim, letterSpacing: 0.5)),
            const SizedBox(height: 1),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _equityChart(BacktestResult r) {
    return SfCartesianChart(
      backgroundColor: const Color(0xFF0E1116),
      plotAreaBorderColor: const Color(0xFF22272F),
      primaryXAxis: DateTimeAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelStyle: const TextStyle(fontSize: 9, color: _textDim),
        labelIntersectAction: AxisLabelIntersectAction.hide,
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0.3, color: Color(0xFF1C2128)),
        axisLine: const AxisLine(width: 0),
        labelStyle: const TextStyle(fontSize: 9, color: _textDim),
        numberFormat: NumberFormat.compact(),
      ),
      series: [
        LineSeries<EquityPoint, DateTime>(
          dataSource: r.equityCurve,
          xValueMapper: (pt, _) => pt.time,
          yValueMapper: (pt, _) => pt.equity,
          color: r.pnl >= 0 ? _up : _down,
          width: 1.8,
          animationDuration: 0,
        ),
      ],
    );
  }
}

class _BacktestDialog extends StatefulWidget {
  const _BacktestDialog();

  @override
  State<_BacktestDialog> createState() => _BacktestDialogState();
}

class _BacktestDialogState extends State<_BacktestDialog> {
  String _mode = 'ai';
  String _interval = '1h';
  final _lookback = TextEditingController(text: '300');
  final _step = TextEditingController(text: '6');
  final _sl = TextEditingController(text: '2');
  final _tp = TextEditingController(text: '4');
  bool _starting = false;
  String? _error;

  @override
  void dispose() {
    _lookback.dispose();
    _step.dispose();
    _sl.dispose();
    _tp.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      await startBacktest(BacktestParams(
        interval: _interval,
        lookback: int.tryParse(_lookback.text) ?? 300,
        step: int.tryParse(_step.text) ?? 6,
        slPct: double.tryParse(_sl.text) ?? 2,
        tpPct: double.tryParse(_tp.text) ?? 4,
        mode: _mode,
      ));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _starting = false;
          _error = '$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _panel,
      title: const Text('Run backtest', style: TextStyle(fontSize: 17)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Strategy', style: TextStyle(fontSize: 11, color: _textDim)),
            Wrap(
              spacing: 6,
              children: [
                for (final m in const [('ai', 'AI'), ('structure', 'Structure')])
                  ChoiceChip(
                    label: Text(m.$2),
                    selected: _mode == m.$1,
                    onSelected: (_) => setState(() => _mode = m.$1),
                    selectedColor: Colors.amber.withValues(alpha: 0.25),
                    labelStyle: TextStyle(fontSize: 12, color: _mode == m.$1 ? Colors.amber : _textDim),
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Interval', style: TextStyle(fontSize: 11, color: _textDim)),
            Wrap(
              spacing: 6,
              children: [
                for (final i in ['15m', '1h', '4h', '1d'])
                  ChoiceChip(
                    label: Text(i),
                    selected: _interval == i,
                    onSelected: (_) => setState(() => _interval = i),
                    selectedColor: _up.withValues(alpha: 0.25),
                    labelStyle: TextStyle(fontSize: 12, color: _interval == i ? _up : _textDim),
                    showCheckmark: false,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            _field('History length (candles, max 1000)', _lookback),
            _field('Decision step (candles)', _step),
            Row(children: [
              Expanded(child: _field('Stop loss %', _sl)),
              const SizedBox(width: 10),
              Expanded(child: _field('Take profit %', _tp)),
            ]),
            const SizedBox(height: 6),
            Text(
              _mode == 'structure'
                  ? 'Structure rules replay instantly · SL from broken swing level, TP at last swing high (SL/TP % ignored)'
                  : '~${((int.tryParse(_lookback.text) ?? 300) / (int.tryParse(_step.text) ?? 6)).toStringAsFixed(0)} AI decisions — each takes ~15s',
              style: TextStyle(fontSize: 11, color: _mode == 'structure' ? _up : Colors.amber),
            ),
            if (_error != null)
              Padding(padding: const EdgeInsets.only(top: 6), child: Text(_error!, style: const TextStyle(color: _down, fontSize: 11))),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        FilledButton(
          onPressed: _starting ? null : _start,
          style: FilledButton.styleFrom(backgroundColor: _up, foregroundColor: Colors.black),
          child: _starting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Start'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController c) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 12, color: _textDim),
            filled: true,
            fillColor: const Color(0xFF0E1116),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      );
}
