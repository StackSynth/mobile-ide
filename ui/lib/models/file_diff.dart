enum DiffLineType {
  added,
  deleted,
  unchanged;
}

class DiffLine {
  final DiffLineType type;
  final String text;
  final int? oldLineNumber;
  final int? newLineNumber;

  const DiffLine({
    required this.type,
    required this.text,
    this.oldLineNumber,
    this.newLineNumber,
  });
}

enum DiffStatus {
  pending,
  accepted,
  rejected;
}

class FileDiff {
  final String id;
  final String filePath;
  final String fileTitle;
  final String summary;
  final int additions;
  final int deletions;
  final List<DiffLine> lines;
  final DiffStatus status;

  const FileDiff({
    required this.id,
    required this.filePath,
    required this.fileTitle,
    required this.summary,
    required this.additions,
    required this.deletions,
    required this.lines,
    this.status = DiffStatus.pending,
  });

  FileDiff copyWith({
    String? id,
    String? filePath,
    String? fileTitle,
    String? summary,
    int? additions,
    int? deletions,
    List<DiffLine>? lines,
    DiffStatus? status,
  }) {
    return FileDiff(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileTitle: fileTitle ?? this.fileTitle,
      summary: summary ?? this.summary,
      additions: additions ?? this.additions,
      deletions: deletions ?? this.deletions,
      lines: lines ?? this.lines,
      status: status ?? this.status,
    );
  }
}
