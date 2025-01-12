import 'dart:convert';
import 'package:day1/providers/calendar_title_provider.dart';
import 'package:day1/providers/total_record_count_provider.dart';
import 'package:day1/services/app_database.dart';
import 'package:day1/services/device_size_provider.dart';
import 'package:day1/services/dio.dart';
import 'package:day1/services/server_token_provider.dart';
import 'package:day1/widgets/atoms/calendar_rich_text.dart';
import 'package:day1/widgets/molecules/show_Error_Popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/size.dart';
import '../models/calendar_image_model.dart';
import '../services/auth_service.dart';
import '../models/token_information.dart';
import '../widgets/organisms/custom_table_calendar.dart';


class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  Map<DateTime, CalendarImage> imageMap = {};
  bool isGetFinish = false;
  late int _year;
  late int _month;
  @override
  void initState() {
    super.initState();

    int year = DateTime.now().year;
    int month = DateTime.now().month;
    getCalendarImage(year, month);
  }

  // 서버에서 캘린더 이미지를 불러오는 함수
  Future<void> getCalendarImage(int year, int month) async {
    //provider에서 서버 토큰 정보 get
    String? token = ref.read(ServerTokenProvider.notifier).getServerToken();
    List<dynamic>? responseList;

    _year = year;
    _month = month;
    imageMap.clear();

    if(token != null){
      //token 정보 json string 디코딩
      Map<String, dynamic> tokenMap = jsonDecode(token);
      //Map 데이터를 모델클래스로 컨버팅
      TokenInformation tokenInfo = TokenInformation.fromJson(tokenMap);
      // 캘린더 api 함수
      var response = await DioService.getImageList(year, month, tokenInfo.accessToken);
      if(response.toString().contains("Error")){
        DioService.showErrorPopup(context, response.replaceFirst("Error", ""));
      }
      else{
        responseList = response;
      }
      //responseList가 null일 경우 재로그인
      if(responseList == null){
        AppDataBase.clearToken();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
      else{
        // day는 imageMap<Map>의 키로 사용하고 value로는 썸네일 이미지와 원본이미지를 멤버로 갖고 있는 CalendarImage 모델 클래스로 사용
        responseList.forEach((element) {
          imageMap[DateTime(_year, _month, element['day'])] = CalendarImage(thumbNailUrl: element['thumbNailUrl'], defaultUrl: element['defaultUrl'], date: '');
        });
        setState(() {
          // 통신이 끝났는지 플래그값 설정
          isGetFinish = true;
          print("response success");
        });
      }




    }
    else{
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }

  }

  @override
  Widget build(BuildContext context) {

    // provider에서 실제 화면 width get
    double deviceWidth = ref.watch(deviceSizeProvider.notifier).getDeviceWidth();
    // calendar headermargin 크기
    double headerMargin = (deviceWidth - 225) / 2;
    // calendar title get
    String? calendarTitle = ref.watch(calendarTitleProvider.notifier).state;

    String? totalCount = ref.watch(totalRecordCount.notifier).state;


    return Padding(
      padding: screenHorizontalMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: calendarTopMargin,
          ),
          //서버에서 사진을 저장한 일자대로 리스트를 넘겨주므로 리스트의 길이를 매개변수로 넘겨준다
          CalendarRichText(title: calendarTitle,recordNum: totalCount,),
          SizedBox(
            height: 20,
          ),
          // dio 통신 응답 받기전 예외 처리
          isGetFinish == false ? Center(child: CircularProgressIndicator()) :
          CustomTableCalendar(year: _year, month: _month, headerMargin: headerMargin, imageMap: imageMap, shifhtMonth: getCalendarImage,),
        ],
      ),
    );
  }
}

