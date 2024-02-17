# ZKCTF by Scalebit - Circom Challenges

Explained solutions to the challenges:

- [x] [Checkin](#checkin)
- [x] [Roundabout](#roundabout)
- [x] [Familiar Strangers](#familiar-strangers)
- [ ] Mixer

## Setup

Install everything here with:

```sh
yarn install
forge install
```

When you click on a challenge, you are greeted with:

- an RPC endpoint
- a faucet link
- a netcat `nc` command

You can see further instruction when you enter the netcat command. You will also need a solver account (preferably a throw-away).

> [!NOTE]
>
> When you get the deployer address, you can fund that address at the faucet, along with your throw-away solver address.

See [example env](./.env.example) file for the Forge script setup.

## Tests

Both circuit tests & contract tests are written:

```sh
yarn  test # test circuits
forge test # test contracts
```

## Solutions

Below are the write-ups.

### Checkin

Compile the circuit:

```sh
npx circomkit compile checkin
```

Download the given prover key (`zkey`) and rename it as `groth16_pkey.zkey`, place it under the build directory of the circuit. Create an input under `inputs/checkin/default.json` as:

```sh
{
  "a": 1,
  "b": 1
}
```

Finally, prove & generate calldata:

```sh
npx circomkit prove checkin
npx circomkit calldata checkin
```

Use this calldata to verify your on-chain proof, check the script or test to see how thats done.

### Roundabout

If we read the docs about [MiMC](https://byt3bit.github.io/primesym/mimc/), it has the following scheme:

$$
E_k(x) = (F_{r-1} \cdot F_{r-2} \cdot \ldots \cdot F_0)(x) + k
$$

where $x \in F_{q}$, is the plaintext, $r$ is the number of rounds, $F_i$ is the round function for round $i \geq 0$, and $k \in F_q$ is the key. At the bottom of that page, we see the Feistel-MiMC which is what the circuit in this challenge makes use of.

For Feistel-MiMC Each $F_i$ is defined as:

$$
F_i(x_i, y_i) = (y_i, x_i + (y_i + k + c_i)^3)
$$

where $c_i$ are round constants, fixed during the instantiation of MiMC. With this in mind, we can check the [circuit itself](https://github.com/iden3/circomlib/blob/master/circuits/mimcsponge.circom#L275), and see two things:

- The circuit recommends 220 rounds (as indicated in a comment there) but we have two rounds, which means the first and last rounds have constant 0:
  - $c_{first} = c_0 = 0$
  - $c_{last} = c_1 = 0$
- The circuit uses the fifth power instead of third, as in $(y_i + k + c_i)^5$
- $y_0$ is 0 and $x_0$ is $x$ for some input $x$ to the circuit.

So our two rounds with $k=1$ for an input $a$ would look like the following:

```py
# inputs
L_in = a
R_in = 0

# first round
xL[0] = (1 + a)^5
xR[0] = a

# second (and last) round
xL[1] = (1 + (1 + a)^5)^5
xR[1] = (1 + a)^5

# outputs
L_out = xL[0]
R_out = xR[1]
```

As the final output, we only have `R_out` which is just $(1 + a)^5$. The given circuit expects this value to be `3066844496547985532785966973086993824` so we only need to solve the following equation for $a$:

$$
(1 + a)^5 = 3066844496547985532785966973086993824
$$

Using Sage, we can find the answer:

```py
# bn128 order
p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
F = GF(p)

c = F(3066844496547985532785966973086993824)
a = c.nth_root(5) - 1
print(a)
```

We find $a = 19830713$, done!

In the next part of this challenge, we need to find a suitable $b$ that satisfies an equation. Denote $k = 37622140664026667386099315436167897444086165906536960040182069717656571868$ as given in the problem. Then, we are looking to satisfy:

$$
9b^2 + k = c^2 \times b^2
$$

We can re-arrange as:

$$
(c^2 - 9)^{-1} \times k = b^2
$$

Again, we can use Sage:

```py
# bn128 order
p = 21888242871839275222246405745257275088548364400416034343698204186575808495617
F = GF(p)

c = F(3066844496547985532785966973086993824)
k = F(37622140664026667386099315436167897444086165906536960040182069717656571868)

bb = (1 / (c * c - 9)) * k
b = bb.nth_root(2)
print(b)
```

We find $b=2$, so we now have all our inputs. To solve the challenge, first compile the circuit:

```sh
npx circomkit compile roundabout
```

Download the given prover key (`zkey`) and rename it as `groth16_pkey.zkey`, place it under the build directory of the circuit. Create an input under `inputs/roundabout/default.json` as:

```sh
{
  "a": 19830713,
  "b": 2
}
```

Finally, prove & generate calldata:

```sh
npx circomkit prove roundabout
npx circomkit calldata roundabout
```

Use this calldata to verify your on-chain proof, check the script or test to see how thats done.

### Familiar Strangers

We have a several inequalities to solve here. In Level 1, we are expected to provide an input `x` such that:
