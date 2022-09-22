import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:fano/src/select.dart';
import 'package:test/test.dart';
import 'package:fano/src/Dict.dart';
import 'dart:convert';

import 'package:tuple/tuple.dart';
import 'package:xpx_chain_sdk/xpx_chain_sdk.dart';

class TestCase {
  //Uint8List inp = BytesBuilder().toBytes();
  //Uint8List out = BytesBuilder().toBytes();
  List<int> inp = [];
  List<int> out = [];
  int sizeLValue;
  int sizeT;
  TestCase(this.inp, this.out, this.sizeLValue, this.sizeT);
}

void main() {
  List testCases = [];
  //testCases.add(TestCase(List.from(int[0]), List.from([int"0b1"]), 0, 1));
  fillTestCases(testCases);

  group("Testing from method", () {
    for (var i = 0; i < testCases.length; i++) {
      TestCase tc = testCases[i];
      Dict? d = from(tc.inp).item1;

      test('Testing SizeLValue and SizeT', () {
        Object? e = from(tc.inp).item2;
        expect(e, null);

        int gotSizeLValue = d!.sizeLValue;
        int wantSizeLValue = tc.sizeLValue;
        int gotSizeT = d.sizeH + d.n * d.sizeLValue;
        int wantSizeT = tc.sizeT;

        expect(gotSizeLValue, wantSizeLValue);
        expect(gotSizeT, wantSizeT);
      });
      for (var j = 0; j < tc.out.length; j++) {
        test("Testing b array", () {
          final want = testCases[i].out[j];
          final got = d!.b[j];

          expect(got, want);
        });
      }
    }
  });

  test("Testing Value", () {
    for (var i = 0; i < testCases.length; i++) {
      TestCase tc = testCases[i];
      Dict? d = from(tc.inp).item1;
      for (var j = 0; j < tc.inp.length; j++) {
        int want = tc.inp[j];
        int got = Value(j, d!).item1;

        expect(got, want);
      }
    }
  });

  test("Testing Append", () {
    for (var i = 0; i < testCases.length; i++) {
      TestCase tc = testCases[i];
      Dict? d = funcNew(tc.inp.length, tc.inp[tc.inp.length - 1]).item1;
      Object? e = funcNew(tc.inp.length, tc.inp[tc.inp.length - 1]).item2;
      expect(e, null);

      for (var j = 0; j < tc.inp.length; j++) {
        int k = append(tc.inp[j], d);
        int want = tc.inp[j];
        int got = Value(j, d).item1;

        expect(k != -1, true);
        expect(got, want);
      }
    }
  });

  test("Testing HValue", () {
    for (var i = 0; i < testCases.length; i++) {
      TestCase tc = testCases[i];
      Dict? d = from(tc.inp).item1;
      for (var j = 0; j < tc.inp.length; j++) {
        int want = tc.inp[j] >> d!.sizeLValue;
        int got = hValue(j, d);

        expect(got, want);
      }
    }
  });

  test("Testing lValue", () {
    for (var i = 0; i < testCases.length; i++) {
      TestCase tc = testCases[i];
      Dict? d = from(tc.inp).item1;
      for (var j = 0; j < tc.inp.length; j++) {
        int want = tc.inp[j] & ((1 << d!.sizeLValue) - 1);
        int got = lValue(j, d);

        expect(got, want);
      }
    }
  });

  test("Testing Values", () {
    for (var i = 0; i < testCases.length; i++) {
      TestCase tc = testCases[i];
      Dict? d = from(tc.inp).item1;
      List<int> val = values(d!);
      //print("${values(d)}  ${val}");
      for (var j = 0; j < val.length; j++) {
        //print(values(d));
        print("${values(d)[j]}  ${val[j]}");
        int want = tc.inp[j];
        int got = val[j];
        //print(values(d)[j]);
        //int got = values(from(tc.inp).item1!)[j];

        expect(got, want);
      }
    }
  });

  group("Group Test Values Long", () {
    final n = 1000;
    final max = 100;
    final iterations = 1000;

    var a = List<int>.filled(n, 0, growable: true);
    var inp = List<int>.filled(n, 0, growable: true);

    for (var k = 0; k < iterations; k++) {
      inp = a.sublist(0, 1 + Random(18).nextInt(n));
      int prev = 0;

      for (var i = 0; i < inp.length; i++) {
        prev += Random(18).nextInt(max);
        inp[i] = prev;
      }
      test("From ${n}", () {
        Dict? d = from(inp).item1;
        List<int> val = values(d!);

        Object? e = from(inp).item2;
        expect(e, null);

        for (var i = 0; i < val.length; i++) {
          print("${values(d)[i]}  ${val[i]}");
          int want = inp[i];
          int got = val[i];

          expect(got, want);
        }
      });

      test("Append ${n}", () {
        Dict? d = funcNew(inp.length, inp[inp.length - 1]).item1;
        Object? e = funcNew(inp.length, inp[inp.length - 1]).item2;
        expect(e, null);

        List<int> val = values(d);

        for (var i = 0; i < inp.length; i++) {
          var v = inp[i];

          var j = append(v, d);

          expect(j != -1, true);
        }

        for (var i = 0; i < val.length; i++) {
          int want = inp[i];
          int got = val[i];

          expect(got, want);
        }
      });
    }
  });
}

