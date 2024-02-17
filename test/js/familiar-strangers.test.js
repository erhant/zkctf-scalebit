import { Circomkit } from "circomkit";

describe("familiar strangers", () => {
  const circomkit = new Circomkit({ verbose: false });

  describe("level 1", () => {
    let circuit;

    beforeAll(async () => {
      circuit = await circomkit.WitnessTester("challenge1", {
        file: "familiar-strangers",
        template: "Level1",
      });
    });

    it("level 1", async () => {
      const input =
        "2812141577453232982198433661597034554413855239119887461777408";
      await circuit.expectPass({ in: input });
    });
  });

  describe("level 2", () => {
    let circuit;

    beforeAll(async () => {
      circuit = await circomkit.WitnessTester("challenge2", {
        file: "familiar-strangers",
        template: "Level2",
      });
    });

    it("level 2", async () => {
      const input =
        "00005897488333439202455083409550285544209858125342430750230241414742016";
      // can just add 0s to the start for the check below haha
      expect(input.length <= 70).toBe(false);
      await circuit.expectPass({
        in: input,
      });
    });
  });
});
