// TODO: Put public facing types in this file.

import 'dart:ffi';
import 'dart:html';
import 'dart:io';
import 'dart:js_util';
import 'dart:typed_data';
import 'package:xpx_chain_sdk/xpx_chain_sdk.dart';
import 'package:fano/src/select.dart';
import 'package:tuple/tuple.dart';

/// Checks if you are awesome. Spoiler: you are.
//class Awesome {
// bool get isAwesome => true;
//}

class Dict {
  List<int> b = []; // Elias-Fano representation of the bit sequence
  int sizeLValue = 0; // bit length of a lValue
  int sizeH = 0; // bit length of the higher bits array H
  int n = 0; // number of entries in the dictionary
  int lMask = 0; // mask to isolate lValue
  int maxValue = 0; // universe of the Elias-Fano algorithm
  int pValue = 0; // previously added value: helper value to check monotonicity
  int cap = 0; // number of entries that can be stored in the dictionary
}

// New constructs a dictionary with a capacity of n entries. The dictionary
// can accept positive numbers, smaller than or equal to maxValue. The values
// needed to be in monotonic, non-decreasing way.
Tuple2<Dict, Object?> funcNew(int cap, int maxValue) {
  print("doing it");

  try {
    if (cap == 0) {
      throw Exception("ef: dictionary does not support an empty values list");
    }
  } catch (e) {
    print(e);
    return Tuple2(Dict(), e);
  }

  int sizeLVal = max0(((maxValue / cap) - 1)
      .toInt()
      .bitLength); //Returns the minimum number of bits required to store this integer.
  int sizeH = cap + (maxValue >> sizeLVal).toInt(); //Need to see if this works.

  final dict = Dict();
  dict.b = <int>[];
  dict.sizeLValue = sizeLVal;
  dict.sizeH = sizeH;
  dict.lMask = 1 << sizeLVal - 1;
  dict.maxValue = maxValue;
  dict.cap = cap;

  return Tuple2(Dict(), null);
}

// From constructs a dictionary from a list of values.
Tuple2<Dict?, Object?> from(var values) {
  try {
    if (values.empty) {
      throw Exception("ef: dictionary does not support an empty values list");
    }
  } catch (e) {
    print(e);
    return Tuple2(null, e);
  }
  try {
    Dict d = funcNew(values.length, values[values.length - 1]).item1;
    return Tuple2(build(values, d).item1, null);
  } catch (e) {
    print(e);
    return Tuple2(null, e);
  }
}

// Append appends a value to the dictionary and returns the key. If something
// goes wrong, Append returns -1. In that case, no value is added.
int append(int value, Dict d) {
  // TODO: Return vervangen door error. Definieer een err var voor elk soort error.

  // check values
  if (d.n != 0 && (d.cap <= d.n || value < d.pValue || d.maxValue < value)) {
    return -1;
  }
  d.pValue = value;
  d.n++;

  // higher bits processing
  int hValue = value >> d.sizeLValue + (d.n - 1).toInt();
  d.b[hValue >> 6] |= 1 << (hValue & 63);
  if (d.sizeLValue == 0) {
    return d.n - 1;
  }

  // lower bits processing
  int lValue = value & d.lMask;
  int offset = d.sizeH + (d.n - 1) * d.sizeLValue;
  d.b[offset >> 6] |= lValue << (offset & 63);
  int msb = lValue >> (64 - offset & 63);
  if (msb != 0) {
    d.b[offset >> 6 + 1] = msb;
  }
  return d.n - 1;
}

// Cap returns the maximum number of entries in the dictionary.
int cap(Dict d) {
  return d.cap;
}

// Len returns the current number of entries in the dictionary.
// When the dictionary is built with From, Len and Cap always
// return the same result.
int len(Dict d) {
  return d.n;
}

// build encodes a monotone increasing array of positive integers
// into an Elias-Fano bit sequence. build will return an error
// when the values are not increasing monotonically.
Tuple2<Dict?, Object?> build(var values, Dict d) {
  int vmin = 0;

  int offset = d.sizeH;

  for (var i = 0; i < values.length; i++) {
    try {
      if (values[i] < vmin) {
        throw Exception(
            "ef: dictionary requires an array that increases monotonically");
      }
    } catch (e) {
      print(e);
      return Tuple2(null, e);
    }
    vmin = values[i];

    //higher bits processing
    int hValue = (values[i] >> d.sizeLValue) + i.toInt();
    d.b[offset >> 6] |= 1 << (hValue & 63);
    if (d.sizeLValue == 0) {
      continue;
    }

    //lower bits processing
    int lValue = values[i] & d.lMask;
    d.b[offset >> 6] |= lValue << (offset & 63);
    int msb = lValue >> (64 - offset & 63);
    if (msb != 0) {
      d.b[offset >> 6 + 1] = msb;
    }
    offset += d.sizeLValue;
  }

  d.n = values.length;

  return Tuple2(d, null);
}

