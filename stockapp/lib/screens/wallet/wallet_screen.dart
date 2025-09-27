import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockapp/models/transaction_model.dart';
import 'package:stockapp/models/user_model.dart';
import 'package:stockapp/providers/auth_provider.dart';
import 'package:stockapp/providers/transaction_provider.dart';
import 'package:intl/intl.dart';


class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late AuthProvider authProvider;
  late TransactionProvider transactionProvider;
  final vndFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');


  @override
  void initState() {
    super.initState();

    // Delay để chắc chắn context đã sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      transactionProvider = Provider.of<TransactionProvider>(context, listen: false);

      if (authProvider.user != null) {
        transactionProvider.listenTransactions(authProvider.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    transactionProvider.cancelListen(); // Hủy listener khi rời page
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    transactionProvider = Provider.of<TransactionProvider>(context);
    final AppUser? user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
        backgroundColor: Colors.green[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Số dư hiện tại
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Số dư hiện tại 💰",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user != null
                        ? vndFormat.format(user.balance)
                        : "Đang tải...",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Nạp/Rút tiền
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final amount = await _showAmountDialog(context, "Nạp tiền");
                      if (amount != null && user != null) {
                        await transactionProvider.deposit(user.uid, amount);
                        await authProvider.refreshUser();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Nạp tiền"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[300],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final amount = await _showAmountDialog(context, "Rút tiền");
                      if (amount != null && user != null) {
                        try {
                          await transactionProvider.withdraw(user.uid, amount);
                          await authProvider.refreshUser();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.remove),
                    label: const Text("Rút tiền"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[300],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Lịch sử giao dịch dùng StreamBuilder
            Expanded(
              child: user == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<List<TransactionModel>>(
                      stream: transactionProvider.transactionsStream(user.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final transactions = snapshot.data
                                ?.where((tx) => tx.type == "DEPOSIT" || tx.type == "WITHDRAW")
                                .toList() ??
                            [];

                        if (transactions.isEmpty) {
                          return const Center(child: Text("Chưa có giao dịch"));
                        }

                        return ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: Icon(
                                  tx.type == "DEPOSIT"
                                      ? Icons.add_circle
                                      : Icons.remove_circle,
                                  color: tx.type == "DEPOSIT"
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: Text(
                                    "${tx.type == "DEPOSIT" ? "Nạp tiền" : "Rút tiền"}: ${vndFormat.format(tx.total)}"),
                                subtitle: Text(
                                    "${tx.createdAt.toLocal().toString().split(".")[0]}"),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog nhập số tiền
  Future<double?> _showAmountDialog(BuildContext context, String title) async {
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Nhập số tiền",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(context, value);
            },
             style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16), 
            ),
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }
}
