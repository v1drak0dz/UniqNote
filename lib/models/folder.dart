class Folder {
  final int? id;
  final String name;
  final int color;

  Folder({this.id, required this.name, required this.color});

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(id: map['id'], name: map['name'], color: map['color']);
  }
}
