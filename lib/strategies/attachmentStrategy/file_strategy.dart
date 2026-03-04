import 'package:file_picker/file_picker.dart';
import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/strategies/attachmentStrategy/strategy_interface.dart';

class FileStrategy implements StrategyInterface {
  @override
  Future<Attachment?> addAttachment() async {
    final picked = await FilePicker.platform.pickFiles();

    if (picked == null) return null;

    if (picked.files.isEmpty) return null;

    return Attachment(
      type: AttachmentType.image,
      filePath: picked.files.first.path!,
      name: picked.files.first.name,
    );
  }
}
