import 'package:papyrus/ui/ui.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const PapyrusScaffold(
      title: 'Search',
      body: Center(
        child: PapyrusText('Search'),
      ),
    );
  }
}
