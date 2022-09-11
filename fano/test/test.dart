import 'package:test/test.dart';

class TestCase {
  var input = List<int>;
  var out = List<int>;
  int sizeLValue;
  int sizeT;
  TestCase(this.input, this.out, this.sizeLValue, this.sizeT);
}

void main() {
  List testCases = [];
  testCases.add(TestCase(List.from([0]) , List.from([0b1]), 0, 1));
  for (TestCase in testCases){
     
  }
}
