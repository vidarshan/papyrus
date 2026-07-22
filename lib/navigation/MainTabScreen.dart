import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:papyrus/tabs/HomeTab.dart';
import 'package:papyrus/tabs/LibraryTab.dart';
import 'package:papyrus/tabs/ProfileTab.dart';
import 'package:papyrus/tabs/SearchTab.dart';
import 'package:papyrus/ui/ui.dart';

class MainTabScreen extends StatelessWidget {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PapyrusTabScaffold(
      items: [
        PTabItem(
          icon: Icon(CupertinoIcons.house),
          activeIcon: Icon(CupertinoIcons.house_fill),
          label: 'Home',
        ),
        PTabItem(
          icon: Icon(CupertinoIcons.search),
          activeIcon: Icon(CupertinoIcons.search),
          label: 'Search',
        ),
        PTabItem(
          icon: Icon(CupertinoIcons.book),
          activeIcon: Icon(CupertinoIcons.book_fill),
          label: 'Library',
        ),
        PTabItem(
          icon: Icon(CupertinoIcons.person),
          activeIcon: Icon(CupertinoIcons.person_fill),
          label: 'Profile',
        ),
      ],
      tabs: [
        HomeTab(),
        SearchTab(),
        LibraryTab(),
        ProfileTab(),
      ],
    );
  }
}
