part of "notice_list.dart";

class NoticeDetail extends StatelessWidget {
  const NoticeDetail(this.notice, {super.key});

  @override
  Widget build(BuildContext context) {
    final double rowSpacing = 16.w;

    return Scaffold(
      backgroundColor: AppColors.designWhite,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.commonWhite,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: SvgPicture.asset(
            BEATAssets.svg.backArrow,
            width: 24.w,
            height: 24.w,
          ),
        ),
        shape: Border(
          bottom: BorderSide(width: 0.5, color: AppColors.disabledColorLight),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.w),
            NoticeTitle(notice.title, notice.createdAt),
            SizedBox(height: 16.w),
            NoticeImages(notice.fileList),
            if (notice.fileList.isNotEmpty)
              SizedBox(height: 16.w),
            NoticeBody(notice.body),
            SizedBox(height: 32.w),
          ],
        ),
      ),
    );
  }

  final NoticeModel notice;
}
