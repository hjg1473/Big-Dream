import 'dart:convert';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:block_english/screens/SuperScreens/GameScreens/super_game_main_screen.dart';
import 'package:block_english/services/game_service.dart';
import 'package:block_english/utils/constants.dart';
import 'package:block_english/utils/game.dart';
import 'package:block_english/utils/status.dart';
import 'package:block_english/widgets/square_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SuperGameSettingScreen extends ConsumerStatefulWidget {
  const SuperGameSettingScreen({super.key});

  @override
  ConsumerState<SuperGameSettingScreen> createState() =>
      _SuperGameSettingScreenState();
}

class _SuperGameSettingScreenState
    extends ConsumerState<SuperGameSettingScreen> {
  Map<String, String> players = {};
  String pinNumber = '';
  late WebSocketChannel _channel;

  final _seasonList = [
    '시즌1',
  ];
  final _difficultyList = [
    'Level 1',
    'Level 2',
    'Level 3',
  ];

  int season = 1;
  int level = 1;
  int difficulty = 1;

  getPinNumber() async {
    final response = await ref.watch(gameServiceProvider).postGameCreate();

    response.fold(
      (failure) {
        //TODO: error handling
        debugPrint('[GETPINNUMBER] ${failure.detail}');
      },
      (gameRoomModel) {
        debugPrint('[PINNUMBER] ${gameRoomModel.pinNumber}');
        pinNumber = gameRoomModel.pinNumber;
        debugPrint(
            '[URI] $BASEWSURL/$pinNumber/${ref.watch(statusProvider).username}');
        _channel = WebSocketChannel.connect(
          Uri.parse(
              '$BASEWSURL/$pinNumber/${ref.watch(statusProvider).username}'),
        );
        _channel.stream.listen((message) {
          final decodedMessage = jsonDecode(message) as Map<String, dynamic>;

          for (final val in decodedMessage.entries) {
            debugPrint('key: ${val.key}, value: ${val.value}');
          }
          if (decodedMessage.containsKey('participant_name')) {
            players[decodedMessage['participant_id']] =
                (decodedMessage['participant_name'] ?? 'UNKNOWN');
            setState(() {});
          } else if (decodedMessage.containsKey('problems')) {
            for (final problem in decodedMessage['problems']) {
              ref.watch(gameProvider).problems[problem['problem_id']] =
                  problem['koreaProblem'];
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SuperGameMainScreen(
                  players: players,
                  pinNumber: pinNumber,
                  channel: _channel,
                ),
              ),
            );
          }
        }, onError: (error) {
          debugPrint('[WS:ERROR] $error');
        }, onDone: () {
          debugPrint('[WS:DISCONNECT]');
        });
      },
    );
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getPinNumber();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC6FEFF),
      body: SizedBox(
        height: 1.sh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 32,
                left: 64,
                right: 43,
                bottom: 24,
              ).r,
              child: SizedBox(
                width: 705.r,
                height: 251.r,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0).r,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(16.0).r,
                          width: 284.r,
                          height: 98.r,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '게임 참가 핀코드',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18.sp,
                                ),
                              ),
                              SizedBox(
                                width: 222.r,
                                height: 36.r,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    for (String pin in pinNumber.split(''))
                                      Container(
                                        alignment: Alignment.center,
                                        width: 32.r,
                                        height: 36.r,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFB13EFE),
                                          borderRadius:
                                              BorderRadius.circular(4.0).r,
                                        ),
                                        child: Text(
                                          pin,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 24.sp,
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0).r,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(16.0).r,
                          width: 284.r,
                          height: 86.r,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '게임 시간',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18.sp,
                                ),
                              ),
                              SizedBox(
                                width: 150.r,
                                height: 50.r,
                                child: CustomDropdown(
                                  decoration: CustomDropdownDecoration(
                                    closedBorderRadius:
                                        BorderRadius.circular(8.0).r,
                                    closedFillColor: const Color(0xFFC6FEFF),
                                    expandedFillColor: const Color(0xFFC6FEFF),
                                  ),
                                  items: const [
                                    '1분',
                                    '5분',
                                    '10분',
                                  ],
                                  onChanged: (val) {},
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: 180.r,
                      height: 250.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0).r,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 24.0,
                        horizontal: 16.0,
                      ).r,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '게임 설정',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18.sp,
                            ),
                          ),
                          SizedBox(
                            width: 150.r,
                            height: 50.r,
                            child: CustomDropdown(
                              //TODO: need season list
                              items: _seasonList,
                              initialItem: _seasonList[0],
                              decoration: CustomDropdownDecoration(
                                closedBorderRadius:
                                    BorderRadius.circular(8.0).r,
                                closedFillColor: const Color(0xFFC6FEFF),
                                expandedFillColor: const Color(0xFFC6FEFF),
                              ),
                              onChanged: (val) {
                                season = _seasonList.indexOf(val!) + 1;
                              },
                            ),
                          ),
                          SizedBox(
                            width: 150.r,
                            height: 50.r,
                            child: CustomDropdown(
                              //TODO: need grammar list for selected season
                              items: levelList,
                              initialItem: levelList[0],
                              decoration: CustomDropdownDecoration(
                                closedBorderRadius:
                                    BorderRadius.circular(8.0).r,
                                closedFillColor: const Color(0xFFC6FEFF),
                                expandedFillColor: const Color(0xFFC6FEFF),
                              ),
                              onChanged: (val) {
                                level = levelList.indexOf(val!) + 1;
                              },
                            ),
                          ),
                          SizedBox(
                            width: 150.r,
                            height: 50.r,
                            child: CustomDropdown(
                              //TODO: need season list
                              items: _difficultyList,
                              initialItem: _difficultyList[0],
                              decoration: CustomDropdownDecoration(
                                closedBorderRadius:
                                    BorderRadius.circular(8.0).r,
                                closedFillColor: const Color(0xFFC6FEFF),
                                expandedFillColor: const Color(0xFFC6FEFF),
                              ),
                              onChanged: (val) {
                                difficulty = _difficultyList.indexOf(val!) + 1;
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0).r,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 24.0,
                        horizontal: 16.0,
                      ).r,
                      width: 226.r,
                      height: 250.r,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 194.r,
                            height: 20.r,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '대기 인원',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18.sp,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                SizedBox(
                                  width: 16.r,
                                ),
                                Text(
                                  '참가 ${players.length}명',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.sp,
                                    color: const Color(0xFFAAAAAA),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16.0.r,
                          ),
                          SizedBox(
                            width: 194.r,
                            height: 166.r,
                            child: ListView.separated(
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 180.r,
                                  height: 50.r,
                                  padding: const EdgeInsets.all(15.0).r,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC6FEFF),
                                    borderRadius: BorderRadius.circular(8.0).r,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        players.values.elementAt(index),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Color(
                                            0xFF418B8C,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        '대기중',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(
                                            0xFF56B9BB,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Container(
                                  height: 8.r,
                                );
                              },
                              itemCount: players.length,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SquareButton(
              text: '게임 시작하기',
              onPressed: () {
                final jsonString = jsonEncode({
                  "message": "GameStart",
                  "level": level,
                  "season": season,
                  "difficulty": difficulty,
                });
                debugPrint(jsonString);
                _channel.sink.add(jsonString);
              },
            ),
          ],
        ),
      ),
    );
  }
}