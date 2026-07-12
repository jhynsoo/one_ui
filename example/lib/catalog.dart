import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:one_ui/one_ui.dart' as one_ui;

/// Stable identifiers for the catalog's eight sections.
abstract final class CatalogSectionIds {
  static const String appBarAndView = 'app-bar-and-view';
  static const String bottomNavigation = 'bottom-navigation';
  static const String buttons = 'buttons';
  static const String dialogs = 'dialogs';
  static const String popupMenus = 'popup-menus';
  static const String switches = 'switches';
  static const String sliders = 'sliders';
  static const String inkEffects = 'ink-effects';
}

/// Stable identifiers for every public widget demonstrated by the catalog.
abstract final class CatalogWidgetIds {
  static const String appBar = 'one-ui-app-bar';
  static const String bottomNavigationBar = 'one-ui-bottom-navigation-bar';
  static const String backButton = 'one-ui-back-button';
  static const String containedButton = 'one-ui-contained-button';
  static const String flatButton = 'one-ui-flat-button';
  static const String iconButton = 'one-ui-icon-button';
  static const String dialog = 'one-ui-dialog';
  static const String alertDialog = 'one-ui-alert-dialog';
  static const String popupMenuItem = 'one-ui-popup-menu-item';
  static const String popupMenuButton = 'one-ui-popup-menu-button';
  static const String switchControl = 'one-ui-switch';
  static const String slider = 'one-ui-slider';
  static const String view = 'one-ui-view';
}

/// The complete public-widget coverage contract for this example.
const Set<String> requiredCatalogWidgetIds = <String>{
  CatalogWidgetIds.appBar,
  CatalogWidgetIds.bottomNavigationBar,
  CatalogWidgetIds.backButton,
  CatalogWidgetIds.containedButton,
  CatalogWidgetIds.flatButton,
  CatalogWidgetIds.iconButton,
  CatalogWidgetIds.dialog,
  CatalogWidgetIds.alertDialog,
  CatalogWidgetIds.popupMenuItem,
  CatalogWidgetIds.popupMenuButton,
  CatalogWidgetIds.switchControl,
  CatalogWidgetIds.slider,
  CatalogWidgetIds.view,
};

/// Keys shared by the example and its smoke tests.
abstract final class CatalogKeys {
  static const ValueKey<String> homeList = ValueKey<String>(
    'catalog.home.list',
  );
  static const ValueKey<String> homeStatus = ValueKey<String>(
    'catalog.home.status',
  );
  static const ValueKey<String> themeMode = ValueKey<String>(
    'catalog.home.theme-mode',
  );
  static const ValueKey<String> materialYouMode = ValueKey<String>(
    'catalog.home.material-you-mode',
  );
  static const ValueKey<String> viewScroll = ValueKey<String>(
    'catalog.view.scroll',
  );

  static ValueKey<String> openSection(String sectionId) =>
      ValueKey<String>('catalog.section.open.$sectionId');

  static ValueKey<String> page(String sectionId) =>
      ValueKey<String>('catalog.section.page.$sectionId');

  static ValueKey<String> status(String sectionId) =>
      ValueKey<String>('catalog.section.status.$sectionId');

  static ValueKey<String> widget(String widgetId) =>
      ValueKey<String>('catalog.widget.$widgetId');

  static ValueKey<String> action(String actionId) =>
      ValueKey<String>('catalog.action.$actionId');
}

typedef CatalogPageBuilder = Widget Function(BuildContext context);

@immutable
final class CatalogSection {
  const CatalogSection({
    required this.id,
    required this.title,
    required this.description,
    required this.widgetIds,
    required this.builder,
  });

  final String id;
  final String title;
  final String description;
  final Set<String> widgetIds;
  final CatalogPageBuilder builder;
}

