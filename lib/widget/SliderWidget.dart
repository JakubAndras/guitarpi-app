import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/widget/CustomSliderThumbCircle.dart';

import '../model/SliderController.dart';

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  final int min;
  final int max;
  double currentValue;
  final String name;
  final String parentName;
  final Color color;

  final Function updateLevelValue;
  final Function setCurrentPresetToNull;
  final Function sendData;

  SliderWidget({
    required Key key,
    required this.sliderHeight,
    this.max = 100,
    this.min = 0,
    required this.name,
    required this.updateLevelValue,
    required this.setCurrentPresetToNull,
    required this.sendData,
    required this.currentValue,
    required this.parentName,
    required this.color,
  }) : super(key: key);

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget>
    with AutomaticKeepAliveClientMixin {
  late double _currentValue;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _currentValue = widget.currentValue;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(SliderWidget oldWidget) {
    _currentValue = SliderController().getSliderValueByParameterName(widget.parentName);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double paddingFactor = .25;

    return Container(
      width: (widget.sliderHeight) * 7.9,
      height: (widget.sliderHeight) * 1.1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular((widget.sliderHeight * .3)),
        ),
        gradient: LinearGradient(
            colors: [
              widget.color,
              Colors.white,
            ],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 9.0),
            stops: [0.1, 1],
            tileMode: TileMode.clamp),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(widget.sliderHeight * paddingFactor, 2,
            widget.sliderHeight * paddingFactor, 2),
        child: Row(
          children: <Widget>[
            Container(
              width: 66,
              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
              child: Text(
                widget.name,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: widget.sliderHeight * .45,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white.withOpacity(1),
                    inactiveTrackColor: Colors.white.withOpacity(.5),

                    trackHeight: 4.0,
                    thumbShape: CustomSliderThumbCircle(
                      thumbRadius: widget.sliderHeight * .4,
                      min: widget.min,
                      max: widget.max,
                      color: widget.color,
                    ),
                    overlayColor: Colors.white.withOpacity(.4),
                    activeTickMarkColor: Colors.white,
                    inactiveTickMarkColor: Colors.red.withOpacity(.7),
                  ),
                  child: Slider(
                    value: _currentValue,
                    divisions: 100,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      setState(() {
                        _currentValue = value;
                      });
                    },
                    onChangeStart: (value) {},
                    onChangeEnd: (value) {
                      setState(() {
                        _currentValue = value;

                        widget.setCurrentPresetToNull();

                        widget.updateLevelValue(widget.name, (_currentValue).toInt());
                        SliderController().setSliderValueByParameterName(
                            widget.parentName, _currentValue);

                        widget.sendData();
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
