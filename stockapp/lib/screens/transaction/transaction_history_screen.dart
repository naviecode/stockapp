import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockapp/providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.uid;

    // Đảm bảo gọi listenTransactions sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userId != null) {
        context.read<TransactionProvider>().listenTransactions(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final vndFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND', decimalDigits: 0);

    if (provider.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final transactions = provider.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử giao dịch"),
        backgroundColor: Colors.green[300],
      ),
      body: transactions.isEmpty
          ? const Center(child: Text("Chưa có giao dịch"))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];

                // Xác định kiểu giao dịch để hiển thị icon + màu
                IconData icon;
                Color color;
                String title;
                String subtitle;

                switch (tx.type) {
                  case "BUY":
                    icon = Icons.arrow_upward;
                    color = Colors.green;
                    title = "Mua cổ phiếu - ${tx.stockId}";
                    subtitle = "SL: ${tx.quantity} | Ngày: ${tx.createdAt.toLocal().toString().split(' ')[0]}";
                    break;
                  case "SELL":
                    icon = Icons.arrow_downward;
                    color = Colors.red;
                    title = "Bán cổ phiếu - ${tx.stockId}";
                    subtitle = "SL: ${tx.quantity} | Ngày: ${tx.createdAt.toLocal().toString().split(' ')[0]}";
                    break;
                  case "DEPOSIT":
                    icon = Icons.account_balance_wallet;
                    color = Colors.green;
                    title = "Nạp tiền vào ví";
                    subtitle = "Ngày: ${tx.createdAt.toLocal().toString().split(' ')[0]}";
                    break;
                  case "WITHDRAW":
                    icon = Icons.remove_circle;
                    color = Colors.red;
                    title = "Rút tiền từ ví";
                    subtitle = "Ngày: ${tx.createdAt.toLocal().toString().split(' ')[0]}";
                    break;
                  default:
                    icon = Icons.help_outline;
                    color = Colors.grey;
                    title = tx.type;
                    subtitle = "Ngày: ${tx.createdAt.toLocal().toString().split(' ')[0]}";
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(icon, color: color),
                    title: Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, color: color),
                    ),
                    subtitle: Text(subtitle),
                    trailing: Text(
                      "${vndFormat.format(tx.price)}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