final List<CatalogSection> catalogSections = <CatalogSection>[
  CatalogSection(
    id: CatalogSectionIds.appBarAndView,
    title: 'App Bar & View',
    description: 'Expanded One UI navigation and a standalone app bar.',
    widgetIds: const <String>{
      CatalogWidgetIds.appBar,
      CatalogWidgetIds.backButton,
      CatalogWidgetIds.view,
    },
    builder: (_) => const AppBarAndViewCatalogPage(),
  ),
  CatalogSection(
    id: CatalogSectionIds.bottomNavigation,
    title: 'Bottom Navigation',
    description: 'A stateful two-destination bottom navigation bar.',
    widgetIds: const <String>{CatalogWidgetIds.bottomNavigationBar},
    builder: (_) => const BottomNavigationCatalogPage(),
  ),
  CatalogSection(
    id: CatalogSectionIds.buttons,
    title: 'Buttons',
    description: 'Contained, flat, and icon buttons in enabled states.',
    widgetIds: const <String>{
      CatalogWidgetIds.containedButton,
      CatalogWidgetIds.flatButton,
      CatalogWidgetIds.iconButton,
    },
    builder: (_) => const ButtonsCatalogPage(),
  ),
  CatalogSection(
    id: CatalogSectionIds.dialogs,
    title: 'Dialogs',
    description: 'Raw and alert dialogs opened with showOneUIDialog.',
    widgetIds: const <String>{
      CatalogWidgetIds.dialog,
      CatalogWidgetIds.alertDialog,
    },
    builder: (_) => const DialogsCatalogPage(),
  ),
  CatalogSection(
    id: CatalogSectionIds.popupMenus,
    title: 'Popup Menus',
    description: 'Popup button and direct showMenu route results.',
    widgetIds: const <String>{
      CatalogWidgetIds.popupMenuItem,
      CatalogWidgetIds.popupMenuButton,
    },
    builder: (_) => const PopupMenusCatalogPage(),
  ),
  CatalogSection(
    id: CatalogSectionIds.switches,
    title: 'Switches',
    description: 'Enabled and disabled switch states.',
    widgetIds: const <String>{CatalogWidgetIds.switchControl},
    builder: (_) => const SwitchesCatalogPage(),
  ),
  CatalogSection(
    id: CatalogSectionIds.sliders,
    title: 'Sliders',
    description: 'Continuous, discrete, and disabled slider states.',
    widgetIds: const <String>{CatalogWidgetIds.slider},
    builder: (_) => const SlidersCatalogPage(),
  ),
  CatalogSection(
    id: CatalogSectionIds.inkEffects,
    title: 'Ink Effects',
    description: 'Interactive OneUIInkRipple and OneUIInkSplash previews.',
    widgetIds: const <String>{},
    builder: (_) => const InkEffectsCatalogPage(),
  ),
];

class OneUICatalogApp extends StatefulWidget {
  const OneUICatalogApp({super.key});

  @override
  State<OneUICatalogApp> createState() => _OneUICatalogAppState();
}

class _OneUICatalogAppState extends State<OneUICatalogApp> {
  static const Color _materialYouFallbackSeed = Color(0xff0381fe);

  ThemeMode _themeMode = ThemeMode.light;
  bool _materialYouEnabled = false;

