import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  final List<Map<String, dynamic>> transactions = const [
    {"type": "BUY", "symbol": "VNM", "quantity": 20, "price": 74000.0, "date": "2025-09-15"},
    {"type": "SELL", "symbol": "FPT", "quantity": 10, "price": 92000.0, "date": "2025-09-17"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction History"),
        backgroundColor: Colors.green[300],
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          final isBuy = tx["type"] == "BUY";
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(
                isBuy ? Icons.arrow_upward : Icons.arrow_downward,
                color: isBuy ? Colors.green : Colors.red,
              ),
              title: Text("${tx["type"]} - ${tx["symbol"]}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isBuy ? Colors.green : Colors.red,
                  )),
              subtitle: Text("SL: ${tx["quantity"]} | Ngày: ${tx["date"]}"),
              trailing: Text(
                "${tx["price"].toStringAsFixed(0)} VND",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          );
        },
      ),
    );
  }
}
