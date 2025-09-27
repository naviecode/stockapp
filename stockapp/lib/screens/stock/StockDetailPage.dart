// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:k_chart_plus_deeping/k_chart_plus.dart';
// import 'package:stockapp/models/stock_model.dart';

// class StockDetailPage extends StatefulWidget {
//   final StockModel stock;

//   const StockDetailPage({super.key, required this.stock});

//   @override
//   State<StockDetailPage> createState() => _StockDetailPageState();
// }

// class _StockDetailPageState extends State<StockDetailPage> {
//   List<KLineEntity>? datas;
//   bool showLoading = true;
//   bool _volHidden = false;
//   MainState _mainState = MainState.mA;
//   final List<SecondaryState> _secondaryStateLi = [];

//   ChartStyle chartStyle = ChartStyle();
//   ChartColors chartColors = ChartColors();

//   @override
//   void initState() {
//     super.initState();
//     getData('1day');
//     loadDepth(); // Nếu muốn DepthChart
//   }

//   /// Depth chart
//   List<DepthEntity>? _bids, _asks;
//   void loadDepth() async {
//     try {
//       final result = await rootBundle.loadString('assets/depth.json');
//       final parseJson = json.decode(result);
//       final tick = parseJson['tick'] as Map<String, dynamic>;
//       final List<DepthEntity> bids = (tick['bids'] as List<dynamic>)
//           .map<DepthEntity>(
//               (item) => DepthEntity(item[0] as double, item[1] as double))
//           .toList();
//       final List<DepthEntity> asks = (tick['asks'] as List<dynamic>)
//           .map<DepthEntity>(
//               (item) => DepthEntity(item[0] as double, item[1] as double))
//           .toList();
//       initDepth(bids, asks);
//     } catch (e) {
//       debugPrint("Không load được depth.json: $e");
//     }
//   }

//   void initDepth(List<DepthEntity>? bids, List<DepthEntity>? asks) {
//     if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
//     _bids = [];
//     _asks = [];
//     double amount = 0.0;
//     bids.sort((left, right) => left.price.compareTo(right.price));
//     for (var item in bids.reversed) {
//       amount += item.vol;
//       item.vol = amount;
//       _bids!.insert(0, item);
//     }

//     amount = 0.0;
//     asks.sort((left, right) => left.price.compareTo(right.price));
//     for (var item in asks) {
//       amount += item.vol;
//       item.vol = amount;
//       _asks!.add(item);
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("${widget.stock.symbol} - ${widget.stock.name}")),
//       body: ListView(
//         shrinkWrap: true,
//         children: [
//           const SizedBox(height: 10),
//           Stack(children: [
//             KChartWidget(
//               datas,
//               chartStyle,
//               chartColors,
//               mBaseHeight: 360,
//               isTrendLine: false,
//               mainState: _mainState,
//               volHidden: _volHidden,
//               secondaryStateLi: _secondaryStateLi.toSet(),
//               fixedLength: 2,
//               timeFormat: TimeFormat.yearMONTHDAY,
//             ),
//             if (showLoading)
//               Container(
//                 width: double.infinity,
//                 height: 450,
//                 alignment: Alignment.center,
//                 child: const CircularProgressIndicator(),
//               ),
//           ]),
//           _buildTitle(context, 'VOL'),
//           buildVolButton(),
//           _buildTitle(context, 'Main State'),
//           buildMainButtons(),
//           _buildTitle(context, 'Secondary State'),
//           buildSecondButtons(),
//           const SizedBox(height: 30),
//           if (_bids != null && _asks != null)
//             Container(
//               color: Colors.white,
//               height: 320,
//               width: double.infinity,
//               child: DepthChart(_bids!, _asks!, chartColors),
//             ),
//           const SizedBox(height: 16),

