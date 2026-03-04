import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/use_cases/notes/insert_note_use_case.dart';

// Anotação para gerar mocks
@GenerateMocks([Database])
// Import do arquivo gerado (após rodar build_runner)
import 'insert_note_use_case_test.mocks.dart';

void main() {
  group('InsertNoteUseCase', () {
    late MockDatabase mockDb;
    late InsertNoteUseCase useCase;

    setUp(() {
      mockDb = MockDatabase();
      useCase = InsertNoteUseCase(db: mockDb);
    });

    test('should insert note and attachments', () async {
      final attachments = [
        Attachment(
          type: AttachmentType.image,
          filePath: '/path/img.png',
          name: 'img1',
        ),
      ];

      // any<Map<String, Object?>>() para null safety
      when(
        mockDb.insert('notes', argThat(isA<Map<String, Object?>>())),
      ).thenAnswer((_) async => 1);

      when(
        mockDb.insert('attachments', argThat(isA<Map<String, Object?>>())),
      ).thenAnswer((_) async => 1);

      final noteId = await useCase.insertNote('title', 'content', attachments);

      expect(noteId, 1);

      verify(
        mockDb.insert('notes', argThat(containsPair('title', 'title'))),
      ).called(1);
      verify(
        mockDb.insert('attachments', argThat(containsPair('note_id', 1))),
      ).called(1);
    });
  });
}
