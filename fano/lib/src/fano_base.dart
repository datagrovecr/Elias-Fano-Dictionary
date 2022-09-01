// TODO: Put public facing types in this file.

import 'dart:js_util';

/// Checks if you are awesome. Spoiler: you are.
//class Awesome {
// bool get isAwesome => true;
//}

class Dict {
  List<int>? b;
  int? sizeLValue;
  int? sizeH;
  int? n;
  int? lMask;
  int? maxValue;
  int? pValue;
  int? cap;
}

//

Dict New(int cap, int maxValue) {
  print("doing it");

  try {
    if (cap == 0) {
      throw new Exception(
          "ef: dictionary does not support an empty values list");
    }
  } catch (e) {
    print(e);
    return Dict();
  }

  int sizeLVal = max0(((maxValue / cap) - 1)
      .toInt()
      .bitLength); //Returns the minimum number of bits required to store this integer.
  int sizeH = cap + (maxValue >> sizeLVal); //Need to see if this works.

  final dict = Dict();
  dict.b = <int>[];
  dict.sizeLValue = sizeLVal;
  dict.sizeH = sizeH;
  dict.lMask = 1 << sizeLVal - 1;
  dict.maxValue = maxValue;
  dict.cap = cap;

  return Dict();
}

int max0(int x) {
  if (x <= 0) {
    return 0;
  }
  return x;
}

int? Len(Dict d) {
  //Need to check how Len works.
  return d.n;
}

Dict? From(var values) {
  try {
    if (values.empty) {
      throw new Exception(
          "ef: dictionary does not support an empty values list");
    }
  } catch (e) {
    print(e);
    return null;
  }

  Dict d = New(values.length, values[values.length - 1]);

  return null; //missing build
}

Dict? build(var values, Dict d) {
  int vmin = 0;

  int? offset = d.sizeH;

  for (var i = 0; i < values.length; i++) {
    try {
      if (values[i] < vmin) {
        throw new Exception(
            "ef: dictionary requires an array that increases monotonically");
      }
    } catch (e) {
      print(e);
      return null;
    }
    vmin = values[i];

    int? hValue = (values[i] >> d.sizeLValue) + i.toInt();

    d.b[offset >> 6] |
        1 <<
            (hValue &
                63); //Problem here, need to know how to fix that keeping it nullable.
    if (d.sizeLValue == 0) {
      continue;
    }

    int? lValue = values[i] & d.lMask;
    d.b[offset >> 6] |
        lValue <<
            (offset &
                63); //Problem here, need to know how to fix that keeping it nullable.
  }
}
