pragma circom 2.1.7;

include "circomlib/circuits/comparators.circom";

template Level1() {
  signal input in;
  signal output out;
  out <== 1;
  component lt = LessThan(201);
  lt.in[0] <== in;
  lt.in[1] <== 6026017665971213533282357846279359759458261226685473132380160;
  lt.out === out;
  component gt = GreaterThan(201);
  gt.in[0] <== in;
  gt.in[1] <== -401734511064747568885490523085290650630550748445698208825344;
  gt.out === out;
}

template Level2() {
  signal input in;
  signal output out;
  out <== 1;
  component lt = GreaterThan(241);
  lt.in[0] <== 3533700027045102098369050084895387317199177651876580346993442643999981568;
  lt.in[1] <== in;
  lt.out === out;
  component gt = LessThan(251);
  gt.in[0] <== -3618502782768642773547390826438087570129142810943142283802299270005870559232;
  gt.in[1] <== in;
  gt.out === out;
}