  ThemeData _theme({
    required Brightness brightness,
    required ColorScheme? dynamicColorScheme,
  }) {
    final ColorScheme? colorScheme = _materialYouEnabled
        ? dynamicColorScheme ??
              ColorScheme.fromSeed(
                seedColor: _materialYouFallbackSeed,
                brightness: brightness,
              )
        : null;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[
        one_ui.OneUIThemeData(
          colorMode: _materialYouEnabled
              ? one_ui.OneUIColorMode.materialYou
              : one_ui.OneUIColorMode.oneUI,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder:
          (
            ColorScheme? lightDynamicColorScheme,
            ColorScheme? darkDynamicColorScheme,
          ) {
            final bool darkMode = _themeMode == ThemeMode.dark;
            final bool currentDynamicColorAvailable = darkMode
                ? darkDynamicColorScheme != null
                : lightDynamicColorScheme != null;

            return MaterialApp(
              title: 'One UI Widget Catalog',
              debugShowCheckedModeBanner: false,
              theme: _theme(
                brightness: Brightness.light,
                dynamicColorScheme: lightDynamicColorScheme,
              ),
              darkTheme: _theme(
                brightness: Brightness.dark,
                dynamicColorScheme: darkDynamicColorScheme,
              ),
              themeMode: _themeMode,
              home: CatalogHomePage(
                darkMode: darkMode,
                materialYouEnabled: _materialYouEnabled,
                materialYouUsesDynamicColor: currentDynamicColorAvailable,
                onThemeModeChanged: (bool darkMode) {
                  setState(() {
                    _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
                  });
                },
                onMaterialYouChanged: (bool enabled) {
                  setState(() {
                    _materialYouEnabled = enabled;
                  });
                },
              ),
            );
          },
    );
  }
}

class CatalogHomePage extends StatelessWidget {
  const CatalogHomePage({
    required this.darkMode,
    required this.materialYouEnabled,
    required this.materialYouUsesDynamicColor,
    required this.onThemeModeChanged,
    required this.onMaterialYouChanged,
    super.key,
  });

  final bool darkMode;
  final bool materialYouEnabled;
  final bool materialYouUsesDynamicColor;
  final ValueChanged<bool> onThemeModeChanged;
  final ValueChanged<bool> onMaterialYouChanged;

  String get _statusLabel {
    final String theme = darkMode ? 'dark' : 'light';
    final String materialYou = switch ((
      materialYouEnabled,
      materialYouUsesDynamicColor,
    )) {
      (false, _) => 'off',
      (true, true) => 'on (dynamic)',
      (true, false) => 'on (seed fallback)',
    };
    return 'Theme: $theme · Material You: $materialYou · 8 sections';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('One UI Widget Catalog'),
        actions: <Widget>[
          IconButton(
            key: CatalogKeys.themeMode,
            tooltip: darkMode ? 'Use light theme' : 'Use dark theme',
            onPressed: () => onThemeModeChanged(!darkMode),
            icon: Icon(darkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: ListView.separated(
        key: CatalogKeys.homeList,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: catalogSections.length + 2,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _StatusCard(
              key: CatalogKeys.homeStatus,
              label: _statusLabel,
            );
          }

          if (index == 1) {
            return Card(
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile(
                key: CatalogKeys.materialYouMode,
                title: const Text('Material You'),
                subtitle: const Text(
                  'Use the device palette when available, or a seeded fallback.',
                ),
                value: materialYouEnabled,
                onChanged: onMaterialYouChanged,
              ),
            );
          }

          final CatalogSection section = catalogSections[index - 2];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              key: CatalogKeys.openSection(section.id),
              title: Text(section.title),
              subtitle: Text(section.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    settings: RouteSettings(
                      name: '/catalog/${section.id}',
                      arguments: section,
                    ),
                    builder: section.builder,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(label),
        ),
      ),
    );
  }
}

class _CatalogScaffold extends StatelessWidget {
  const _CatalogScaffold({
    required this.sectionId,
    required this.title,
    required this.status,
    required this.children,
  });

