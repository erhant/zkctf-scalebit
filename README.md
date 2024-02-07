# ZKCTF by Scalebit - Circom Challenges

When you click on a challenge, you are greeted with:

- an RPC endpoint
- a faucet link
- a netcat `nc` command

You can see further instruction when you enter the netcat command.

> [!NOTE]
>
> When you get the deployer address, you can fund that address at the faucet.

You will also need a solver account (preferably a throw-away) and you can fund that at the faucet as well.

## 1. Checkin

In my case, the `zkey` corresponded to a circuit with only 1 input and 1 output, although the given circuit code had 2 inputs. So I just removed one of the inputs and proved the circuit. I've used Circomkit.

First, I download the prover key (`zkey`) and rename it as `plonk_pkey.zkey`. Then:

```sh
npx circomkit compile checkin
npx circomkit prove checkin default
npx circomkit calldata checkin default
```

I paste that output into Solidity and we are done!

## 4. Roundabout

MiMC has the following scheme:

$$
E_k(x) = (F_{r-1} \cdot F_{r-2} \cdot \ldots \cdot F_0)(x) + k
$$

where $x \in F_{q}$, is the plaintext, $r$ is the number of rounds, $F_i$ is the round function for round $i \geq 0$, and $k \in F_q$ is the key. For Feistel-MiMC Each $F_i$ is defined as:

$$
F_i(x_i, y_i) = (y_i, x_i + (y_i + k + c_i)^3)
$$

where $c_i$ are round constants, fixed during the instantiation of MiMC. In our circuit, we have two rounds but that means the first and last rounds have constant 0:

- $c_{first} = c_0 = 0$
- $c_{last} = c_1 = 0$

So our two rounds with $k=1$ for an input $x$ would be:

$$
F_0(x, 0) = (0, x + (0 + 1 + 0)^3)
$$

$$
F_1(0, x + 1) = (x + 1, (x + 1 + 2)^3)
$$

$$
E_1(x) = F_1(F_0(x, 0)) + 1 = x + 2
$$

However, the output is the $x$ of the last state, so we just have $x+2$ as our output!

L_in = a
R_in = 0

xL[0] = (1 + a)^5
xR[0] = a

xL[1] = (1 + (1 + a)^5)^5
xR[1] = (1 + a)^5

L_out = xL[0]
R_out = xR[1]

c = 3066844496547985532785966973086993824
c = (1 + 19830714)^5 (found with Sage)
a = 19830713

---

9 _ b_sq + 37622140664026667386099315436167897444086165906536960040182069717656571868 === c_sq _ b_sq;

$$
9 * b^2 + M = c^2 * b^2
$$

$$
M = b^2 * (c^2 - 9)
$$

14781455202254494728553277557737201547954787763944603120419043881948088016715
