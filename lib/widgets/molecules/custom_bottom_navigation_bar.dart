import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const CustomBottomNavigationBar({this.selectedIndex = 0, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    print("Selected index: $selectedIndex"); // 디버깅을 위해 추가
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 90, // 높이 설정
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed, // 모든 라벨을 항상 표시하도록 설정
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: selectedIndex == 0
                      ? SvgPicture.asset("assets/icons/active_calendar_tab.svg", height: 24)
                      : SvgPicture.asset("assets/icons/inactive_calendar_tab.svg", height: 24),
                  label: '캘린더',
                ),
                BottomNavigationBarItem(
                  icon: selectedIndex == 1
                      ? SvgPicture.asset("assets/icons/active_camera_tab.svg", height: 24)
                      : SvgPicture.asset("assets/icons/inactive_camera_tab.svg", height: 24),
                  label: '카메라',
                ),
                BottomNavigationBarItem(
                  icon: selectedIndex == 2
                      ? SvgPicture.asset("assets/icons/active_community_tab.svg", height: 24)
                      : SvgPicture.asset("assets/icons/inactive_community_tab.svg", height: 24),
                  label: '커뮤니티',
                ),
                BottomNavigationBarItem(
                  icon: selectedIndex == 3
                      ? SvgPicture.asset("assets/icons/active_profile_tab.svg", height: 24)
                      : SvgPicture.asset("assets/icons/inactive_profile_tab.svg", height: 24),
                  label: '마이페이지',
                ),
              ],
              backgroundColor: backGroundColor,
              currentIndex: selectedIndex,
              selectedItemColor: gray900,
              unselectedItemColor: gray500,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              onTap: (index) {
                print("Tab $index selected"); // 디버깅을 위해 추가
                if (index == 1) {
                  Navigator.of(context, rootNavigator: true).pushNamed("/camera");
                } else {
                  onTap(index);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
