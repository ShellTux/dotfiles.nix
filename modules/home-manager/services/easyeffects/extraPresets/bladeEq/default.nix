{ ... }:
{
  services.easyeffects.extraPresets.bladeEq = {
    output = {
      blocklist = [ ];
      plugins_order = [
        "loudness#0"
        "equalizer#0"
        "bass_enhancer#0"
        "autogain#0"
        "limiter#0"
      ];
      "loudness#0" = {
        bypass = false;
        clipping = false;
        clipping-range = 6.0;
        fft = "4096";
        input-gain = 0.0;
        output-gain = 0.0;
        std = "ISO226-2003";
        volume = -2.0;
      };
      "equalizer#0" = {
        balance = 0.0;
        bypass = false;
        input-gain = 0.0;
        left = {
          band0 = {
            frequency = 250.0;
            gain = 6.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.504760237537245;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band1 = {
            frequency = 500.0;
            gain = -8.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.5047602375372453;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band2 = {
            frequency = 1000.0;
            gain = -2.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.5;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band3 = {
            frequency = 2000.0;
            gain = 0.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.504760237537245;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band4 = {
            frequency = 4000.0;
            gain = 3.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.5047602375372453;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band5 = {
            frequency = 8000.0;
            gain = 3.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.504760237537245;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band6 = {
            frequency = 16000.0;
            gain = 4.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.5047602375372449;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
        };
        mode = "IIR";
        num-bands = 7;
        output-gain = 0.0;
        pitch-left = 0.0;
        pitch-right = 0.0;
        right = {
          band0 = {
            frequency = 250.0;
            gain = 6.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.504760237537245;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band1 = {
            frequency = 500.0;
            gain = -8.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.5047602375372453;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band2 = {
            frequency = 1000.0;
            gain = -2.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.5;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band3 = {
            frequency = 2000.0;
            gain = 0.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.504760237537245;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band4 = {
            frequency = 4000.0;
            gain = 3.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.5047602375372453;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band5 = {
            frequency = 8000.0;
            gain = 3.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.504760237537245;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
          band6 = {
            frequency = 16000.0;
            gain = 4.0;
            mode = "RLC (BT)";
            mute = false;
            q = 1.5047602375372449;
            slope = "x1";
            solo = false;
            type = "Bell";
            width = 4.0;
          };
        };
        split-channels = false;
      };
      "bass_enhancer#0" = {
        amount = 1.5;
        blend = -2.0;
        bypass = false;
        floor = 20.0;
        floor-active = false;
        harmonics = 2.0;
        input-gain = 0.0;
        output-gain = 0.0;
        scope = 100.0;
      };
      "autogain#0" = {
        bypass = false;
        input-gain = 0.0;
        maximum-history = 15;
        output-gain = 0.0;
        reference = "Geometric Mean (MSI)";
        silence-threshold = -70.0;
        target = -10.0;
      };
      "limiter#0" = {
        alr = false;
        alr-attack = 5.0;
        alr-knee = 0.0;
        alr-release = 50.0;
        attack = 5.0;
        bypass = false;
        dithering = "None";
        external-sidechain = false;
        gain-boost = true;
        input-gain = 0.0;
        lookahead = 5.0;
        mode = "Herm Thin";
        output-gain = 0.0;
        oversampling = "None";
        release = 5.0;
        sidechain-preamp = -1.5;
        stereo-link = 100.0;
        threshold = -3.0;
      };
    };
  };
}
