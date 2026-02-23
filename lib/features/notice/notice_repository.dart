import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:beat/entities/notice/index.dart';
import 'package:beat/shared/services/index.dart';

class NoticeRepository {
  Future<List<NoticeModel>> fetchNoticeList(String authorization) async {
    try {
      final response = await _apiService.get(
        endpoint:
        DotEnvService.instance.fetchNoticeList,
        header: {"Content-Type": "application/json", "authorization": authorization},
      );

      log("NoticeRepository : fetchNoticeList() : ${response.body}");

      switch (response.statusCode) {
        case 200:
          final String decoded = utf8.decode(response.bodyBytes);
          List<NoticeModel> noticeList = [];

          for (var item in jsonDecode(decoded)) {
            noticeList.add(NoticeModel.fromJson(item));
          }

          return noticeList;

        case 400:
          throw BEATException(title: LocalizationService.instance.errorUnknown);
        case 401:
          throw BEATTokenExpired();
        default:
          throw BEATException(title: LocalizationService.instance.errorUnknown);
      }
    } on TimeoutException {
      throw BEATException(
        title: LocalizationService.instance.errorTimeout,
        message: LocalizationService.instance.errorConnectivity,
      );
    } catch (e) {
      log("NoticeRepository : fetchNoticeList() : ${e.toString()}");
      rethrow;
    }
  }

  final APIService _apiService = APIService();
}
