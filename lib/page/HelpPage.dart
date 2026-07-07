import 'package:bc_ui_flutter/model/AppColors.dart';
import 'package:bc_ui_flutter/widget/CustomPageBackground.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  HelpPage();

  @override
  _HelpPage createState() => _HelpPage();
}

class _HelpPage extends State<HelpPage> {
  List<HelpItem> items = [
    HelpItem(
        'Bluetooth connection',
        'At first you have to enable Bluetooth in your mobile phone and then '
            'connect to prepared Raspberry Pi. After connection you will be '
            'redirected on a pedalboard of GuitarPi application.',
        null),
    HelpItem(
        'Pedalboard screen',
        'If you want to see more effects on the pedalboard at the same time '
            'just turn around your mobile device (switch to the landscape view).',
        Image.asset('assets/helpImages/pedalboardHorizontal.PNG')),
    HelpItem(
        'ON/OFF switching',
        'On the pedalboard are two types of things to switch ON/OFF.\n'
            'The first is the pedalboard itself. You can do it by clicking on '
            'a red/green button in right-top corner of the pedalboard.\n'
            'Second type of things that can be switched are effects. It can be '
            'done by clicking on a big black button in bottom of each effect.\n'
            '\n'
            'Audio is send to output only if the pedalboard is ON.',
        null),
    HelpItem('Effects parameters',
        'The most common parameter is the Level, which defines the effect\'s intensity and volume\n'
            '\n'
        'Delay & Echo\n'
            '-> Time parameter sets the delay in the interval 0 to 1 second.\n'
            '\n'
        'Reverb\n'
            '-> Time parameter sets the delay of reverberation in the interval roughly 0.3 to 0.6 second.\n'
        '-> Wet parameter sets the ratio of direct sound to reverberation.\n',
        null),
    HelpItem(
        'Presets',
        'If you are satisfied with current effect setting you can save it as a '
            'new preset and use it in the future. Just click on a Save icon in '
            'the middle of each effect and named it.',
        null),
    HelpItem(
        'Effect ordering',
        'Current application version contains only '
            'effects from last 3 groups. So, in this case ordering is Fuzz '
            '-> Overdrive -> Distortion -> Delay -> Echo -> Reverb',
        Image.asset('assets/helpImages/effectChain.jpg')),
  ];

  late int expandedWidgetIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Usage',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        actions: const [],
      ),
      body: Stack(
        children: [
          const CustomPageBackground(),
          SingleChildScrollView(
            child: ExpansionPanelList.radio(
              expansionCallback: (index, isExpanded) {
                setState(() {
                  expandedWidgetIndex = index;
                  items[index].isExpanded = !isExpanded;
                });
              },
              children: items
                  .map((item) => ExpansionPanelRadio(
                        value: item.name,
                        canTapOnHeader: true,
                        headerBuilder: (context, isExpanded) =>
                            buildPresetHeader(item),
                        body: buildHelpItem(item),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPresetHeader(HelpItem item) {
    return ListTile(
      title: Text(
        item.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildHelpItem(HelpItem item) {
    return Column(
      children: [
        const Divider(
          height: 1,
          thickness: 1,
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: ListTile(
                title: Text(
                  item.textContent,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Container(
              child: item.image,
            )
          ],
        ),
      ],
    );
  }
}

class HelpItem {
  String name, textContent;
  bool isExpanded = false;
  Image? image;

  HelpItem(this.name, this.textContent, this.image);
}
