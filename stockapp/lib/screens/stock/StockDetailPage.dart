import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:k_chart_plus_deeping/k_chart_plus.dart';
import 'package:provider/provider.dart';
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

        if (showLoading) {
          Future.microtask(() => setState(() => showLoading = false));
        }
        
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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user; 
    final isUserReady = user != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: isUserReady ? () => _showTradeDialog(context, "BUY", stock) : null,
              child: const Text("Mua"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: isUserReady ? () => _showTradeDialog(context, "SELL", stock) : null,
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
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                backgroundColor: Colors.blue, 
              ),
            onPressed: () async  {
              final qty = int.tryParse(quantityCtrl.text) ?? 0;
              if (qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Vui lòng nhập số lượng hợp lệ")),
                );
                return;
              }

              final provider = Provider.of<PortfolioProvider>(context, listen: false);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final userId = auth.user?.uid; 

              try {
                await provider.tradeStock(
                  userId: userId,
                  stockId: stock.id,
                  type: type,
                  quantity: qty,
                  price: stock.price,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(
                    "$type ${stock.symbol} x $qty thành công"
                  )),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi: ${e.toString()}")),
                );
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

