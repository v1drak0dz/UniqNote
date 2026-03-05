class Folder {
  final int? id;
  final String name;
  final int color;
  final int isProtected;

  Folder({
    this.id,
    required this.name,
    required this.color,
    this.isProtected = 0,
  });

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      isProtected: map['is_protected'],
    );
  }
}
