import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockapp/providers/auth_provider.dart';
import '../../providers/portfolio_provider.dart';
import 'package:intl/intl.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.uid;

    context.read<PortfolioProvider>().listenPortfolio(userId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final vndFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');

    if (provider.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final portfolio = provider.portfolio;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Portfolio"),
        backgroundColor: Colors.green[300],
      ),
      body: (portfolio == null || portfolio.stocks.isEmpty)
          ? const Center(child: Text("Chưa có cổ phiếu trong danh mục"))
          : ListView.builder(
              itemCount: portfolio.stocks.length,
              itemBuilder: (context, index) {
                final item = portfolio.stocks[index];

                // Nếu bạn muốn lấy giá realtime từ danh sách stocks có sẵn:
                final stockPrice = item.avgPrice; // hoặc từ stockList nếu có

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[200],
                      child: Text(item.stockId[0]),
                    ),
                    title: Text(item.stockId,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Số lượng: ${item.quantity}"),
                    trailing: Text(
                      "Avg: ${vndFormat.format(stockPrice)}",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
