import 'package:uniqnote/models/attachment.dart';
import 'package:uniqnote/strategies/attachmentStrategy/file_strategy.dart';
import 'package:uniqnote/strategies/attachmentStrategy/image_strategy.dart';
import 'package:uniqnote/strategies/attachmentStrategy/video_strategy.dart';

class AttachmentContext {
  final AttachmentType attachmentType;

  AttachmentContext(this.attachmentType);

  Future<Attachment?> addAttachment() async {
    if (attachmentType == AttachmentType.image) {
      return await ImageStrategy().addAttachment();
    } else if (attachmentType == AttachmentType.video) {
      return await VideoStrategy().addAttachment();
    } else if (attachmentType == AttachmentType.file) {
      return await FileStrategy().addAttachment();
    } else {
      return null;
    }
  }
}
