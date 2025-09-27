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
  final vndFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  String selectedType = "ALL"; // ALL | DEPOSIT | WITHDRAW
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);

      if (authProvider.user != null) {
        transactionProvider.listenTransactions(authProvider.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    transactionProvider.cancelListen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    transactionProvider = Provider.of<TransactionProvider>(context);
    final AppUser? user = authProvider.user;

    final theme = Theme.of(context); // ✅ lấy theme hiện tại
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Wallet"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Số dư hiện tại
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Số dư hiện tại 💰",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user != null ? vndFormat.format(user.balance) : "Đang tải...",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nút nạp / rút
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
                      backgroundColor: Colors.greenAccent[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                      backgroundColor: Colors.redAccent[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Filter row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    dropdownColor: theme.cardColor,
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(value: "ALL", child: Text("Tất cả")),
                      DropdownMenuItem(value: "DEPOSIT", child: Text("Nạp tiền")),
                      DropdownMenuItem(value: "WITHDRAW", child: Text("Rút tiền")),
                    ],
                    onChanged: (value) {
                      setState(() => selectedType = value ?? "ALL");
                    },
                    decoration: const InputDecoration(
                      labelText: "Loại",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.date_range, color: Colors.greenAccent),
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: startDate != null && endDate != null
                          ? DateTimeRange(start: startDate!, end: endDate!)
                          : null,
                    );
                    if (picked != null) {
                      setState(() {
                        startDate = picked.start;
                        endDate = picked.end;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Lịch sử giao dịch
            Expanded(
              child: user == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<List<TransactionModel>>(
                      stream: transactionProvider.transactionsStream(user.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        List<TransactionModel> transactions = snapshot.data
                                ?.where((tx) =>
                                    tx.type == "DEPOSIT" ||
                                    tx.type == "WITHDRAW")
                                .toList() ??
                            [];

                        // filter
                        if (selectedType != "ALL") {
                          transactions = transactions
                              .where((tx) => tx.type == selectedType)
                              .toList();
                        }
                        if (startDate != null && endDate != null) {
                          transactions = transactions.where((tx) {
                            final d = tx.createdAt;
                            return d.isAfter(
                                    startDate!.subtract(const Duration(days: 1))) &&
                                d.isBefore(endDate!.add(const Duration(days: 1)));
                          }).toList();
                        }

                        if (transactions.isEmpty) {
                          return Center(
                            child: Text("Không có giao dịch phù hợp",
                                style: theme.textTheme.bodyMedium),
                          );
                        }

                        return ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
                            return Card(
                              color: theme.cardColor,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: theme.dividerColor),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  tx.type == "DEPOSIT"
                                      ? Icons.add_circle
                                      : Icons.remove_circle,
                                  color: tx.type == "DEPOSIT"
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                ),
                                title: Text(
                                  "${tx.type == "DEPOSIT" ? "Nạp tiền" : "Rút tiền"}: ${vndFormat.format(tx.total)}",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "${tx.createdAt.toLocal().toString().split(".")[0]}",
                                  style: theme.textTheme.bodySmall,
                                ),
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
        backgroundColor: Colors.grey[900],
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Nhập số tiền",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }
}
