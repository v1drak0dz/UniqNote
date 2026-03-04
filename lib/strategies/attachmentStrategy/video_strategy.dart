import 'package:image_picker/image_picker.dart';
import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/strategies/attachmentStrategy/strategy_interface.dart';

class VideoStrategy implements StrategyInterface {
  final ImagePicker imagePicker = ImagePicker();

  @override
  Future<Attachment?> addAttachment() async {
    final picked = await imagePicker.pickVideo(source: ImageSource.gallery);

    if (picked == null) return null;

    return Attachment(
      type: AttachmentType.video,
      filePath: picked.path,
      name: picked.name,
    );
  }
}