// max0 returns the maximum of x and 0.
int max0(int x) {
  if (x <= 0) {
    return 0;
  }
  return x;
}

// Value returns the k-th value in the dictionary.
Tuple2<int, bool> value(int k, Dict d) {
  if (k < 0 || d.n <= k) {
    return Tuple2(0, false);
  }
  return Tuple2(hValue(k, d) << d.sizeLValue | lValue(k, d), true);
}

// Value2 returns the k-th value in the dictionary.
Tuple2<int, bool> value2(int k, Dict d) {
  if (k < 0 || d.n <= k) {
    return Tuple2(0, false);
  }
  return Tuple2((select1(k, d) - k) << d.sizeLValue | lValue(k, d), true);
}

// Values reads all numbers from the dictionary.
List<int> values(Dict d) {
  List<int> values = [];
  int k = 0;

  if (d.sizeLValue == 0) {
    for (var j = 0; j < d.b.length; j++) {
      int p64 = j << 6;
      while (d.b[j] != 0) {
        values[k] = p64 +
            d.b[j]
                .toRadixString(2)
                .split('')
                .reversed
                .takeWhile((e) => e == '0')
                .length -
            k;
        d.b[j] &= d.b[j] - 1;
        k++;
      }
    }
    return values;
  }
  List<int> a = d.b.sublist(0, ((d.sizeH + 63) >> 63));
  int lValFilter = d.sizeH;

  for (var j = 0; j < a.length; j++) {
    a[j] &= 1 << lValFilter - 1;
    int p64 = j << 6;
    while (a[j] != 0) {
      int hValue = p64 +
          a[j]
              .toRadixString(2)
              .split('')
              .reversed
              .takeWhile((e) => e == '0')
              .length -
          k;
      values[k] = hValue << d.sizeLValue | lValue(k, d);
      a[j] &= a[j] - 1;
      k++;
    }
    lValFilter -= 64;
  }
  return values;
}

int hValue2(int k, Dict d) {
  return select1(k, d) - k;
}

// hValue2 returns the higher bits (bucket value) of the k-th value.
int lValue(int k, Dict d) {
  int offset = d.sizeH + k * d.sizeLValue;
  int off63 = offset & 63;
  int val = d.b[offset >> 6] >> off63 & d.lMask;

  if (off63 + d.sizeLValue > 64) {
    val |= d.b[offset >> 6 + 1] << (64 - off63) & d.lMask;
  }
  return val;
}

// NextGEQ returns the first value in the dictionary equal to or larger than
// the given value. NextGEQ fails when there exists no value larger than or
// equal to value. If so, it returns -1 as index.
Tuple2<int, int> nextGEQ(int value, Dict d) {
  if (d.maxValue < value) {
    return Tuple2(-1, d.maxValue);
  }

  int hValue = (value >> d.sizeLValue).toInt();
  // pos denotes the end of bucket hValue-1
  int pos = select0(hValue, d);
  // k is the number of integers whose high bits are less than hValue.
  // So, k is the key of the first value we need to compare to.
  int k = pos - hValue;
  int pos63 = pos & 63;
  int pos64 = pos & ~63;

  int buf = d.b[pos64 >> 6] & ~(1 << pos63 - 1);
  // This does not mean that the p+1-th value is larger than or equal to value!
  // The p+1-th value has either the same hValue or a larger one. In case of a
  // larger hValue, this value is the result we are seeking for. In case the
  // hValue is identical, we need to scan the bucket to be sure that our value
  // is larger. We can do this with select1, combined with search or scanning.
  // We can also do this with scanning without select1. Most probably the
  // fastest way for regular cases.

  // scan potential solutions
  int templValue = value & d.lMask;

  while (true) {
    while (buf == 0) {
      pos64 += 64;
      buf = d.b[pos64 >> 6];
    }

    pos63 = buf
        .toRadixString(2)
        .split('')
        .reversed
        .takeWhile((e) => e == '0')
        .length;

    // check potential solution
    int hVal = pos64 + pos63 - k;

    if (hValue < hVal || templValue <= lValue(k, d)) {
      break;
    }

    buf &= buf - 1;
    k++;
  }
  return Tuple2(k, (pos64 + pos63 - k) << d.sizeLValue | lValue(k, d));
}
