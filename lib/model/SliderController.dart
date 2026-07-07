import 'package:bc_ui_flutter/model/Effect.dart';

class SliderController {

  // non-linear
  static double distortionLevel = 0;
  static double fuzzLevel = 0;
  static double fuzzFuzz = 0;
  static double overdriveLevel = 0;

  // echo
  static double echoLevel = 0;
  static double echoTime = 0;

  // delay
  static double delayLevel = 0;
  static double delayTime = 0;

  // reverb
  static double reverbTime = 0;
  static double reverbWet = 0;
  static double reverbFB = 0;

  double getSliderValueByParameterName(String name) {
    switch (name) {
      case Effect.DISTORTION_LEVEL:
        return SliderController.distortionLevel;
      case Effect.FUZZ_LEVEL:
        return SliderController.fuzzLevel;
      case Effect.FUZZ_FUZZ:
        return SliderController.fuzzFuzz;
      case Effect.OVERDRIVE_LEVEL:
        return SliderController.overdriveLevel;

      case Effect.ECHO_LEVEL:
        return SliderController.echoLevel;
      case Effect.ECHO_TIME:
        return SliderController.echoTime;

      case Effect.DELAY_LEVEL:
        return SliderController.delayLevel;
      case Effect.DELAY_TIME:
        return SliderController.delayTime;

      case Effect.REVERB_TIME:
        return SliderController.reverbTime;
      case Effect.REVERB_WET:
        return SliderController.reverbWet;
      case Effect.REVERB_FB:
        return SliderController.reverbFB;
    }
    return 0;
  }

  void setSliderValueByParameterName(String name, double value) {
    switch (name) {
      case Effect.DISTORTION_LEVEL:
        SliderController.distortionLevel = value;
        break;
      case Effect.FUZZ_LEVEL:
        SliderController.fuzzLevel = value;
        break;
      case Effect.FUZZ_FUZZ:
        SliderController.fuzzFuzz = value;
        break;
      case Effect.OVERDRIVE_LEVEL:
        SliderController.overdriveLevel = value;
        break;

      case Effect.ECHO_LEVEL:
        SliderController.echoLevel = value;
        break;
      case Effect.ECHO_TIME:
        SliderController.echoTime = value;
        break;

      case Effect.DELAY_LEVEL:
        SliderController.delayLevel = value;
        break;
      case Effect.DELAY_TIME:
        SliderController.delayTime = value;
        break;

      case Effect.REVERB_TIME:
        SliderController.reverbTime = value;
        break;
      case Effect.REVERB_WET:
        SliderController.reverbWet = value;
        break;
      case Effect.REVERB_FB:
        SliderController.reverbFB = value;
        break;
    }
  }
}
