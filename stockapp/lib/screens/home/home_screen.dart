import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/stock_card.dart';
import '../stock/StockDetailPage.dart';
import 'package:stockapp/models/stock_model.dart';
import 'package:stockapp/providers/stock_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe stocks realtime khi Home load
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    stockProvider.listenStocks();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.green[300],
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Header (Balance + Portfolio value)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Số dư ví 💰", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("100,000 VND", style: TextStyle(fontSize: 16)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tài sản 📊", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("250,000 VND", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.trending_up),
                    label: const Text("Top Movers"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[300],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text("AI Gợi ý"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[300],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 Stock List realtime
          Expanded(
            child: Consumer<StockProvider>(
              builder: (context, stockProvider, _) {
                final stocks = stockProvider.stocks;

                if (stocks.isEmpty) {
                  return const Center(child: Text("Chưa có dữ liệu cổ phiếu"));
                }

                return ListView.builder(
                  itemCount: stocks.length,
                  itemBuilder: (context, index) {
                    final stock = stocks[index];
                    return StockCard(
                      symbol: stock.symbol,
                      price: stock.price,
                      change: stock.changePercent,
                      volume: stock.volume,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StockDetailPage(stockId: stock.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
