class Tag {
  final String name;
  final String colorHex; // HEX-цвет, например #FF6B6B

  Tag({
    required this.name,
    this.colorHex = '#2196F3', // по умолчанию синий
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'colorHex': colorHex,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      name: map['name'],
      colorHex: map['colorHex'] ?? '#2196F3',
    );
  }
}
