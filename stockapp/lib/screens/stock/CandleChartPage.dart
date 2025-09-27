import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:k_chart_plus_deeping/entity/index.dart';
import 'package:k_chart_plus_deeping/k_chart_plus.dart';

class CandleChartPage extends StatefulWidget {
  const CandleChartPage({super.key});

  @override
  State<CandleChartPage> createState() => _CandleChartPageState();
}

class _CandleChartPageState extends State<CandleChartPage> {
  List<KLineEntity> datas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 🔹 Load dữ liệu JSON giả lập (có thể thay bằng Firestore realtime)
    final json = [
      {
        "open": 26800.0,
        "high": 27000.0,
        "low": 26500.0,
        "close": 26950.0,
        "vol": 12000,
        "time": 1695000000000
      },
      {
        "open": 26950.0,
        "high": 27200.0,
        "low": 26800.0,
        "close": 27100.0,
        "vol": 18000,
        "time": 1695100000000
      },
      // ... add thêm dữ liệu
    ];

    datas = json.map((e) => KLineEntity.fromJson(e)).toList();

    DataUtil.calculate(datas); // 🔹 Tính toán MA, BOLL, RSI...
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Biểu đồ chứng khoán")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : KChartWidget(
              datas,
              ChartStyle(),
              ChartColors(),
              isTrendLine: false,
              isLine: false, // false = nến, true = line chart
              mainState: MainState.mA, // hiển thị đường MA
              volHidden: false, // bật volume
              timeFormat: TimeFormat.yearMONTHDAY, // định dạng trục X
            ),
    );
  }
}