//           /// NÚT MUA / BÁN
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                     onPressed: () => _showTradeDialog(context, "BUY"),
//                     child: const Text("Mua"),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                     onPressed: () => _showTradeDialog(context, "SELL"),
//                     child: const Text("Bán"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTitle(BuildContext context, String title) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 20, 12, 15),
//       child: Text(
//         title,
//         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//       ),
//     );
//   }

//   Widget buildVolButton() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: _buildButton(
//           context: context,
//           title: 'VOL',
//           isActive: !_volHidden,
//           onPress: () {
//             _volHidden = !_volHidden;
//             setState(() {});
//           },
//         ),
//       ),
//     );
//   }

//   Widget buildMainButtons() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Wrap(
//         alignment: WrapAlignment.start,
//         spacing: 10,
//         runSpacing: 10,
//         children: MainState.values.map((e) {
//           return _buildButton(
//             context: context,
//             title: e.name,
//             isActive: _mainState == e,
//             onPress: () => _mainState = e,
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget buildSecondButtons() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Wrap(
//         alignment: WrapAlignment.start,
//         spacing: 10,
//         runSpacing: 5,
//         children: SecondaryState.values.map((e) {
//           bool isActive = _secondaryStateLi.contains(e);
//           return _buildButton(
//             context: context,
//             title: e.name,
//             isActive: isActive,
//             onPress: () {
//               if (isActive) {
//                 _secondaryStateLi.remove(e);
//               } else {
//                 _secondaryStateLi.add(e);
//               }
//               setState(() {});
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildButton({
//     required BuildContext context,
//     required String title,
//     required bool isActive,
//     required Function onPress,
//   }) {
//     Color? bgColor, txtColor;
//     if (isActive) {
//       bgColor = Theme.of(context).primaryColor.withOpacity(.15);
//       txtColor = Theme.of(context).primaryColor;
//     } else {
//       bgColor = Colors.transparent;
//       txtColor = Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(.75);
//     }
//     return InkWell(
//       onTap: () {
//         onPress();
//         setState(() {});
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(6),
//         ),
//         constraints: const BoxConstraints(minWidth: 60),
//         padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//         child: Text(title, style: TextStyle(color: txtColor)),
//       ),
//     );
//   }

//   void getData(String period) async {
//     try {
//       final result = await getChatDataFromInternet(period);
//       solveChatData(result);
//     } catch (error) {
//       showLoading = false;
//       setState(() {});
//       debugPrint('### datas error $error');
//     }
//   }

//   Future<String> getChatDataFromInternet(String? period) async {
//     var url =
//         'https://api.huobi.br.com/market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcusdt';
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       return response.body;
//     } else {
//       throw Exception("Failed to load data");
//     }
//   }

//   void solveChatData(String result) {
//     final parseJson = json.decode(result) as Map<String, dynamic>;
//     if (parseJson['data'] == null) {
//       showLoading = false;
//       setState(() {});
//       debugPrint("API trả về dữ liệu null");
//       return;
//     }
//     final list = parseJson['data'] as List<dynamic>;
//     datas = list
//         .map((item) => KLineEntity.fromJson(item as Map<String, dynamic>))
//         .toList()
//         .reversed
//         .toList()
//         .cast<KLineEntity>();
//     DataUtil.calculate(datas!);
//     setState(() {
//       showLoading = false;
//     });
//   }

//   void _showTradeDialog(BuildContext context, String type) {
//     final TextEditingController quantityCtrl = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(type == "BUY" ? "Mua cổ phiếu" : "Bán cổ phiếu"),
//         content: TextField(
//           controller: quantityCtrl,
//           keyboardType: TextInputType.number,
//           decoration: const InputDecoration(labelText: "Số lượng"),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Hủy"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final qty = int.tryParse(quantityCtrl.text) ?? 0;
//               if (qty > 0) {
//                 print("$type ${widget.stock.symbol} x $qty");
//               }
//               Navigator.pop(context);
//             },
//             child: const Text("Xác nhận"),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:k_chart_plus_deeping/k_chart_plus.dart';
import 'package:stockapp/models/stock_model.dart';

class StockDetailPage extends StatefulWidget {
  final String stockId; // document id trong Firestore

  const StockDetailPage({super.key, required this.stockId});

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  bool showLoading = true;
  bool _volHidden = false;
  MainState _mainState = MainState.mA;
  final List<SecondaryState> _secondaryStateLi = [];

  ChartStyle chartStyle = ChartStyle();
  ChartColors chartColors = ChartColors();

  List<KLineEntity>? datas;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("stocks")
          .doc(widget.stockId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final stock = StockModel.fromFirestore(snapshot.data!);
        
        return _buildStockDetail(stock);
      },
    );
  }

  Widget _buildStockDetail(StockModel stock) {
    datas = stock.history
        .map((p) => KLineEntity.fromCustom(
              open: p.open,
              close: p.close,
              high: p.high,
              low: p.low,
              vol: 0, // Nếu có volume, thay số 0 thành p.volume nếu bạn bổ sung volume
              time: p.time.millisecondsSinceEpoch,
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text("${stock.symbol} - ${stock.name}")),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(12),
        children: [
          Stack(children: [
            SizedBox(
              height: 360,
              child: KChartWidget(
                datas,
                chartStyle,
                chartColors,
                mBaseHeight: 360,
                isTrendLine: true,
                mainState: _mainState,
                volHidden: _volHidden,
                secondaryStateLi: _secondaryStateLi.toSet(),
                fixedLength: 2,
                timeFormat: TimeFormat.yearMONTHDAY,
              ),
            ),
            if (showLoading)
              Container(
                width: double.infinity,
                height: 450,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
          ]),
          _buildTitle(context, 'VOL'),
          buildVolButton(),
          _buildTitle(context, 'Main State'),
          buildMainButtons(),
          _buildTitle(context, 'Secondary State'),
          buildSecondButtons(),
          const SizedBox(height: 30),
          _buildTradeButtons(stock),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget buildVolButton() {
    return _buildButton(context, 'VOL', !_volHidden, () {
      _volHidden = !_volHidden;
      setState(() {});
    });
  }

  Widget buildMainButtons() {
    return Wrap(
      spacing: 10,
      children: MainState.values
          .map((e) => _buildButton(context, e.name, _mainState == e, () {
                _mainState = e;
                setState(() {});
              }))
          .toList(),
    );
  }

  Widget buildSecondButtons() {
    return Wrap(
      spacing: 10,
      children: SecondaryState.values
          .map((e) => _buildButton(context, e.name, _secondaryStateLi.contains(e),
              () {
            if (_secondaryStateLi.contains(e)) {
              _secondaryStateLi.remove(e);
            } else {
              _secondaryStateLi.add(e);
            }
            setState(() {});
          }))
          .toList(),
    );
  }

  Widget _buildButton(
      BuildContext context, String title, bool isActive, Function onPress) {
    Color? bgColor, txtColor;
    if (isActive) {
      bgColor = Theme.of(context).primaryColor.withOpacity(.15);
      txtColor = Theme.of(context).primaryColor;
    } else {
      bgColor = Colors.transparent;
      txtColor =
          Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(.75);
    }
    return InkWell(
      onTap: () => onPress(),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Text(title, style: TextStyle(color: txtColor)),
      ),
    );
  }

  Widget _buildTradeButtons(StockModel stock) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => _showTradeDialog(context, "BUY", stock),
              child: const Text("Mua"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _showTradeDialog(context, "SELL", stock),
              child: const Text("Bán"),
            ),
          ),
        ],
      ),
    );
  }

  void _showTradeDialog(BuildContext context, String type, StockModel stock) {
    final TextEditingController quantityCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(type == "BUY" ? "Mua cổ phiếu" : "Bán cổ phiếu"),
        content: TextField(
          controller: quantityCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Số lượng"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(quantityCtrl.text) ?? 0;
              if (qty > 0) {
                print("$type ${stock.symbol} x $qty");
              }
              Navigator.pop(context);
            },
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }
}

