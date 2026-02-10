import 'package:beat/entities/quest/quest_model.dart';
import 'package:beat/features/quest/index.dart';
import 'package:beat/widgets/quest/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_notifier.dart';

class QuestList extends StatelessWidget {
  QuestList({super.key});

  final QuestListController questListController = QuestListController.to;

  @override
  Widget build(BuildContext context) {
    return questListController.obx(
      (state) {
        return ListView.separated(
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: QuestItem(state[index], index: index),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: 10.w);
          },
          itemCount: state.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
      },
      onEmpty: ListView.separated(
        itemBuilder: (context, index) {
          final List<QuestModel> dummyQuests = List.generate(
            10,
            (index) => QuestModel.dummy(),
          );
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: QuestItem(dummyQuests[index], index: index),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 10.w);
        },
        itemCount: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      onLoading: ListView.separated(
        itemBuilder: (context, index) {
          final List<QuestModel> dummyQuests = List.generate(
            10,
            (index) => QuestModel.dummy(),
          );
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: QuestItem(dummyQuests[index], index: index),
          );
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 10.w);
        },
        itemCount: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      // TODO: onError는 더미 데이터이면 안됨
      onError: (state) {
        return ListView.separated(
          itemBuilder: (context, index) {
            final List<QuestModel> dummyQuests = List.generate(
              10,
              (index) => QuestModel.dummy(),
            );
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: QuestItem(dummyQuests[index], index: index),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: 10.w);
          },
          itemCount: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
      },
    );
  }
}
