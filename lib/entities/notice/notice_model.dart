class NoticeModel {
  NoticeModel({
    required this.noticeId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.fileList,
  });

  NoticeModel.fromJson(Map<String, dynamic> json)
      : noticeId = json['noticeId'],
        title = json['title'],
        body = json['body'],
        createdAt = DateTime.parse(json['createdAt']),
        fileList = (json['fileList'] as List)
            .map((e) => NoticeFile.fromJson(e))
            .toList();

  NoticeModel.empty()
      : noticeId = 0,
        title = "",
        body = "",
        createdAt = DateTime.now(),
        fileList = [];

  final int noticeId;
  final String title;
  final String body;
  final DateTime createdAt;
  final List<NoticeFile> fileList;
}

class NoticeFile {
  NoticeFile({
    required this.fileId,
    required this.fileName,
    required this.publicUrl,
  });

  NoticeFile.fromJson(Map<String, dynamic> json)
      : fileId = json['fileId'],
        fileName = json['fileName'],
        publicUrl = json['publicUrl'];

  final int fileId;
  final String fileName;
  final String publicUrl;
}