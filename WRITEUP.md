# 1. Checkin

In my case, the `zkey` corresponded to a circuit with only 1 input and 1 output, although the given circuit code had 2 inputs. So I just removed one of the inputs and proved the circuit. I've used Circomkit.

First, I download the prover key (`zkey`) and rename it as `plonk_pkey.zkey`. Then:

```sh
npx circomkit compile checkin
npx circomkit prove checkin default
npx circomkit calldata checkin default
```

I paste that output into Solidity and we are done!
