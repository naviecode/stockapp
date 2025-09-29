import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:k_chart_plus_deeping/k_chart_plus.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:stockapp/models/portfolio_model.dart';
import 'package:stockapp/models/stock_model.dart';
import 'package:stockapp/providers/auth_provider.dart';
import 'package:stockapp/providers/portfolio_provider.dart';
import 'package:stockapp/screens/stock/stock_chart_widget.dart';
import 'package:stockapp/utils/toast_helper.dart';

class StockDetailPage extends StatefulWidget {
  final String stockId;

  const StockDetailPage({super.key, required this.stockId});

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  bool showLoading = true;
  bool _volHidden = false;

  final GlobalKey<State<StockChartWidget>> chartWidgetKey = GlobalKey();

  MainState _mainState = MainState.mA;
  final List<SecondaryState> _secondaryStateLi = [];

  final vndFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("stocks")
          .doc(widget.stockId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            ),
          );
        }

        final stock = StockModel.fromFirestore(snapshot.data!);

        // Update dữ liệu chart
        WidgetsBinding.instance.addPostFrameCallback((_) {
          (chartWidgetKey.currentState as dynamic)?.onNewData(stock.history);
        });

        if (showLoading) {
          Future.microtask(() => setState(() => showLoading = false));
        }

        return _buildStockDetail(stock, theme);
      },
    );
  }

  Widget _buildStockDetail(StockModel stock, ThemeData theme) {
    final provider = context.watch<PortfolioProvider>();
    final ownedQty = provider.portfolio?.quantityOf(stock.id) ?? 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "${stock.symbol} - ${stock.name}",
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        elevation: 0,
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(12),
        children: [
          Stack(children: [
            StockChartWidget(
              key: chartWidgetKey,
              stock: stock,
              volHidden: _volHidden,
              mainState: _mainState,
              secondaryStates: _secondaryStateLi.toSet(),
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
          // Block giá + số lượng sở hữu + nút mua/bán
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
                "Bạn đang sở hữu: $ownedQty coin",
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              _buildTradeButtons(stock, theme),
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
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget buildVolButton() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 10,
      children: [
        _buildButton(
          'VOL',
          !_volHidden,
          () {
            _volHidden = !_volHidden;
            setState(() {});
          },
          theme,
        ),
      ],
    );
  }

  Widget buildMainButtons() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 10,
      children: MainState.values
          .map((e) => _buildButton(e.name, _mainState == e, () {
                _mainState = e;
                setState(() {});
              }, theme))
          .toList(),
    );
  }

  Widget buildSecondButtons() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 10,
      children: SecondaryState.values
          .map((e) => _buildButton(
              e.name, _secondaryStateLi.contains(e), () {
                if (_secondaryStateLi.contains(e)) {
                  _secondaryStateLi.remove(e);
                } else {
                  _secondaryStateLi.add(e);
                }
                setState(() {});
              }, theme))
          .toList(),
    );
  }

  Widget _buildButton(
    String title, bool isActive, Function onPress, ThemeData theme) {
  
    // Lấy brightness hiện tại
    bool isDark = theme.brightness == Brightness.dark;

    // Màu chữ
    Color txtColor = isActive
        ? theme.colorScheme.primary
        : (isDark
            ? Colors.white70
            : Colors.black54); 

    Color bgColor = isActive
        ? theme.colorScheme.primary.withOpacity(0.15)
        : Colors.transparent;

    Color borderColor = isDark ? Colors.white24 : Colors.black26;

    return InkWell(
      onTap: () => onPress(),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Text(
          title,
          style: TextStyle(color: txtColor),
        ),
      ),
    );
  }

  Widget _buildTradeButtons(StockModel stock, ThemeData theme) {
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
              onPressed: isUserReady
                  ? () => Future.microtask(() => _showTradeDialog(context, "BUY", stock))
                  : null,
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
              onPressed: isUserReady
              ? () => Future.microtask(() => _showTradeDialog(context, "SELL", stock))
              : null,
              child: const Text("Bán"),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm _showTradeDialog giữ nguyên như bạn đã viết
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
                type == "BUY" ? "Mua" : "Bán",
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
                            "Bạn đang sở hữu: $ownedQty coin",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      TextField(
                        controller: quantityCtrl,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        enabled: !isLoading,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                        decoration: InputDecoration(
                          hintText: "Số lượng",
                          hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                      Visibility(
                        visible: isLoading,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child:
                              const CircularProgressIndicator(color: Colors.greenAccent),
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
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          final qty = int.tryParse(quantityCtrl.text) ?? 0;
                          if (qty <= 0) {
                            Future.microtask(() => showErrorToast(context, "Vui lòng nhập số lượng hợp lệ"));
                            return;
                          }

                          if (type == "SELL" && qty > ownedQty) {
                            Future.microtask(() => showErrorToast(context, "Số lượng bán vượt quá số lượng sở hữu"));
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
                            Future.microtask(() => showSuccessToast(context, "$type ${stock.symbol} x $qty thành công"));

                            Navigator.pop(context);
                          } catch (e) {
                             Future.microtask(() => showErrorToast(context, "Lỗi: ${e.toString()}"));
                            
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
