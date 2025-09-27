import 'dart:async';
import 'package:flutter/material.dart';
import 'package:k_chart_plus_deeping/k_chart_plus.dart';
import 'package:stockapp/models/stock_model.dart';

class StockChartWidget extends StatefulWidget {
  final StockModel stock;
  final bool volHidden;
  final MainState mainState;
  final Set<SecondaryState> secondaryStates;

  const StockChartWidget({
    super.key,
    required this.stock,
    this.volHidden = false,
    this.mainState = MainState.mA,
    this.secondaryStates = const {},
  });

  @override
  State<StockChartWidget> createState() => _StockChartWidgetState();
}

class _StockChartWidgetState extends State<StockChartWidget> {
  List<KLineEntity> _datas = [];
  Timer? _throttleTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _datas = widget.stock.history
        .map((p) => KLineEntity.fromCustom(
              open: p.open,
              close: p.close,
              high: p.high,
              low: p.low,
              vol: 0,
              time: p.time.millisecondsSinceEpoch,
            ))
        .takeLast(100)
        .toList();
  }

  /// Gọi hàm này mỗi khi Python bắn dữ liệu mới
  void onNewData(List<PricePoint> newHistory) {
    if (!mounted) return;

    // Throttle để chart không bị lag nếu data quá dày
    if (_throttleTimer?.isActive ?? false) return;
    _throttleTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _datas = newHistory
            .map((p) => KLineEntity.fromCustom(
                  open: p.open,
                  close: p.close,
                  high: p.high,
                  low: p.low,
                  vol: 0,
                  time: p.time.millisecondsSinceEpoch,
                ))
            .takeLast(100)
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: KChartWidget(
        _datas,
        ChartStyle(),
        ChartColors(),
        mainState: widget.mainState,
        volHidden: widget.volHidden,
        secondaryStateLi: widget.secondaryStates,
        isTrendLine: true,
      ),
    );
  }
}

/// Extension tiện lợi: lấy n phần tử cuối
extension TakeLastExtension<E> on Iterable<E> {
  Iterable<E> takeLast(int n) => skip(length - n < 0 ? 0 : length - n);
}
