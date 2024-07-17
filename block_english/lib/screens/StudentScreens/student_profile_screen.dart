import 'package:block_english/models/StudentModel/student_info_model.dart';
import 'package:block_english/services/student_service.dart';
import 'package:block_english/widgets/profile_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  return FutureBuilder(
                    future: ref.watch(studentServiceProvider).getStudentInfo(),
                    builder: (context, snapshot) {
                      late StudentInfoModel studentInfo;
                      String error = '';
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      snapshot.data!.fold(
                        (failure) {
                          error = failure.detail;
                        },
                        (studentinfo) {
                          studentInfo = studentinfo;
                        },
                      );
                      return error.isEmpty
                          ? ProfileCard(
                              name: studentInfo.name,
                              age: studentInfo.age,
                              isStudent: true,
                            )
                          : // TODO: Error handling
                          Text(error);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
