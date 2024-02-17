import { Circomkit } from "circomkit";

describe("checkin", () => {
  let circuit;

  beforeAll(async () => {
    const circomkit = new Circomkit({ protocol: "groth16", verbose: false });
    circuit = await circomkit.ProofTester("checkin", {
      file: "checkin",
      template: "Example",
    });
  });

  it("should prove & verify", async () => {
    const { proof, publicSignals } = await circuit.prove({ a: 1, b: 2 });
    expect(await circuit.verify(proof, publicSignals)).toBe(true);
  });
});
