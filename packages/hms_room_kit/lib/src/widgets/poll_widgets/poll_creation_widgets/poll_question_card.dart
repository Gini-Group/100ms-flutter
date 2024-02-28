///Package imports
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hms_room_kit/src/meeting/meeting_store.dart';
import 'package:hms_room_kit/src/widgets/bottom_sheets/poll_vote_bottom_sheet.dart';
import 'package:hms_room_kit/src/widgets/poll_widgets/poll_creation_widgets/poll_question_bottom_sheet.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:provider/provider.dart';

///Project imports
import 'package:hms_room_kit/hms_room_kit.dart';
import 'package:hms_room_kit/src/model/poll_store.dart';
import 'package:hms_room_kit/src/widgets/common_widgets/hms_button.dart';
import 'package:hms_room_kit/src/widgets/common_widgets/live_badge.dart';

///[PollQuestionCard] widget renders the cards for poll which are either started, ended, created or are in draft
class PollQuestionCard extends StatelessWidget {
  const PollQuestionCard({super.key});

  String? getBadgeText(HMSPollState state) {
    switch (state) {
      case HMSPollState.started:
        return null;
      case HMSPollState.stopped:
        return "ENDED";
      case HMSPollState.created:
        return "DRAFT";
    }
  }

  Color? getBadgeColor(HMSPollState state) {
    switch (state) {
      case HMSPollState.started:
        return null;
      default:
        return HMSThemeColors.surfaceBrighter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        decoration: BoxDecoration(
          color: HMSThemeColors.surfaceDefault,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Selector<HMSPollStore, String>(
                        selector: (_, hmsPollStore) => hmsPollStore.poll.title,
                        builder: (_, title, __) {
                          return HMSTitleText(
                            text: title,
                            textColor: HMSThemeColors.onSurfaceHighEmphasis,
                            letterSpacing: 0.15,
                            maxLines: 3,
                          );
                        }),
                  ),
                  Selector<HMSPollStore, HMSPollState>(
                      selector: (_, hmsPollStore) => hmsPollStore.poll.state,
                      builder: (_, pollState, __) {
                        return LiveBadge(
                            text: getBadgeText(pollState),
                            badgeColor: getBadgeColor(pollState),
                            width: 50);
                      })
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  HMSButton(
                      width: MediaQuery.of(context).size.width * 0.23,
                      onPressed: () {
                        var meetingStore = context.read<MeetingStore>();
                        var pollStore = context.read<HMSPollStore>();

                        if (pollStore.poll.state == HMSPollState.created) {
                          showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: HMSThemeColors.surfaceDim,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16)),
                              ),
                              context: context,
                              builder: (ctx) => ChangeNotifierProvider.value(
                                    value: meetingStore,
                                    child: ChangeNotifierProvider.value(
                                      value: pollStore,
                                      child: PollQuestionBottomSheet(
                                        isPoll: pollStore.poll.category ==
                                            HMSPollCategory.poll,
                                        pollName: pollStore.poll.title,
                                      ),
                                    ),
                                  ));
                          return;
                        }

                        if (pollStore.poll.questions?.isEmpty ?? true) {
                          if (Platform.isAndroid) {
                            meetingStore.fetchPollQuestions(pollStore.poll);
                            meetingStore.getPollResults(pollStore.poll);
                          } else {
                            meetingStore.getPollResults(pollStore.poll);
                            meetingStore.fetchPollQuestions(pollStore.poll);
                          }
                        }
                        if (pollStore.poll.category == HMSPollCategory.quiz &&
                            pollStore.pollLeaderboardResponse == null) {
                          meetingStore.fetchLeaderboard(pollStore.poll);
                        }
                        showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: HMSThemeColors.surfaceDim,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16)),
                            ),
                            context: context,
                            builder: (ctx) => ChangeNotifierProvider.value(
                                  value: meetingStore,
                                  child: ChangeNotifierProvider.value(
                                    value: pollStore,
                                    child: PollVoteBottomSheet(
                                        isPoll: pollStore.poll.category ==
                                            HMSPollCategory.poll),
                                  ),
                                ));
                      },
                      childWidget: HMSTitleText(
                          text: "View",
                          textColor: HMSThemeColors.onSurfaceHighEmphasis))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
