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

You can see further instruction when you enter the netcat command. You will also need a solver account (preferably a throw-away). You will place your solver private key & RPC urls along with contract addresses under `.env` file, see [example here](./.env.example).

> [!NOTE]
>
> When you get the deployer address, you can fund that address at the faucet, along with your throw-away solver address.

## Tests

Both circuit tests & contract tests are written:

```sh
yarn test     # test everything
yarn test:sol # test contracts
yarn test:js  # test circuits
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

Use this calldata to verify your on-chain proof, check the script or test to see how thats done. You can submit the solution with:

```sh
source .env && forge script script/Checkin.s.sol:Solve --rpc-url $CHECKIN_RPC -vvv --broadcast
```

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

where $c_i$ are round constants, fixed during the instantiation of MiMC. With this in mind, we can check the [circuit itself](https://github.com/erhant/zkctf-scalebit/blob/main/circuits/roundabout.circom#L298), and see two things:

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

Use this calldata to verify your on-chain proof, check the script or test to see how thats done. You can submit the solution with:

```sh
source .env && forge script script/Roundabout.s.sol:Solve --rpc-url $ROUNDABOUT_RPC -vvv --broadcast
```

### Familiar Strangers

We have a several inequalities to solve here. This challenge had no contract, but instead a UI was prepared for us to submit the correct values. We describe how to compute them here:

#### Level 1

In Level 1, we are expected to provide an input `x` such that:

- `x < 6026017665971213533282357846279359759458261226685473132380160` (within 201 bits)
- `x > -401734511064747568885490523085290650630550748445698208825344` (within 201 bits)

The `GreaterThan` uses `LessThan` within (see [here](https://circom.erhant.me/comparators/index.html#greaterthan)), which simply switches the places of the input. Also, lets just work with positive numbers as the negative number will be converted to a positive number within the field. The second inequality thus becomes:

- `21888242871839274820511894680509706203057841315125383713147455740877599670273 < x`

If we look at the number of bits of that huge number, we see that its 254 bits! However, the comparators in Level1 expect 201 bit numbers only. So how do we bypass that? If we look closely, the input to `Num2Bits` is actually `((1 << n) + in[0]) - in[1]` and the `Num2Bits` is instantiated with `n+1` bits.

To return 1 from the `LessThan` template we have to make sure the `n`th bit of that operation is 0. We can actually just say `x = in[1] = in[0] + (1 << n)` which would make the whole thing 0. This gives us `x = 2812141577453232982198433661597034554413855239119887461777408` which is 201 bits! Thankfully, this also satisfies the first inequality, so we can solve Level1 with:

$$
\texttt{in} = 2812141577453232982198433661597034554413855239119887461777408
$$

#### Level 2

In level 2, we again have two inequalities for an input `x` such that:

- `3533700027045102098369050084895387317199177651876580346993442643999981568 > x` (within 241 bits)
- `-3618502782768642773547390826438087570129142810943142283802299270005870559232 < x` (within 251 bits)

Again, lets make all of these use `LessThan` and with no negative numbers.

- `x < 3533700027045102098369050084895387317199177651876580346993442643999981568`
- `18269740089070632448699014918819187518419221589472892059895904916569937936385 < x`

Looking at the second inequality, we can follow the same approach as before to find by setting `x = in[1] = in[0] + (1 << n)` which gives us `x = 5897488333439202455083409550285544209858125342430750230241414742016`. Thankfully again, this number is 222 bits and satisfies the first inequality.

The challenge also required the given number to have more than 70 digits, but this number has 67 digits. If we look closely to this check within the challenge judge code, we see that its just a simple string length check. We can just prepend some zeros to our answer to keep the value same, but make it look like more than 70 digits! With that, our answer is:

$$
\texttt{in} = 00005897488333439202455083409550285544209858125342430750230241414742016
$$