  final String sectionId;
  final String title;
  final String status;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: CatalogKeys.page(sectionId),
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: <Widget>[
            _StatusCard(key: CatalogKeys.status(sectionId), label: status),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DemoHeading extends StatelessWidget {
  const _DemoHeading(this.data);

  final String data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(data, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class AppBarAndViewCatalogPage extends StatefulWidget {
  const AppBarAndViewCatalogPage({super.key});

  @override
  State<AppBarAndViewCatalogPage> createState() =>
      _AppBarAndViewCatalogPageState();
}

class _AppBarAndViewCatalogPageState extends State<AppBarAndViewCatalogPage> {
  String _status = 'Ready';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: CatalogKeys.page(CatalogSectionIds.appBarAndView),
      body: one_ui.OneUIView(
        key: CatalogKeys.widget(CatalogWidgetIds.view),
        title: const Text('App Bar & View'),
        largeTitle: const Text('App Bar & View'),
        child: ListView(
          key: CatalogKeys.viewScroll,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: <Widget>[
            _StatusCard(
              key: CatalogKeys.status(CatalogSectionIds.appBarAndView),
              label: _status,
            ),
            const SizedBox(height: 20),
            const _DemoHeading('Standalone OneUIAppBar'),
            SizedBox(
              height: 124,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Scaffold(
                  appBar: one_ui.OneUIAppBar(
                    key: CatalogKeys.widget(CatalogWidgetIds.appBar),
                    automaticallyImplyLeading: false,
                    leading: one_ui.OneUIBackButton(
                      key: CatalogKeys.widget(CatalogWidgetIds.backButton),
                      onPressed: () {
                        setState(() {
                          _status = 'Back button pressed';
                        });
                      },
                    ),
                    title: const Text('Preview'),
                    actions: <Widget>[
                      IconButton(
                        tooltip: 'Preview action',
                        onPressed: () {
                          setState(() {
                            _status = 'App bar action pressed';
                          });
                        },
                        icon: const Icon(Icons.star_outline),
                      ),
                    ],
                  ),
                  body: const Center(child: Text('Standalone app bar body')),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scroll this page to collapse and expand the OneUIView header.',
            ),
            ...List<Widget>.generate(
              6,
              (int index) => Card(
                child: ListTile(
                  leading: const Icon(Icons.layers_outlined),
                  title: Text('Scrollable sample ${index + 1}'),
                  subtitle: const Text('OneUIView nested scroll content'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavigationCatalogPage extends StatefulWidget {
  const BottomNavigationCatalogPage({super.key});

  @override
  State<BottomNavigationCatalogPage> createState() =>
      _BottomNavigationCatalogPageState();
}

class _BottomNavigationCatalogPageState
    extends State<BottomNavigationCatalogPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    const List<String> labels = <String>['Overview', 'Library'];
    return Scaffold(
      key: CatalogKeys.page(CatalogSectionIds.bottomNavigation),
      appBar: AppBar(title: const Text('Bottom Navigation')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _StatusCard(
                key: CatalogKeys.status(CatalogSectionIds.bottomNavigation),
                label: 'Selected: ${labels[_currentIndex]}',
              ),
              const Spacer(),
              Icon(
                _currentIndex == 0
                    ? Icons.home_outlined
                    : Icons.widgets_outlined,
                size: 64,
              ),
              const SizedBox(height: 12),
              Text(
                labels[_currentIndex],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: one_ui.OneUIBottomNavigationBar(
        key: CatalogKeys.widget(CatalogWidgetIds.bottomNavigationBar),
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const <one_ui.OneUIBottomNavigationBarItem>[
          one_ui.OneUIBottomNavigationBarItem(label: 'Overview'),
          one_ui.OneUIBottomNavigationBarItem(label: 'Library'),
        ],
      ),
    );
  }
}

class ButtonsCatalogPage extends StatefulWidget {
  const ButtonsCatalogPage({super.key});

  @override
  State<ButtonsCatalogPage> createState() => _ButtonsCatalogPageState();
}

class _ButtonsCatalogPageState extends State<ButtonsCatalogPage> {
  String _status = 'Ready';

  void _record(String value) {
    setState(() {
      _status = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CatalogScaffold(
      sectionId: CatalogSectionIds.buttons,
      title: 'Buttons',
      status: _status,
      children: <Widget>[
        const _DemoHeading('Enabled'),
        one_ui.OneUIContainedButton(
          key: CatalogKeys.widget(CatalogWidgetIds.containedButton),
          onPressed: () => _record('Contained button pressed'),
          style: const ButtonStyle(
            minimumSize: WidgetStatePropertyAll<Size>(Size(180, 44)),
          ),
          child: const Text('Contained button'),
        ),
        const SizedBox(height: 12),
        one_ui.OneUIFlatButton(
          key: CatalogKeys.widget(CatalogWidgetIds.flatButton),
          onPressed: () => _record('Flat button pressed'),
          style: const ButtonStyle(
            minimumSize: WidgetStatePropertyAll<Size>(Size(180, 44)),
          ),
          child: const Text('Flat button'),
        ),
        const SizedBox(height: 12),
        Align(
          child: one_ui.OneUIIconButton(
            key: CatalogKeys.widget(CatalogWidgetIds.iconButton),
            tooltip: 'Favorite',
            onPressed: () => _record('Icon button pressed'),
            icon: const Icon(Icons.favorite_outline),
          ),
        ),
        const _DemoHeading('Disabled'),
        const Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: <Widget>[
            one_ui.OneUIContainedButton(
              onPressed: null,
              child: Text('Disabled contained'),
            ),
            one_ui.OneUIFlatButton(
              onPressed: null,
              child: Text('Disabled flat'),
            ),
          ],
        ),
      ],
    );
  }
}

enum CatalogDialogResult { accepted, canceled, closed }

class DialogsCatalogPage extends StatefulWidget {
  const DialogsCatalogPage({super.key});

  @override
  State<DialogsCatalogPage> createState() => _DialogsCatalogPageState();
}

class _DialogsCatalogPageState extends State<DialogsCatalogPage> {
  String _status = 'Ready';

  Future<void> _showRawDialog() async {
    final CatalogDialogResult? result = await one_ui
        .showOneUIDialog<CatalogDialogResult>(
          key: CatalogKeys.action('dialog.route.raw'),
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return one_ui.OneUIDialog(
              key: CatalogKeys.widget(CatalogWidgetIds.dialog),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'OneUIDialog',
                        style: Theme.of(dialogContext).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'A custom dialog body using the One UI surface.',
                      ),
                      const SizedBox(height: 20),
                      one_ui.OneUIFlatButton(
                        key: CatalogKeys.action('dialog.raw.close'),
                        onPressed: () => Navigator.of(
                          dialogContext,
                        ).pop(CatalogDialogResult.closed),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _status = 'Raw dialog: ${result?.name ?? 'dismissed'}';
    });
  }

  Future<void> _showAlertDialog() async {
    final CatalogDialogResult?
    result = await one_ui.showOneUIDialog<CatalogDialogResult>(
      context: context,
      builder: (BuildContext dialogContext) {
        return one_ui.OneUIAlertDialog(
          key: CatalogKeys.widget(CatalogWidgetIds.alertDialog),
          title: const Text('Save changes?'),
          content: const Text('This demonstrates typed dialog route results.'),
          actions: <one_ui.OneUIDialogAction>[
            one_ui.OneUIDialogAction(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(CatalogDialogResult.canceled),
              child: Text(
                'Cancel',
                key: CatalogKeys.action('dialog.alert.cancel'),
              ),
            ),
            one_ui.OneUIDialogAction(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(CatalogDialogResult.accepted),
              child: Text(
                'Accept',
                key: CatalogKeys.action('dialog.alert.accept'),
              ),
            ),
          ],
        );
      },
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _status = 'Alert dialog: ${result?.name ?? 'dismissed'}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CatalogScaffold(
      sectionId: CatalogSectionIds.dialogs,
      title: 'Dialogs',
      status: _status,
      children: <Widget>[
        one_ui.OneUIContainedButton(
          key: CatalogKeys.action('dialog.raw.open'),
          onPressed: _showRawDialog,
          child: const Text('Open OneUIDialog'),
        ),
        const SizedBox(height: 12),
        one_ui.OneUIFlatButton(
          key: CatalogKeys.action('dialog.alert.open'),
          onPressed: _showAlertDialog,
          child: const Text('Open OneUIAlertDialog'),
        ),
      ],
    );
  }
}

enum CatalogPopupChoice { first, second, direct }

class PopupMenusCatalogPage extends StatefulWidget {
  const PopupMenusCatalogPage({super.key});

  @override
  State<PopupMenusCatalogPage> createState() => _PopupMenusCatalogPageState();
}

class _PopupMenusCatalogPageState extends State<PopupMenusCatalogPage> {
  final GlobalKey _directMenuAnchorKey = GlobalKey();
  String _status = 'Ready';

  void _recordChoice(CatalogPopupChoice choice) {
    setState(() {
      _status = 'Selected: ${choice.name}';
    });
  }

  Future<void> _showDirectMenu() async {
    final BuildContext? anchorContext = _directMenuAnchorKey.currentContext;
    if (anchorContext == null) {
      return;
    }
    final RenderBox anchor = anchorContext.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final Rect anchorRect = Rect.fromPoints(
      anchor.localToGlobal(Offset.zero, ancestor: overlay),
      anchor.localToGlobal(
        anchor.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
    );
    final CatalogPopupChoice? result = await one_ui
        .showMenu<CatalogPopupChoice>(
          context: context,
          position: RelativeRect.fromRect(
            anchorRect,
            Offset.zero & overlay.size,
          ),
          items: <PopupMenuEntry<CatalogPopupChoice>>[
            one_ui.OneUIPopupMenuItem<CatalogPopupChoice>(
              key: CatalogKeys.action('popup.direct.item'),
              value: CatalogPopupChoice.direct,
              child: const Text('Direct option'),
            ),
          ],
        );
    if (result != null && mounted) {
      _recordChoice(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CatalogScaffold(
      sectionId: CatalogSectionIds.popupMenus,
      title: 'Popup Menus',
      status: _status,
      children: <Widget>[
        const _DemoHeading('OneUIPopupMenuButton'),
        Align(
          child: one_ui.OneUIPopupMenuButton<CatalogPopupChoice>(
            key: CatalogKeys.widget(CatalogWidgetIds.popupMenuButton),
            tooltip: 'Open popup menu',
            onSelected: _recordChoice,
            onCanceled: () {
              setState(() {
                _status = 'Popup canceled';
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<CatalogPopupChoice>>[
                  one_ui.OneUIPopupMenuItem<CatalogPopupChoice>(
                    key: CatalogKeys.widget(CatalogWidgetIds.popupMenuItem),
                    value: CatalogPopupChoice.first,
                    child: const Text('First option'),
                  ),
                  const one_ui.OneUIPopupMenuItem<CatalogPopupChoice>(
                    value: CatalogPopupChoice.second,
                    child: Text('Second option'),
                  ),
                ],
            buttonBuilder:
                (
                  BuildContext context,
                  VoidCallback? onPressed,
                  bool enableFeedback,
                ) => one_ui.OneUIContainedButton(
                  onPressed: onPressed,
                  style: ButtonStyle(enableFeedback: enableFeedback),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Open popup'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
          ),
        ),
        const SizedBox(height: 20),
        const _DemoHeading('showMenu helper'),
        KeyedSubtree(
          key: CatalogKeys.action('popup.direct.open'),
          child: OutlinedButton.icon(
            key: _directMenuAnchorKey,
            onPressed: _showDirectMenu,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open direct menu'),
          ),
        ),
      ],
    );
  }
}

class SwitchesCatalogPage extends StatefulWidget {
  const SwitchesCatalogPage({super.key});

  @override
  State<SwitchesCatalogPage> createState() => _SwitchesCatalogPageState();
}

class _SwitchesCatalogPageState extends State<SwitchesCatalogPage> {
  bool _enabledValue = false;

  @override
  Widget build(BuildContext context) {
    return _CatalogScaffold(
      sectionId: CatalogSectionIds.switches,
      title: 'Switches',
      status: 'Enabled switch: ${_enabledValue ? 'on' : 'off'}',
      children: <Widget>[
        Semantics(
          label: 'Enabled One UI switch',
          child: ListTile(
            title: const Text('Enabled'),
            subtitle: const Text('Tap or drag to update the value.'),
            trailing: one_ui.OneUISwitch(
              key: CatalogKeys.widget(CatalogWidgetIds.switchControl),
              value: _enabledValue,
              onChanged: (bool value) {
                setState(() {
                  _enabledValue = value;
                });
              },
            ),
          ),
        ),
        const ListTile(
          title: Text('Disabled'),
          trailing: one_ui.OneUISwitch(value: false, onChanged: null),
        ),
      ],
    );
  }
}

class SlidersCatalogPage extends StatefulWidget {
  const SlidersCatalogPage({super.key});

  @override
  State<SlidersCatalogPage> createState() => _SlidersCatalogPageState();
}

class _SlidersCatalogPageState extends State<SlidersCatalogPage> {
  double _continuousValue = 0.25;
  double _discreteValue = 2;
  String _status = 'Ready';

  @override
  Widget build(BuildContext context) {
    return _CatalogScaffold(
      sectionId: CatalogSectionIds.sliders,
      title: 'Sliders',
      status: _status,
      children: <Widget>[
        const _DemoHeading('Continuous'),
        one_ui.OneUISlider(
          key: CatalogKeys.widget(CatalogWidgetIds.slider),
          value: _continuousValue,
          semanticFormatterCallback: (double value) =>
              '${(value * 100).round()} percent',
          onChangeStart: (_) {
            setState(() {
              _status = 'Continuous slider started';
            });
          },
          onChanged: (double value) {
            setState(() {
              _continuousValue = value;
              _status = 'Continuous: ${value.toStringAsFixed(2)}';
            });
          },
          onChangeEnd: (double value) {
            setState(() {
              _status = 'Continuous ended: ${value.toStringAsFixed(2)}';
            });
          },
        ),
        const _DemoHeading('Discrete'),
        one_ui.OneUISlider(
          key: CatalogKeys.action('slider.discrete'),
          value: _discreteValue,
          min: 0,
          max: 4,
          divisions: 4,
          label: _discreteValue.round().toString(),
          onChanged: (double value) {
            setState(() {
              _discreteValue = value;
              _status = 'Discrete: ${value.round()}';
            });
          },
        ),
        const _DemoHeading('Disabled'),
        const one_ui.OneUISlider(value: 0.5, onChanged: null),
      ],
    );
  }
}

class InkEffectsCatalogPage extends StatefulWidget {
  const InkEffectsCatalogPage({super.key});

  @override
  State<InkEffectsCatalogPage> createState() => _InkEffectsCatalogPageState();
}

class _InkEffectsCatalogPageState extends State<InkEffectsCatalogPage> {
  String _status = 'Ready';

  Widget _inkPreview({
    required String label,
    required String actionId,
    required InteractiveInkFeatureFactory splashFactory,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(splashFactory: splashFactory),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: CatalogKeys.action(actionId),
          onTap: () {
            setState(() {
              _status = '$label completed';
            });
          },
          child: SizedBox(height: 96, child: Center(child: Text(label))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CatalogScaffold(
      sectionId: CatalogSectionIds.inkEffects,
      title: 'Ink Effects',
      status: _status,
      children: <Widget>[
        _inkPreview(
          label: 'OneUIInkRipple',
          actionId: 'ink.ripple',
          splashFactory: one_ui.OneUIInkRipple.splashFactory,
        ),
        const SizedBox(height: 16),
        _inkPreview(
          label: 'OneUIInkSplash',
          actionId: 'ink.splash',
          splashFactory: one_ui.OneUIInkSplash.splashFactory,
        ),
      ],
    );
  }
}
