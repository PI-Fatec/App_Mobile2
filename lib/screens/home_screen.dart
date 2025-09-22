import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/expense.dart';
import '../models/category.dart';
import 'add_expense_screen.dart';
import 'expense_details_screen.dart';
import 'statistics_screen.dart';
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> expenses = [];
  List<Category> categories = [];
  double totalExpenses = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper.instance;
      final loadedExpenses = await dbHelper.getAllExpenses();
      final loadedCategories = await dbHelper.getAllCategories();
      final total = await dbHelper.getTotalExpenses();

      setState(() {
        expenses = loadedExpenses;
        categories = loadedCategories;
        totalExpenses = total;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
      }
    }
  }

  Future<void> _deleteExpense(int id) async {
    try {
      await DatabaseHelper.instance.deleteExpense(id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Despesa excluída com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao excluir despesa: $e')));
      }
    }
  }

  void _showDeleteDialog(Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Despesa'),
          content: Text('Deseja realmente excluir "${expense.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteExpense(expense.id!);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  String _getCategoryIcon(String categoryName) {
    final category = categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => Category(name: 'Outros', icon: '💼', color: '9E9E9E'),
    );
    return category.icon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador de Despesas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoriesScreen(),
                ),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Card com total de gastos
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Total de Gastos',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'R\$ ${totalExpenses.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lista de despesas
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : expenses.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma despesa registrada',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Toque no botão + para adicionar sua primeira despesa',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.withOpacity(0.1),
                              child: Text(
                                _getCategoryIcon(expense.category),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            title: Text(
                              expense.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(expense.category),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(expense.date),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              'R\$ ${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ExpenseDetailsScreen(expense: expense),
                                ),
                              ).then((_) => _loadData());
                            },
                            onLongPress: () => _showDeleteDialog(expense),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          ).then((_) => _loadData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
