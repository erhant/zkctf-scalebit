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

  // (a + (1 << 201) + 21888242871839269196228739774043741806190518121056274885436977501102676115457)
  //
  // (21888242871839274820511894680509706203057841315125383713147455740877599670273 + (1 << 201) - a)

  // a = 2812141577453232982198433661597034554413855239119887461777408
  //

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
      // can just add 0s to the start for the check beelow :o
      expect(input.length <= 70).toBe(false);
      await circuit.expectPass({
        in: input,
      });
    });
  });

  // 3533700027045102098369050084895387317199177651876580346993442643999981568
  // + (1 << 241) - a

  // a + (1 << 251) + 3618502782768642773547390826438087570129142810943142283802299270005870559232

  // 14651237300404501341712421637297690398004534568671624433662855416322652635137
});
