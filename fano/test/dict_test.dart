import 'dart:io';
import 'dart:typed_data';

import 'package:fano/src/select.dart';
import 'package:test/test.dart';
import 'package:fano/src/dict.dart';
import 'dart:convert';

import 'package:tuple/tuple.dart';

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
      test("Testing from", () {
        Object? e = from(tc.inp).item2;
        expect(e, null);
      });
      test('Testing SizeLValue and SizeT', () {
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

  group("Group Test Values", () {
    for (var i = 0; i < testCases.length; i++) {
      TestCase tc = testCases[i];
      Dict? d = from(tc.inp).item1;
      test("Testing Values", () {
        for (var j = 0; j < tc.inp.length; j++) {
          int want = tc.inp[j];
          int got = Value(j, d!).item1;

          expect(got, want);
        }
      });
    }
  });

  group("Group Test New/Append", () {
    for (var i = 0; i < testCases.length; i++) {
      TestCase tc = testCases[i];
      Dict? d = funcNew(tc.inp.length, tc.inp[tc.inp.length - 1]).item1;
      test("Testing funcNew", () {
        Object? e = funcNew(tc.inp.length, tc.inp[tc.inp.length - 1]).item2;
        expect(e, null);
      });
      test("Testing Append", () {
        for (var j = 0; j < tc.inp.length; j++) {
          int k = append(tc.inp[j], d);
          int want = tc.inp[j];
          int got = Value(j, d).item1;

          expect(k != -1, true);
          expect(got, want);
        }
      });
    }
  });

  group("Group test HValue", () {
    for (var i = 0; i < testCases.length; i++) {
      TestCase tc = testCases[i];
      Dict? d = from(tc.inp).item1;
      test("Testing HValue", () {
        for (var j = 0; j < tc.inp.length; j++) {
          int want = tc.inp[j] >> d!.sizeLValue;
          int got = hValue(j, d);

          expect(got, want);
        }
      });
    }
  });

  group("Group Test lValue", () {
    for (var i = 0; i < testCases.length; i++) {
      TestCase tc = testCases[i];
      Dict? d = from(tc.inp).item1;
      test("Testing lValue", () {
        for (var j = 0; j < tc.inp.length; j++) {
          int want = tc.inp[j] & ((1 << d!.sizeLValue) - 1);
          int got = lValue(j, d);

          expect(got, want);
        }
      });
    }
  });

  group("Group Test Values", () {
    for (var i = 0; i < testCases.length; i++) {
      TestCase tc = testCases[i];
      Dict? d = from(tc.inp).item1;
      test("Testing Values", () {
        for (var j = 0; j < values(d!).length; j++) {
          int want = tc.inp[j];
          int got = values(d)[j]; //Values(d)[j] don't work. Check the 8th case, for an unknown reason b just have 0 in it's array spaces
          //int got = values(from(tc.inp).item1!)[j]; //THIS IS REALLY WEIRD. This one is working but IT'S THE SAME!

          expect(got, want);
        }
      });
    }
  });
}

void fillTestCases(List testCases) {
  //1ST
  testCases.add(TestCase(Uint8List.fromList([0]), [int.parse("1", radix: 2)], 0, 1));
  //2ND
  testCases.add(TestCase(Uint8List.fromList([32]), [int.parse("0000010", radix: 2)], 5, 7));
  //3RD
  testCases.add(TestCase(Uint8List.fromList([2, 4, 8, 30, 32]), [int.parse("00100000101010000010101", radix: 2)], 2, 23));
  //4TH
  testCases.add(TestCase(Uint8List.fromList([5, 5, 5, 5, 5, 5, 5, 5, 5, 31]), [int.parse("11111111111000000000000011111111100", radix: 2)], 1, 35));
  //5TH
  testCases.add(TestCase(Uint8List.fromList([1, 4, 7, 18, 24, 26, 30, 31]), [int.parse("1000010111001010001000000101001", radix: 2)], 1, 31));
  //6TH
  testCases.add(TestCase(Uint8List.fromList([5, 8, 8, 15, 32]), [int.parse("00110000011000001011010", radix: 2)], 2, 23));
  //7TH
  testCases.add(TestCase(Uint8List.fromList([0, 8, 32]), [int.parse("0000000001000101", radix: 2)], 3, 16));
  //8TH
  testCases.add(TestCase(Uint8List.fromList([1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49]),
      [int.parse("0010010010010010010010010010010010010010010010010010010010010010", radix: 2), int.parse("1001001001", radix: 2)], 0, 74));
  //9TH
  testCases.add(TestCase(Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
      [int.parse("111111111111111111111111111111111111", radix: 2)], 0, 36));
  //10TH
  testCases.add(TestCase(Uint8List.fromList([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]),
      [int.parse("111111111111111111111111111111111110", radix: 2)], 0, 36));
  //11TH
  testCases.add(TestCase(Uint8List.fromList([3, 9, 130]), [int.parse("0001001001000111000011", radix: 2)], 5, 22));
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


