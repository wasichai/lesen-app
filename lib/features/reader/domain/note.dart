/// Una oración guardada en las notas, con la cita tomada del texto publicado.
class Note {
  const Note({required this.id, required this.version, required this.sentenceRef, required this.quote, required this.note, required this.createdAt});

  final String id;
  final int version;
  final String sentenceRef;
  final String quote;
  final String? note;
  final DateTime? createdAt;
}
