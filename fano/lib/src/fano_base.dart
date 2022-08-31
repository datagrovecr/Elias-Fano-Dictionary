// TODO: Put public facing types in this file.

/// Checks if you are awesome. Spoiler: you are.
//class Awesome {
 // bool get isAwesome => true;
//}

class Dict {
  List<int> b;
  int sizeLValue;
  int sizeH;
  int n;
  int lMask;
  int maxValue;
  int pValue;
  int cap;
}

//


Dict New(cap int, maxValue int){

  try{
    if (cap == 0) {
      throw new Exception("ef: dictionary does not support an empty values list");
    }
  }catch(e){
      print(e);
      return Dict();
  }

  sizeLVal = max0(((maxValue/cap)-1).bitLength);//Returns the minimum number of bits required to store this integer.
  sizeH = cap + (maxValue>>sizeLVal);//Need to see if this works.
  
  final dict = Dict();
  dict.b = <int>[]; 
  dict.sizeValue = sizeLVal;
  dict.sizeH = sizeH;
  dict.lMask = 1<<sizeLVal - 1;
  dict.maxValue = maxValue;
  dict.cap = cap;

  return Dict();

}

int max0(int x){
  if(x <= 0){
    return 0;
  }
  return x;
}

int Len(Dict d){ //Need to check how Len works.
  return d.n;
}

Dict From(<int>[] values){

try{
  if(values.empty){
    throw new Exception ("ef: dictionary does not support an empty values list");
  }
}catch(e){
  print(e);
  return null;
}

Dict d = new(values.length, values[values.length-1]);

return d.build(values);
}

