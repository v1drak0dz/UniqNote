import 'package:uniqnote/models/attachment.dart';

abstract class StrategyInterface {
  Future<Attachment?> addAttachment();
}
