import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockapp/providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _typeFilter = "Tất cả";
  String _searchText = "";
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.uid;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userId != null) {
        context.read<TransactionProvider>().listenTransactions(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 👈 lấy theme hiện tại
    final provider = context.watch<TransactionProvider>();
    final vndFormat =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'VND', decimalDigits: 0);

    if (provider.loading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background, // 👈 dùng theme
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    var transactions = provider.transactions;

    // Lọc
    if (_typeFilter != "Tất cả") {
      transactions =
          transactions.where((tx) => tx.type == _typeFilter).toList();
    }
    if (_searchText.isNotEmpty) {
      transactions = transactions
          .where((tx) =>
              (tx.stockId ?? "")
                  .toLowerCase()
                  .contains(_searchText.toLowerCase()))
          .toList();
    }
    if (_startDate != null && _endDate != null) {
      transactions = transactions
          .where((tx) =>
              tx.createdAt.isAfter(_startDate!) &&
              tx.createdAt.isBefore(_endDate!.add(const Duration(days: 1))))
          .toList();
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // 👈 đổi theo theme
      appBar: AppBar(
        title: Text(
          "History transaction",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onBackground,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor ??
            theme.colorScheme.surface, // 👈 theo theme
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: "Tìm theo mã coin...",
                          hintStyle: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          prefixIcon: Icon(Icons.search,
                              color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (val) {
                          setState(() => _searchText = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      dropdownColor: theme.colorScheme.surfaceVariant,
                      value: _typeFilter,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: "Tất cả", child: Text("Tất cả")),
                        DropdownMenuItem(value: "BUY", child: Text("Mua")),
                        DropdownMenuItem(value: "SELL", child: Text("Bán")),
                        DropdownMenuItem(
                            value: "DEPOSIT", child: Text("Nạp tiền")),
                        DropdownMenuItem(
                            value: "WITHDRAW", child: Text("Rút tiền")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _typeFilter = val);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _startDate = picked);
                          }
                        },
                        icon: Icon(Icons.date_range,
                            color: theme.colorScheme.onSurface),
                        label: Text(
                          _startDate != null
                              ? DateFormat('dd/MM/yyyy').format(_startDate!)
                              : "Từ ngày",
                          style:
                              TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _endDate = picked);
                          }
                        },
                        icon: Icon(Icons.date_range,
                            color: theme.colorScheme.onSurface),
                        label: Text(
                          _endDate != null
                              ? DateFormat('dd/MM/yyyy').format(_endDate!)
                              : "Đến ngày",
                          style:
                              TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Danh sách giao dịch
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Text(
                      "Không tìm thấy giao dịch phù hợp",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];

                      IconData icon;
                      Color color;
                      String title;
                      String subtitle;

                      switch (tx.type) {
                        case "BUY":
                          icon = Icons.arrow_upward;
                          color = Colors.greenAccent;
                          title = "Mua coin - ${tx.stockId}";
                          subtitle =
                              "SL: ${tx.quantity} | Ngày: ${DateFormat('dd/MM/yyyy').format(tx.createdAt)}";
                          break;
                        case "SELL":
                          icon = Icons.arrow_downward;
                          color = Colors.redAccent;
                          title = "Bán coin - ${tx.stockId}";
                          subtitle =
                              "SL: ${tx.quantity} | Ngày: ${DateFormat('dd/MM/yyyy').format(tx.createdAt)}";
                          break;
                        case "DEPOSIT":
                          icon = Icons.account_balance_wallet;
                          color = Colors.greenAccent;
                          title = "Nạp tiền vào ví";
                          subtitle =
                              "Ngày: ${DateFormat('dd/MM/yyyy').format(tx.createdAt)}";
                          break;
                        case "WITHDRAW":
                          icon = Icons.remove_circle;
                          color = Colors.redAccent;
                          title = "Rút tiền từ ví";
                          subtitle =
                              "Ngày: ${DateFormat('dd/MM/yyyy').format(tx.createdAt)}";
                          break;
                        default:
                          icon = Icons.help_outline;
                          color = theme.colorScheme.primary;
                          title = tx.type;
                          subtitle =
                              "Ngày: ${DateFormat('dd/MM/yyyy').format(tx.createdAt)}";
                      }

                      return Card(
                        color: theme.colorScheme.surfaceVariant,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: theme.dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(icon, color: color),
                          title: Text(
                            title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: color),
                          ),
                          subtitle: Text(
                            subtitle,
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7)),
                          ),
                          trailing: Text(
                            vndFormat.format(tx.price),
                            style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
