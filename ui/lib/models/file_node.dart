export '../features/files/models/file_node.dart';
export '../features/files/models/open_file_tab.dart';
import '../features/files/models/file_node.dart';

typedef GitFileStatus = GitStatus;

extension GitStatusCompat on GitStatus {
  static const GitStatus unmodified = GitStatus.none;
  static const GitStatus added = GitStatus.newFile;
  static const GitStatus deleted = GitStatus.none;
}
