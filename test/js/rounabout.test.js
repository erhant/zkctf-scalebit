import { Circomkit } from "circomkit";

describe("roundabout", () => {
  let circuit;

  beforeAll(async () => {
    const circomkit = new Circomkit({ protocol: "groth16", verbose: false });
    circuit = await circomkit.ProofTester("roundabout", {
      file: "roundabout",
      template: "Gift",
    });
  });

  it("should prove & verify", async () => {
    const { proof, publicSignals } = await circuit.prove({ a: 19830713, b: 2 });
    expect(await circuit.verify(proof, publicSignals)).toBe(true);
  });
});
