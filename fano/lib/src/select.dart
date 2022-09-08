import 'dart:typed_data';

import 'package:fano/fano.dart';
import 'package:xpx_chain_sdk/xpx_chain_sdk.dart';

int hValue(int i, Dict d) {
  int nOnes = i;

  for (j = 0; j < d.b.length; j++) {
    int ones = d.b.bitCount();
    if ((i - ones) < 0) {}
  }
}

int select64(int x0, k int) {
  int x1 = (x0 & 0x5555555555555555) + (x0 >> 1 & 0x5555555555555555);
  int x2 = (x1 & 0x3333333333333333) + (x1 >> 2 & 0x3333333333333333);
  int x3 = (x2 & 0x0F0F0F0F0F0F0F0F) + (x2 >> 4 & 0x0F0F0F0F0F0F0F0F);
  int x4 = (x3 & 0x00FF00FF00FF00FF) + (x3 >> 8 & 0x00FF00FF00FF00FF);
  int x5 = (x4 & 0x0000FFFF0000FFFF) + (x4 >> 16 & 0x0000FFFF0000FFFF);
}
