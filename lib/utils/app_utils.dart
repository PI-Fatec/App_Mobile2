import 'package:intl/intl.dart';

class AppUtils {
  // Formatadores de data
  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat monthYearFormat = DateFormat('MM/yyyy');

  // Formatador de moeda
  static final NumberFormat currencyFormat = NumberFormat.currency(
    symbol: 'R\$',
    decimalDigits: 2,
  );

  // Formatar valor monetário
  static String formatCurrency(double value) {
    return currencyFormat.format(value);
  }

  // Formatar data
  static String formatDate(DateTime date) {
    return dateFormat.format(date);
  }

  // Formatar data e hora
  static String formatDateTime(DateTime dateTime) {
    return dateTimeFormat.format(dateTime);
  }

  // Obter primeiro dia do mês
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Obter último dia do mês
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  // Validar valor monetário
  static bool isValidAmount(String value) {
    if (value.isEmpty) return false;
    final amount = double.tryParse(value.replaceAll(',', '.'));
    return amount != null && amount > 0;
  }

  // Converter string para double (considerando vírgula como decimal)
  static double? parseAmount(String value) {
    if (value.isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }

  // Obter cor a partir do código hex
  static int getColorFromHex(String hexColor) {
    return int.parse('FF$hexColor', radix: 16);
  }

  // Truncar texto com reticências
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Calcular percentual
  static double calculatePercentage(double part, double total) {
    if (total == 0) return 0;
    return (part / total) * 100;
  }
}

// Constantes do aplicativo
class AppConstants {
  // Strings
  static const String appName = 'Gerenciador de Despesas';
  static const String databaseName = 'expense_manager.db';

  // Limites
  static const int maxTitleLength = 50;
  static const int maxDescriptionLength = 200;
  static const double maxAmount = 999999.99;
  static const double minAmount = 0.01;

  // Configurações padrão
  static const int recentExpensesLimit = 5;
  static const int databaseVersion = 1;

  // Mensagens
  static const String noExpensesMessage = 'Nenhuma despesa registrada';
  static const String noCategoriesMessage = 'Nenhuma categoria encontrada';
  static const String loadingMessage = 'Carregando...';
  static const String errorLoadingData = 'Erro ao carregar dados';
  static const String successSave = 'Salvo com sucesso!';
  static const String successDelete = 'Excluído com sucesso!';
  static const String confirmDelete = 'Deseja realmente excluir?';
}

// Enums para facilitar o uso
enum ExpenseFilter { all, thisMonth, lastMonth, thisYear, category }

enum SortType { dateDesc, dateAsc, amountDesc, amountAsc, titleAsc, titleDesc }