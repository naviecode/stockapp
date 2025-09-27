import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:k_chart_plus_deeping/k_chart_plus.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/models/portfolio_model.dart';
import 'package:stockapp/models/stock_model.dart';
import 'package:stockapp/providers/auth_provider.dart';
import 'package:stockapp/providers/portfolio_provider.dart';

class StockDetailPage extends StatefulWidget {
  final String stockId;

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

  final vndFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

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
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            ),
          );
        }

        final stock = StockModel.fromFirestore(snapshot.data!);

        if (showLoading) {
          Future.microtask(() => setState(() => showLoading = false));
        }

        return _buildStockDetail(stock);
      },
    );
  }

  Widget _buildStockDetail(StockModel stock) {
    final provider = context.watch<PortfolioProvider>();

    datas = stock.history
        .map((p) => KLineEntity.fromCustom(
              open: p.open,
              close: p.close,
              high: p.high,
              low: p.low,
              vol: 0,
              time: p.time.millisecondsSinceEpoch,
            ))
        .toList();

    final ownedQty = provider.portfolio?.quantityOf(stock.id) ?? 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "${stock.symbol} - ${stock.name}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
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
                child: const CircularProgressIndicator(color: Colors.greenAccent),
              ),
          ]),
          _buildTitle(context, 'VOL'),
          buildVolButton(),
          _buildTitle(context, 'Main State'),
          buildMainButtons(),
          _buildTitle(context, 'Secondary State'),
          buildSecondButtons(),
          const SizedBox(height: 30),

          // Thêm block giá + số lượng sở hữu + nút mua/bán
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Giá hiện tại: ${vndFormat.format(stock.price)} "
                "(${stock.changePercent >= 0 ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%)",
                style: TextStyle(
                  color: stock.changePercent >= 0
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Bạn đang sở hữu: $ownedQty cổ phiếu",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildTradeButtons(stock),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget buildVolButton() {
    return Wrap(
      spacing: 10,
      children: [
        _buildButton(context, 'VOL', !_volHidden, () {
          _volHidden = !_volHidden;
          setState(() {});
        }),
      ],
    );
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
          .map((e) =>
              _buildButton(context, e.name, _secondaryStateLi.contains(e), () {
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
      bgColor = Colors.greenAccent.withOpacity(.15);
      txtColor = Colors.greenAccent;
    } else {
      bgColor = Colors.transparent;
      txtColor = Colors.white70;
    }
    return InkWell(
      onTap: () => onPress(),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Text(title, style: TextStyle(color: txtColor)),
      ),
    );
  }

  Widget _buildTradeButtons(StockModel stock) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    final isUserReady = user != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed:
                  isUserReady ? () => _showTradeDialog(context, "BUY", stock) : null,
              child: const Text("Mua"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed:
                  isUserReady ? () => _showTradeDialog(context, "SELL", stock) : null,
              child: const Text("Bán"),
            ),
          ),
        ],
      ),
    );
  }

  void _showTradeDialog(BuildContext context, String type, StockModel stock) {
    final TextEditingController quantityCtrl = TextEditingController();
    bool isLoading = false;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.uid;
    final provider = Provider.of<PortfolioProvider>(context, listen: false);

    int ownedQty = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                type == "BUY" ? "Mua cổ phiếu" : "Bán cổ phiếu",
                style: const TextStyle(color: Colors.white),
              ),
              content: FutureBuilder<PortfolioModel?>(
                future: provider.portfolio != null
                    ? Future.value(provider.portfolio)
                    : provider.fetchPortfolioOnce(userId ?? ""),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 60,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.greenAccent),
                      ),
                    );
                  }

                  final portfolio = snapshot.data;
                  ownedQty = portfolio?.quantityOf(stock.id) ?? 0;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (type == "SELL")
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "Bạn đang sở hữu: $ownedQty cổ phiếu",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      TextField(
                        controller: quantityCtrl,
                        keyboardType: TextInputType.number,
                        enabled: !isLoading,
                        style: const TextStyle(color: Colors.white), // chữ nhập trắng
                        decoration: InputDecoration(
                          hintText: "Số lượng",
                          hintStyle: const TextStyle(color: Colors.white54),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                      Visibility(
                        visible: isLoading,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: const CircularProgressIndicator(color: Colors.greenAccent),
                        ),
                      ),
                    ],
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    "Hủy",
                    style: TextStyle(color: Colors.white70), // nhẹ nhàng hơn
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    backgroundColor: Colors.blueAccent, // màu rõ hơn
                    foregroundColor: Colors.white,       // chữ trắng
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: isLoading ? null : () async {
                      final qty = int.tryParse(quantityCtrl.text) ?? 0;
                      if (qty <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Vui lòng nhập số lượng hợp lệ")));
                        return;
                      }

                      if (type == "SELL" && qty > ownedQty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Số lượng bán vượt quá số lượng sở hữu")));
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        await provider.tradeStock(
                          userId: userId,
                          stockId: stock.id,
                          type: type,
                          quantity: qty,
                          price: stock.price,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "$type ${stock.symbol} x $qty thành công")));

                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Lỗi: ${e.toString()}")));
                        setState(() => isLoading = false);
                      }
                  },
                  child: const Text("Xác nhận"),
                ),
              ],
            );

          },
        );
      },
    );
  }
}
