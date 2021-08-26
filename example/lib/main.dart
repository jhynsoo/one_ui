import 'package:flutter/material.dart';
import 'package:one_ui/one_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'One UI Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOption = [
      OneUIView(
        title: const Text('One UI Examples'),
        actions: [
          OneUIPopupMenuButton(
            itemBuilder: (context) => <PopupMenuEntry>[
              const OneUIPopupMenuItem(child: Text('Option 1')),
              const OneUIPopupMenuItem(child: Text('Option 2')),
              const OneUIPopupMenuItem(child: Text('Option 3')),
            ],
          ),
        ],
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ButtonPage(),
                    ),
                  ),
                  title: const Text('Buttons'),
                ),
                ListTile(
                  onTap: () => showOneUIDialog(
                    context: context,
                    builder: (context) {
                      return OneUIAlertDialog(
                        title: const Text("title"),
                        content: const Text("This is a demo alert dialog."),
                        actions: [
                          OneUIDialogAction(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                          OneUIDialogAction(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Accept")),
                        ],
                      );
                    },
                  ),
                  title: const Text('Dialog'),
                ),
                ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SwitchPage(),
                    ),
                  ),
                  title: const Text('Switches'),
                ),
                ListTile(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SliderPage(),
                    ),
                  ),
                  title: const Text('Sliders'),
                ),
              ],
            ),
          ),
        ],
      ),
      const Center(child: Text('Second Page')),
    ];

    return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOption,
        ),
        bottomNavigationBar: OneUIBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (value) {
            setState(() {
              _selectedIndex = value;
            });
          },
          items: const [
            OneUIBottomNavigationBarItem(label: "Home"),
            OneUIBottomNavigationBarItem(label: "More"),
          ],
        ));
  }
}

class ButtonPage extends StatelessWidget {
  const ButtonPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OneUIView(
        title: const Text('Buttons'),
        slivers: [
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OneUIContainedButton(
                  onPressed: () {},
                  child: const Text('Contained button'),
                ),
                OneUIFlatButton(
                  onPressed: () {},
                  child: const Text('Flat button'),
                ),
                OneUIIconButton(
                  onPressed: () {},
                  splashRadius: 24,
                  icon: const Icon(Icons.home),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SwitchPage extends StatefulWidget {
  const SwitchPage({Key? key}) : super(key: key);

  @override
  _SwitchPageState createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OneUIView(
        title: const Text('Switches'),
        slivers: [
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Enabled'),
                    OneUISwitch(
                      value: _value,
                      onChanged: (value) {
                        setState(() {
                          _value = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Disabled'),
                    OneUISwitch(
                      value: _value,
                      onChanged: null,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SliderPage extends StatefulWidget {
  const SliderPage({Key? key}) : super(key: key);

  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  double _value1 = .0;
  double _value2 = .0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OneUIView(
        title: const Text('Sliders'),
        slivers: [
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OneUISlider(
                  value: _value1,
                  onChanged: (value) {
                    setState(() {
                      _value1 = value;
                    });
                  },
                ),
                const Text('Continuous'),
                const SizedBox(height: 50),
                OneUISlider(
                  value: _value2,
                  divisions: 3,
                  onChanged: (value) {
                    setState(() {
                      _value2 = value;
                    });
                  },
                ),
                const Text('Discrete'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
