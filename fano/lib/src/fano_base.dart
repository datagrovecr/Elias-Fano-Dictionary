// TODO: Put public facing types in this file.

import 'dart:html';
import 'dart:io';
import 'dart:js_util';

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
Dict New(int cap, int maxValue) {
  print("doing it");

  try {
    if (cap == 0) {
      throw Exception("ef: dictionary does not support an empty values list");
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

// max0 returns the maximum of x and 0.
int max0(int x) {
  if (x <= 0) {
    return 0;
  }
  return x;
}

// Len returns the current number of entries in the dictionary.
// When the dictionary is built with From, Len and Cap always
// return the same result.
int Len(Dict d) {
  //Need to check how Len works.
  return d.n;
}

// From constructs a dictionary from a list of values.
Dict? From(var values) {
  try {
    if (values.empty) {
      throw Exception("ef: dictionary does not support an empty values list");
    }
  } catch (e) {
    print(e);
    return null;
  }

  Dict d = New(values.length, values[values.length - 1]);

  return null; //missing build
}

// build encodes a monotone increasing array of positive integers
// into an Elias-Fano bit sequence. build will return an error
// when the values are not increasing monotonically.
Dict? build(var values, Dict d) {
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
      return null;
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
}

// Append appends a value to the dictionary and returns the key. If something
// goes wrong, Append returns -1. In that case, no value is added.
int Append(int value, Dict d) {// TODO: Return vervangen door error. Definieer een err var voor elk soort error.

  // check values
  if(d.n != 0 && (d.cap <= d.n || value < d.pValue || d.maxValue < value)){
    return -1;
  }
  d.pValue = value;
  d.n++;

  // higher bits processing
  int hValue = value>>d.sizeLValue + (d.n-1).toInt();
  d.b[hValue>>6] |= 1 << (hValue & 63)
  if(d.sizeLValue == 0){
    return d.n - 1;
  }

  // lower bits processing
  int lValue = value & d.lMask;
  int offset = d.sizeH + (d.n-1)*d.sizeLValue;
  d.b[offset>>6] |= lValue << (offset & 63);
  int msb = lValue >> (64 - offset & 63);
  if(msb != 0){
    d.b[offset>>6+1] = msb;
  }
  return d.n - 1;
}

// Cap returns the maximum number of entries in the dictionary.
int Cap(Dict d){
  return d.cap;
}
