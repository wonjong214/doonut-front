import 'dart:convert';
import 'package:day1/models/token_information.dart';
import 'package:day1/services/server_token_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/colors.dart';
import '../../constants/size.dart';
import '../../providers/total_record_count_provider.dart';
import '../../screens/camera/camera.dart';
import '../../services/dio.dart';

class StoreTextButton extends ConsumerWidget {
  int count = 0;

  StoreTextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parent = context.findAncestorStateOfType<CameraScreenState>();
    //서버 토큰 불러오기
    String? token = ref.watch(ServerTokenProvider.notifier).getServerToken();
    return TextButton(
      onPressed: () async {
        count++;
        //중복 클릭 방지
        if(count < 2){
          //camareascreen의 response이미지가 null이 아니고 서버토큰이 null이 아닐 시 서버에 이미지 업로드
          if (parent != null && parent.responseImage != null && token != null) {
            // provider에서 실제 화면 width get
            Map<String, dynamic> tokenMap = jsonDecode(token);
            // calendar headermargin 크기
            TokenInformation tokenInfo = TokenInformation.fromJson(tokenMap);
            String? response = await DioService.uploadImage(
                parent!.responseImage!, tokenInfo.accessToken);
            //이미지 업로드가 정상적으로 수행됐을 때 달력화면으로 전환
            if (response == null) {
              Navigator.pushReplacementNamed(context, '/main');
            }
            else {
              DioService.showErrorPopup(context, response, navigate: (){
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              });
              ;
            }
            var totalCount = await DioService.getTotalRecordCount(tokenInfo.accessToken);
            if(totalCount.toString().contains("Error")){
              DioService.showErrorPopup(context, totalCount.toString().replaceFirst("Error", ""));
            }
            else{
              ref.read(totalRecordCount.notifier).state = totalCount;
            }
          }
        }
      },
      child: Text(
        "저장",
        style: TextStyle(
            fontSize: cameraScreenAppBarTextSize, color: textButtonColor),
      ),
    );
  }
}
