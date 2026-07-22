import 'package:flutter/widgets.dart';

import '../theme/papyrus_theme.dart';
import '../theme/tokens.dart';

class PTabItem {
  const PTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final Widget icon;
  final Widget activeIcon;
  final String label;
}

/// Bottom-tab app shell, replacing CupertinoTabScaffold. Keeps each tab's
/// widget subtree alive via IndexedStack.
class PapyrusTabScaffold extends StatefulWidget {
  const PapyrusTabScaffold({
    super.key,
    required this.items,
    required this.tabs,
  });

  final List<PTabItem> items;
  final List<Widget> tabs;

  @override
  State<PapyrusTabScaffold> createState() => _PapyrusTabScaffoldState();
}

class _PapyrusTabScaffoldState extends State<PapyrusTabScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = PapyrusTheme.of(context);
    return ColoredBox(
      color: theme.background,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(index: _index, children: widget.tabs),
            ),
            Container(
              height: 58,
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border(top: BorderSide(color: theme.border)),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < widget.items.length; i++)
                    Expanded(child: _buildTabButton(theme, i)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(PapyrusThemeData theme, int i) {
    final selected = i == _index;
    final item = widget.items[i];
    final color = selected ? theme.primary : theme.textSecondary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _index = i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(color: color, size: 22),
              child: selected ? item.activeIcon : item.icon,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: theme.fontFamily,
                color: color,
                fontSize: PFontSize.xs - 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
