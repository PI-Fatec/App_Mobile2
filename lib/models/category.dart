class Category {
  final int? id;
  final String name;
  final String icon;
  final String color;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'icon': icon, 'color': color};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color'] ?? '',
    );
  }

  Category copyWith({int? id, String? name, String? icon, String? color}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon, color: $color)';
  }
}

// Categorias padrão
final List<Category> defaultCategories = [
  Category(name: 'Alimentação', icon: '🍕', color: 'FF5722'),
  Category(name: 'Transporte', icon: '🚗', color: '2196F3'),
  Category(name: 'Saúde', icon: '🏥', color: 'F44336'),
  Category(name: 'Educação', icon: '📚', color: '4CAF50'),
  Category(name: 'Lazer', icon: '🎮', color: 'FF9800'),
  Category(name: 'Compras', icon: '🛒', color: 'E91E63'),
  Category(name: 'Casa', icon: '🏠', color: '795548'),
  Category(name: 'Outros', icon: '💼', color: '9E9E9E'),
];