void fillTestCases(List testCases) {
  //1ST
  testCases.add(TestCase([0], [int.parse("1", radix: 2)], 0, 1));
  //2ND
  testCases.add(TestCase([32], [int.parse("0000010", radix: 2)], 5, 7));
  //3RD
  testCases.add(TestCase([2, 4, 8, 30, 32], [int.parse("00100000101010000010101", radix: 2)], 2, 23));
  //4TH
  testCases.add(TestCase([5, 5, 5, 5, 5, 5, 5, 5, 5, 31], [int.parse("11111111111000000000000011111111100", radix: 2)], 1, 35));
  //5TH
  testCases.add(TestCase([1, 4, 7, 18, 24, 26, 30, 31], [int.parse("1000010111001010001000000101001", radix: 2)], 1, 31));
  //6TH
  testCases.add(TestCase([5, 8, 8, 15, 32], [int.parse("00110000011000001011010", radix: 2)], 2, 23));
  //7TH
  testCases.add(TestCase([0, 8, 32], [int.parse("0000000001000101", radix: 2)], 3, 16));
  //8TH
  testCases.add(TestCase([1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49],
      [int.parse("0010010010010010010010010010010010010010010010010010010010010010", radix: 2), int.parse("1001001001", radix: 2)], 0, 74));
  //9TH
  testCases.add(TestCase([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [int.parse("111111111111111111111111111111111111", radix: 2)], 0, 36));
  //10TH
  testCases.add(TestCase([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [int.parse("111111111111111111111111111111111110", radix: 2)], 0, 36));
  //11TH
  testCases.add(TestCase([3, 9, 130], [int.parse("0001001001000111000011", radix: 2)], 5, 22));
  //12TH
  testCases.add(TestCase([6, 7, 10], [int.parse("01010011000", radix: 2)], 1, 11));
  //13TH
  testCases.add(TestCase([1, 4, 7, 18, 24, 26, 30, 31], [int.parse("1000010111001010001000000101001", radix: 2)], 1, 31));
  //14TH
  testCases.add(TestCase([5, 8, 8, 15, 32], [int.parse("00110000011000001011010", radix: 2)], 2, 23));
  //15TH
  testCases.add(TestCase([5, 8, 9, 10, 14, 32], [int.parse("00101001000110000010111010", radix: 2)], 2, 26));
  //16TH
  testCases
      .add(TestCase([3, 4, 7, 13, 14, 15, 21, 25, 36, 38, 54, 62], [int.parse("101010000101111001110011100100001100010100111001101", radix: 2)], 2, 51));
  //17TH
  testCases.add(TestCase([2, 3, 5, 7, 11, 13, 24], [int.parse("01111101000000101001010110", radix: 2)], 1, 26));
  //18TH
  testCases.add(TestCase([4, 5, 6, 13, 22, 25], [int.parse("011001100100101001001110", radix: 2)], 2, 24));
  //19TH
  testCases.add(TestCase([3, 4, 7, 13, 14, 15, 21, 43], [int.parse("1101111001110011100000100111001101", radix: 2)], 2, 34));
  //20TH
  testCases.add(TestCase([3, 4, 13, 15, 24, 26, 27, 29], [int.parse("110011011011010000010100001010", radix: 2)], 1, 30));
  //21TH
  testCases.add(TestCase([8, 9, 11, 13, 16, 18, 23], [int.parse("1001110100101001010110000", radix: 2)], 1, 25));
  //22TH
  testCases.add(TestCase([4, 13, 15, 24, 26, 27, 29], [int.parse("0111100011010010111000110010", radix: 2)], 2, 28));
}


/*
main() {
  var values = [2, 4, 8, 34, 32];
  from(values);
  print("Done");
}
*/


//Testcases for Uint8List
  /*
  testCases.add(TestCase(Uint8List.fromList([0]), Uint8List.fromList([int.parse("1", radix: 2)]), 0, 1));
  testCases.add(TestCase(Uint8List.fromList([32]), Uint8List.fromList([int.parse("0000010", radix: 2)]), 5, 7));
  testCases.add(TestCase(Uint8List.fromList([2, 4, 8, 30, 32]), Uint8List.fromList([int.parse("00100000101010000010101", radix: 2)]), 2, 23));
  testCases.add(TestCase(
      Uint8List.fromList([5, 5, 5, 5, 5, 5, 5, 5, 5, 31]), Uint8List.fromList([int.parse("11111111111000000000000011111111100", radix: 2)]), 1, 35));
  testCases.add(
      TestCase(Uint8List.fromList([1, 4, 7, 18, 24, 26, 30, 31]), Uint8List.fromList([int.parse("1000010111001010001000000101001", radix: 2)]), 1, 31));
  testCases.add(TestCase(Uint8List.fromList([5, 8, 8, 15, 32]), Uint8List.fromList([int.parse("00110000011000001011010", radix: 2)]), 2, 23));
  testCases.add(TestCase(Uint8List.fromList([0, 8, 32]), Uint8List.fromList([int.parse("0000000001000101", radix: 2)]), 3, 16));

  testCases.add(TestCase(
      Uint8List.fromList([1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49]),
      Uint8List.fromList([int.parse("0010010010010010010010010010010010010010010010010010010010010010", radix: 2), int.parse("1001001001", radix: 2)]),
      0,
      74));

  testCases.add(TestCase(Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
      Uint8List.fromList([int.parse("111111111111111111111111111111111111", radix: 2)]), 0, 36));

  testCases.add(TestCase(Uint8List.fromList([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
      Uint8List.fromList([int.parse("111111111111111111111111111111111110", radix: 2)]), 0, 36));

  testCases.add(TestCase(Uint8List.fromList([3, 9, 130]), Uint8List.fromList([int.parse("0001001001000111000011", radix: 2)]), 5, 22));
  */


