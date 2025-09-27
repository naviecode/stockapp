// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:k_chart_plus_deeping/entity/index.dart';
// import 'package:k_chart_plus_deeping/k_chart_plus.dart';
// import 'package:provider/provider.dart';
// import 'package:stockapp/models/stock_model.dart';
// import 'package:stockapp/providers/stock_provider.dart';


// /// Widget chart realtime cho 1 stock (lấy dữ liệu từ StockProvider)
// class StockLiveKChart extends StatefulWidget {
//   final String stockId;
//   final double chartHeight;

//   const StockLiveKChart({
//     Key? key,
//     required this.stockId,
//     this.chartHeight = 360,
//   }) : super(key: key);

//   @override
//   State<StockLiveKChart> createState() => _StockLiveKChartState();
// }

// class _StockLiveKChartState extends State<StockLiveKChart> {
//   List<KLineEntity> datas = [];

//   @override
//   void initState() {
//     super.initState();
//     // đảm bảo provider đã lắng nghe realtime (nếu chưa)
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final prov = context.read<StockProvider>();
//       prov.listenStocks();
//     });
//   }

//   List<KLineEntity> _convertHistoryToKLine(List<PricePoint> history) {
//     // history nên đã sắp xếp tăng dần theo time. Nếu không, sort lại.
//     final sorted = List<PricePoint>.from(history)
//       ..sort((a, b) => a.time.compareTo(b.time));

//     // Convert từng PricePoint sang Map và dùng fromJson (named constructor)
//     final result = sorted.map((p) {
//       final price = p.price;
//       final map = <String, dynamic>{
//         'open': price,
//         'close': price,
//         'high': price,
//         'low': price,
//         'vol': 0.0,
//         'time': p.time.millisecondsSinceEpoch, // ms
//       };
//       return KLineEntity.fromJson(map);
//     }).toList();

//     // Nếu quá ít điểm, có thể duplicate vài điểm để tránh lỗi hiển thị
//     if (result.isEmpty) return result;
//     return result;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<StockProvider>(builder: (context, prov, child) {
//       final stock = prov.getStockById(widget.stockId);

//       if (stock == null) {
//         return const Center(child: Text("Không tìm thấy stock"));
//       }

//       // Convert history → KLineEntity
//       datas = _convertHistoryToKLine(stock.history);

//       // Nếu không có history hãy tạo 1 point từ giá hiện tại để chart vẫn vẽ được
//       if (datas.isEmpty) {
//         final now = DateTime.now().millisecondsSinceEpoch;
//         datas = [
//           KLineEntity.fromJson({
//             'open': stock.price,
//             'close': stock.price,
//             'high': stock.price,
//             'low': stock.price,
//             'vol': stock.volume.toDouble(),
//             'time': now,
//           })
//         ];
//       }

//       // Tính toán indicator (MA, BOLL, v.v.)
//       try {
//         DataUtil.calculate(datas);
//       } catch (_) {
//         // an toàn nếu calculate fail
//       }

//       // Tìm min/max để tính vị trí marker (y)
//       double minPrice = datas.map((e) => e.low).reduce(min);
//       double maxPrice = datas.map((e) => e.high).reduce(max);

//       final latestPrice = stock.price;
//       final chartH = widget.chartHeight;

//       // Tránh chia cho 0
//       double yPos;
//       if ((maxPrice - minPrice).abs() < 1e-9) {
//         yPos = chartH / 2;
//       } else {
//         final ratio = (latestPrice - minPrice) / (maxPrice - minPrice);
//         yPos = (1 - ratio) * chartH; // 0 -> top, chartH -> bottom
//       }

//       // clamp yPos
//       yPos = yPos.clamp(0.0, chartH);

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Basic info row (price + change)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("${stock.symbol} • ${stock.name}",
//                     style: const TextStyle(fontWeight: FontWeight.w600)),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text("\$${stock.price.toStringAsFixed(2)}",
//                         style: const TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     Text("${stock.changePercent.toStringAsFixed(2)}%",
//                         style: TextStyle(
//                             color: stock.changePercent >= 0
//                                 ? Colors.green
//                                 : Colors.red)),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Chart area with overlayed marker
//           SizedBox(
//             height: chartH,
//             child: Stack(
//               children: [
//                 // KChartWidget (candles)
//                 KChartWidget(
//                   datas,
//                   ChartStyle(),
//                   ChartColors(),
//                   mBaseHeight: chartH,
//                   isTrendLine: false,
//                   mainState: MainState.mA,
//                   volHidden: false,
//                   secondaryStateLi: <SecondaryState>{},
//                   fixedLength: 2,
//                   timeFormat: TimeFormat.yearMONTHDAY,
//                 ),

//                 // Horizontal marker line (approx position)
//                 Positioned(
//                   top: yPos - 0.5,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     height: 1,
//                     color: Colors.blue.withOpacity(0.9),
//                   ),
//                 ),

//                 // Small circle marker near the right edge
//                 Positioned(
//                   top: yPos - 6,
//                   right: 68,
//                   child: Container(
//                     width: 12,
//                     height: 12,
//                     decoration: BoxDecoration(
//                       color: Colors.blue,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: Colors.white, width: 1.5),
//                     ),
//                   ),
//                 ),

//                 // Price badge on the right (shows current price)
//                 Positioned(
//                   top: yPos - 16,
//                   right: 6,
//                   child: Container(
//                     padding:
//                         const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.blue,
//                       borderRadius: BorderRadius.circular(6),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.black.withOpacity(0.12),
//                             blurRadius: 4)
//                       ],
//                     ),
//                     child: Text(
//                       "\$${latestPrice.toStringAsFixed(2)}",
//                       style: const TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.w700),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 8),

//           // Optional: basic stats
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Khối lượng: ${stock.volume}"),
//                 Text("Updated: ${stock.updatedAt.toDate()}"),
//               ],
//             ),
//           ),
//         ],
//       );
//     });
//   }
// }

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

