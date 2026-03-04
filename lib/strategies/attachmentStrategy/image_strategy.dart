import 'package:image_picker/image_picker.dart';
import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/strategies/attachmentStrategy/strategy_interface.dart';

class ImageStrategy implements StrategyInterface {
  final ImagePicker imagePicker = ImagePicker();

  @override
  Future<Attachment?> addAttachment() async {
    final picked = await imagePicker.pickImage(source: ImageSource.gallery);

    if (picked == null) return null;

    return Attachment(
      type: AttachmentType.image,
      filePath: picked.path,
      name: picked.name,
    );
  }
}
