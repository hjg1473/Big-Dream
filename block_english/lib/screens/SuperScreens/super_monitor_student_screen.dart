import 'package:block_english/models/StudentModel/student_weak_part_model.dart';
import 'package:block_english/services/super_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String learning = '/';
const String incorrect = '/incorrect';
const String manage = '/manage';

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({required super.builder});

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    //return FadeTransition(opacity: animation, child: child);
    return SlideTransition(
      position:
          Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 0))
              //.chain(CurveTween(curve: Curves.linear))
              .animate(animation),
      child: child,
    );
  }
}

class MonitorStudentScreen extends StatefulWidget {
  const MonitorStudentScreen({
    super.key,
    required this.studentName,
    required this.studentId,
    this.groupName = '',
  });

  final String studentName;
  final int studentId;
  final String groupName;

  @override
  State<MonitorStudentScreen> createState() => _MonitorStudentScreenState();
}

class _MonitorStudentScreenState extends State<MonitorStudentScreen> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  int currentPage = 1;
  Color? unselectedFontColor = Colors.black;
  Color? selectedFontColor = const Color(0xFF58892E);
  Color? unselectedBackgroundColor = const Color(0xFFD9D9D9);
  Color? selectedBackgroundColor = const Color(0xFFA9EA70);
  Color selectedBorderColor = const Color(0xFF8AD24C);

  onMenuPressed(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState!.pushReplacementNamed(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 1.sw,
        height: 1.sh,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 32,
                  left: 64,
                ).h,
                child: SizedBox(
                  height: 319.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: SvgPicture.asset(
                          'assets/buttons/round_back_button.svg',
                          width: 48.r,
                          height: 48.r,
                        ),
                      ),
                      const Spacer(flex: 2),
                      Text(
                        widget.studentName,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 7.r),
                      Text(
                        widget.groupName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(flex: 1),
                      FilledButton(
                        onPressed: () {
                          if (currentPage != 1) {
                            onMenuPressed(learning);
                            setState(() {
                              currentPage = 1;
                            });
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: Size(176.r, 48.r),
                          backgroundColor: currentPage == 1
                              ? selectedBackgroundColor
                              : unselectedBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ).r,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8).r,
                            side: currentPage == 1
                                ? BorderSide(
                                    color: selectedBorderColor,
                                  )
                                : BorderSide.none,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text(
                          '학습 분석',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: currentPage == 1
                                ? selectedFontColor
                                : unselectedFontColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.r),
                      FilledButton(
                        onPressed: () {
                          if (currentPage != 2) {
                            onMenuPressed(incorrect);
                            setState(() {
                              currentPage = 2;
                            });
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: Size(176.r, 48.r),
                          backgroundColor: currentPage == 2
                              ? selectedBackgroundColor
                              : unselectedBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ).r,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8).r,
                            side: currentPage == 2
                                ? BorderSide(
                                    color: selectedBorderColor,
                                  )
                                : BorderSide.none,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text(
                          '오답 분석',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: currentPage == 2
                                ? selectedFontColor
                                : unselectedFontColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.r),
                      FilledButton(
                        onPressed: () {
                          if (currentPage != 3) {
                            onMenuPressed(manage);
                            setState(() {
                              currentPage = 3;
                            });
                          }
                        },
                        style: FilledButton.styleFrom(
                          minimumSize: Size(176.r, 48.r),
                          backgroundColor: currentPage == 3
                              ? selectedBackgroundColor
                              : unselectedBackgroundColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8).r,
                            side: currentPage == 3
                                ? BorderSide(
                                    color: selectedBorderColor,
                                  )
                                : BorderSide.none,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text(
                          '학습자 관리',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: currentPage == 3
                                ? selectedFontColor
                                : unselectedFontColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 553.r,
                height: 1.sh,
                color: const Color(0xFFECECEC),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 64,
                  vertical: 24,
                ).r,
                child: SizedBox(
                  width: 425.r,
                  height: 327.r,
                  child: Navigator(
                    key: _navigatorKey,
                    initialRoute: learning,
                    onGenerateRoute: (settings) {
                      return CustomRoute(
                        builder: (context) {
                          switch (settings.name) {
                            case learning:
                              return LearningAnalysis(userId: widget.studentId);
                            case incorrect:
                              return Incorrect(
                                  userId: widget.studentId,
                                  userName: widget.studentName);
                            case manage:
                              return ManageStudent(userId: widget.studentId);
                            default:
                              return LearningAnalysis(userId: widget.studentId);
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LearningAnalysis extends ConsumerStatefulWidget {
  const LearningAnalysis({super.key, required this.userId});
  final int userId;

  @override
  ConsumerState<LearningAnalysis> createState() => _LearningAnalysisState();
}

class _LearningAnalysisState extends ConsumerState<LearningAnalysis> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 465.r,
      height: 327.r,
      color: const Color(0xFFECECEC),
      child: Stack(
        children: [
          Container(
            width: 302.r,
            height: 142.r,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8).r,
            ),
          ),
        ],
      ),
    );
  }
}

class Incorrect extends ConsumerStatefulWidget {
  const Incorrect({
    super.key,
    required this.userId,
    required this.userName,
  });
  final int userId;
  final String userName;

  @override
  ConsumerState<Incorrect> createState() => _IncorrectState();
}

class _IncorrectState extends ConsumerState<Incorrect> {
  bool isLoading = true;
  List<WeakPartModel> weakParts = [];
  String weakest = '';
  String recentProblem = '';
  String recentAnswer = '';
  String recentDetail = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    waitForData();
  }

  waitForData() async {
    final response = await ref
        .watch(superServiceProvider)
        .postUserMonitoringIncorrect(widget.userId);

    response.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${failure.statusCode} : ${failure.detail}'),
        ),
      );
    }, (data) {
      //TODO: check mapping weakParts
      weakParts = data.weakParts
          .map((weakPart) => WeakPartModel.fromJson(weakPart))
          .toList();
      weakest = data.weakest;
      recentProblem = data.recentProblem ?? 'I love block english.';
      recentAnswer = data.recentAnswer ?? 'I block english love.';
      recentDetail = data.recentDetail;

      debugPrint('userId: ${widget.userId} weakest: $weakest');
    });
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO: 푼 문제 없을 때 화면 구성
    return Container(
      width: 425.r,
      height: 327.r,
      color: const Color(0xFFECECEC),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            )
          : Stack(
              children: [
                Container(
                  width: 425.r,
                  height: 152.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8).r,
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    11,
                    12,
                    10,
                    10,
                  ).r,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 274.r,
                        height: 130.r,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10).r,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 9.r,
                                vertical: 3.r,
                              ),
                              child: Text(
                                '오답 원인',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            //TODO: 그래프 추가
                            Container(
                              width: 274.r,
                              height: 96.r,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '가장 약한 부분은?',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5.r),
                          Text(
                            '$weakest 오류',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //TODO: display svg image
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: SvgPicture.asset(
                    'assets/images/monitor_character1.svg',
                    width: 63.r,
                    height: 120.r,
                  ),
                ),
                Positioned(
                  left: 86.r,
                  bottom: 70.r,
                  child: Container(
                    width: 162.r,
                    height: 90.r,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8).r,
                    ),
                    padding: const EdgeInsets.all(10).r,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '최근에 틀린 문제',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          recentProblem,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 70.r,
                  child: Container(
                    width: 162.r,
                    height: 90.r,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8).r,
                    ),
                    padding: const EdgeInsets.all(10).r,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.userName}의 답',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          recentAnswer,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 339.r,
                    height: 55.r,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8).r,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 19,
                    ).r,
                    child: Center(
                      child: Text(
                        recentDetail,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class ManageStudent extends ConsumerStatefulWidget {
  const ManageStudent({super.key, required this.userId});
  final int userId;

  @override
  ConsumerState<ManageStudent> createState() => _ManageStudentState();
}

class _ManageStudentState extends ConsumerState<ManageStudent> {
  bool isLoading = true;
  int totalStudyTime = 0;
  int streamStudyDay = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    waitForData();
  }

  waitForData() async {
    final response = await ref
        .watch(superServiceProvider)
        .postUserMonitoringEtc(widget.userId);

    response.fold((failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${failure.statusCode} : ${failure.detail}'),
        ),
      );
    }, (data) {
      totalStudyTime = data.totalStudyTime;
      streamStudyDay = data.streamStudyDay;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 425.r,
      height: 327.r,
      color: const Color(0xFFECECEC),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            )
          : Stack(
              children: [
                Positioned(
                  left: 80.r,
                  top: 37.r,
                  child: SvgPicture.asset(
                    'assets/images/monitor_day_icon.svg',
                    width: 34.r,
                    height: 38.r,
                  ),
                ),
                Positioned(
                  left: 127.r,
                  top: 40.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streamStudyDay일째',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '연속 학습 중',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB2B2B2),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 37.r,
                  right: 155.r,
                  child: SvgPicture.asset(
                    'assets/images/monitor_time_icon.svg',
                    width: 34.r,
                    height: 38.r,
                  ),
                ),
                Positioned(
                  right: 79.r,
                  top: 40.r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$totalStudyTime시간',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '총 학습 시간',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB2B2B2),
                        ),
                      ),
                    ],
                  ),
                ),
                //TODO: display svg image
                Positioned(
                  bottom: 62.r,
                  left: 46.r,
                  child: SvgPicture.asset(
                    'assets/images/monitor_character3.svg',
                    width: 334.r,
                    height: 166.r,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      minimumSize: Size(311.r, 37.r),
                      backgroundColor: const Color(0xFF484848),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ).r,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8).r,
                      ),
                      alignment: Alignment.center,
                    ),
                    child: Text(
                      '학습자 삭제',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
