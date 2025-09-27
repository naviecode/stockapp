import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockapp/models/user_model.dart';
import 'package:stockapp/providers/auth_provider.dart';
import 'package:stockapp/providers/portfolio_provider.dart';
import '../../widgets/stock_card.dart';
import '../stock/StockDetailPage.dart';
import 'package:stockapp/models/stock_model.dart';
import 'package:stockapp/providers/stock_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    final portfolioProvider = Provider.of<PortfolioProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final vndFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');

    // Số dư ví
    final balance = auth.user?.balance ?? 0;

    // Tổng giá trị portfolio realtime
    final totalPortfolio =
        portfolioProvider.calculateTotalValueRealtime(stockProvider.stocks);

    // Tổng tài sản = balance + giá trị cổ phiếu realtime
    final totalAssets = balance + totalPortfolio;

    stockProvider.listenStocks();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.green[300],
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  String keyword = '';
                  return AlertDialog(
                    title: const Text("Tìm cổ phiếu"),
                    content: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: "Nhập tên hoặc ký hiệu cổ phiếu",
                      ),
                      onChanged: (value) {
                        keyword = value;
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Hủy"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Gọi logic filter
                          Provider.of<StockProvider>(context, listen: false)
                              .searchStock(keyword);
                          Navigator.pop(context);
                        },
                        child: const Text("Tìm"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.search),
          ),
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
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Số dư ví 💰",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      auth.user != null
                          ? vndFormat.format(auth.user!.balance)
                          : "Đang tải",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tài sản 📊",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(vndFormat.format(totalAssets),
                        style: const TextStyle(fontSize: 16)),
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
                // Dropdown filter thay cho nút Top Movers
                Expanded(
                  child: Consumer<StockProvider>(
                    builder: (context, stockProvider, _) {
                      return DropdownButtonFormField<StockListFilter>(
                        value: stockProvider.currentFilter,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.green[300],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                        dropdownColor: Colors.green[100],
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        items: const [
                          DropdownMenuItem(
                            value: StockListFilter.all,
                            child: Text("All"),
                          ),
                          DropdownMenuItem(
                            value: StockListFilter.topGainers,
                            child: Text("Top Gainers"),
                          ),
                          DropdownMenuItem(
                            value: StockListFilter.topLosers,
                            child: Text("Top Losers"),
                          ),
                          DropdownMenuItem(
                            value: StockListFilter.topVolume,
                            child: Text("Top Volume"),
                          ),
                        ],
                        onChanged: (filter) {
                          if (filter != null) {
                            stockProvider.setFilter(filter);
                          }
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                // Giữ nguyên nút AI Gợi ý
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

          // Consumer<StockProvider>(
          //   builder: (context, stockProvider, _) {
          //     final topGainers = stockProvider.getTopGainers();
          //     final topLosers = stockProvider.getTopLosers();

          //     return Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         const Padding(
          //           padding: EdgeInsets.symmetric(horizontal: 12),
          //           child: Text("Top Gainers",
          //               style: TextStyle(fontWeight: FontWeight.bold)),
          //         ),
          //         SizedBox(
          //           height: 140,
          //           child: ListView.builder(
          //             scrollDirection: Axis.horizontal,
          //             itemCount: topGainers.length,
          //             padding: const EdgeInsets.symmetric(horizontal: 12),
          //             itemBuilder: (context, index) {
          //               final stock = topGainers[index];
          //               return StockCard(
          //                 width: 120, // ✅ chiều ngang cố định
          //                 symbol: stock.symbol,
          //                 price: stock.price,
          //                 change: stock.changePercent,
          //                 volume: stock.volume,
          //                 onTap: () {
          //                   Navigator.push(
          //                     context,
          //                     MaterialPageRoute(
          //                       builder: (_) => StockDetailPage(stockId: stock.id),
          //                     ),
          //                   );
          //                 },
          //               );
          //             },
          //           ),
          //         ),
          //         const SizedBox(height: 10),
          //         const Padding(
          //           padding: EdgeInsets.symmetric(horizontal: 12),
          //           child: Text("Top Losers",
          //               style: TextStyle(fontWeight: FontWeight.bold)),
          //         ),
          //          SizedBox(
          //           height: 140,
          //           child: ListView.builder(
          //             scrollDirection: Axis.horizontal,
          //             itemCount: topLosers.length,
          //             padding: const EdgeInsets.symmetric(horizontal: 12),
          //             itemBuilder: (context, index) {
          //               final stock = topLosers[index];
          //               return StockCard(
          //                 width: 120, // ✅ chiều ngang cố định
          //                 symbol: stock.symbol,
          //                 price: stock.price,
          //                 change: stock.changePercent,
          //                 volume: stock.volume,
          //                 onTap: () {
          //                   Navigator.push(
          //                     context,
          //                     MaterialPageRoute(
          //                       builder: (_) => StockDetailPage(stockId: stock.id),
          //                     ),
          //                   );
          //                 },
          //               );
          //             },
          //           ),
          //         ),
          //       ],
          //     );
          //   },
          // ),

          // const SizedBox(height: 10),

          // 🔹 Stock List realtime
          Expanded(
            child: Consumer<StockProvider>(
              builder: (context, stockProvider, _) {
                final stocks = stockProvider.filteredStockList;

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
                            builder: (_) =>
                                StockDetailPage(stockId: stock.id),
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
