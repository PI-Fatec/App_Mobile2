import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/expense.dart';
import '../models/category.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  double totalExpenses = 0.0;
  double monthlyExpenses = 0.0;
  Map<String, double> categoryTotals = {};
  List<Expense> recentExpenses = [];
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper.instance;

      // Carrega dados básicos
      final total = await dbHelper.getTotalExpenses();
      final monthly = await dbHelper.getTotalExpensesForMonth(DateTime.now());
      final categoryData = await dbHelper.getCategoryTotals();
      final recent = await dbHelper.getAllExpenses();
      final loadedCategories = await dbHelper.getAllCategories();

      setState(() {
        totalExpenses = total;
        monthlyExpenses = monthly;
        categoryTotals = categoryData;
        recentExpenses = recent.take(5).toList();
        categories = loadedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar estatísticas: $e')),
        );
      }
    }
  }

  String _getCategoryIcon(String categoryName) {
    final category = categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => Category(name: 'Outros', icon: '💼', color: '9E9E9E'),
    );
    return category.icon;
  }

  Color _getCategoryColor(String categoryName) {
    final category = categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => Category(name: 'Outros', icon: '💼', color: '9E9E9E'),
    );
    return Color(int.parse('FF${category.color}', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Cards de resumo
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Geral',
                          'R\$ ${totalExpenses.toStringAsFixed(2)}',
                          Icons.account_balance_wallet,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSummaryCard(
                          'Este Mês',
                          'R\$ ${monthlyExpenses.toStringAsFixed(2)}',
                          Icons.calendar_month,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Gastos por categoria
                  if (categoryTotals.isNotEmpty) ...[
                    _buildSectionTitle('Gastos por Categoria'),
                    Card(
                      child: Column(
                        children: categoryTotals.entries
                            .where((entry) => entry.value > 0)
                            .map(
                              (entry) => _buildCategoryItem(
                                entry.key,
                                entry.value,
                                totalExpenses > 0
                                    ? (entry.value / totalExpenses) * 100
                                    : 0,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Despesas recentes
                  if (recentExpenses.isNotEmpty) ...[
                    _buildSectionTitle('Despesas Recentes'),
                    Card(
                      child: Column(
                        children: recentExpenses
                            .map((expense) => _buildExpenseItem(expense))
                            .toList(),
                      ),
                    ),
                  ],

                  // Estatísticas adicionais
                  const SizedBox(height: 24),
                  _buildSectionTitle('Estatísticas Adicionais'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildStatItem(
                            'Média Diária (Este Mês)',
                            'R\$ ${_calculateDailyAverage().toStringAsFixed(2)}',
                            Icons.trending_up,
                          ),
                          const Divider(),
                          _buildStatItem(
                            'Total de Despesas',
                            '${recentExpenses.length} registros',
                            Icons.receipt_long,
                          ),
                          const Divider(),
                          _buildStatItem(
                            'Categoria Mais Usada',
                            _getMostUsedCategory(),
                            Icons.star,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCategoryItem(String category, double amount, double percentage) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getCategoryColor(category).withOpacity(0.1),
        child: Text(
          _getCategoryIcon(category),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      title: Text(category),
      subtitle: Text('${percentage.toStringAsFixed(1)}% do total'),
      trailing: Text(
        'R\$ ${amount.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.red.withOpacity(0.1),
        child: Text(
          _getCategoryIcon(expense.category),
          style: const TextStyle(fontSize: 16),
        ),
      ),
      title: Text(expense.title),
      subtitle: Text(DateFormat('dd/MM/yyyy').format(expense.date)),
      trailing: Text(
        'R\$ ${expense.amount.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateDailyAverage() {
    if (monthlyExpenses == 0) return 0;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return monthlyExpenses / daysInMonth;
  }

  String _getMostUsedCategory() {
    if (categoryTotals.isEmpty) return 'Nenhuma';

    final mostUsed = categoryTotals.entries.reduce(
      (current, next) => current.value > next.value ? current : next,
    );

    return mostUsed.key;
  }
}
