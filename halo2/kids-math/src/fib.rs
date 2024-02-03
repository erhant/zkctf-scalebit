use halo2_proofs::arithmetic::FieldExt;
use halo2_proofs::{
    arithmetic::Field,
    circuit::{AssignedCell, Chip, Layouter, Region, SimpleFloorPlanner, Value},
    dev::MockProver,
    pasta::{EqAffine, Fp},
    plonk::{
        create_proof, keygen_pk, keygen_vk, verify_proof, Advice, Circuit, Column,
        ConstraintSystem, Error, Expression, Fixed, Instance, ProvingKey, Selector, SingleVerifier,
        VerifyingKey,
    },
    poly::{commitment::Params, Rotation},
    transcript::{Blake2bRead, Blake2bWrite, Challenge255},
};
use serde::{Deserialize, Serialize};
use std::marker::PhantomData;

#[derive(Debug, Clone)]
pub struct FibonacciConfig {
    pub col_a: Column<Advice>,
    pub col_b: Column<Advice>,
    pub col_c: Column<Advice>,
    pub col_pa: Column<Fixed>,
    pub col_pb: Column<Fixed>,
    pub col_pc: Column<Fixed>,
    pub selector: Selector,
    pub instance: Column<Instance>,
}

#[derive(Debug, Clone)]
struct FibonacciChip<F: FieldExt> {
    config: FibonacciConfig,
    _marker: PhantomData<F>,
}

impl<F: FieldExt> FibonacciChip<F> {
    pub fn construct(config: FibonacciConfig) -> Self {
        Self {
            config,
            _marker: PhantomData,
        }
    }

    pub fn configure(meta: &mut ConstraintSystem<F>) -> FibonacciConfig {
        let col_a = meta.advice_column();
        let col_b = meta.advice_column();
        let col_c = meta.advice_column();
        let col_pa = meta.fixed_column();
        let col_pb = meta.fixed_column();
        let col_pc = meta.fixed_column();
        let selector = meta.selector();
        let instance = meta.instance_column();

        meta.enable_equality(col_a);
        meta.enable_equality(col_b);
        meta.enable_equality(col_c);
        meta.enable_equality(instance);

        ///////////////////////// Please implement code here /////////////////////////
        meta.create_gate("Fibonacci constraint", |meta| {
            let s = meta.query_selector(selector);
            let a = meta.query_advice(col_a, Rotation::cur());
            let b = meta.query_advice(col_b, Rotation::cur());
            let c = meta.query_advice(col_c, Rotation::cur());
            let pa = meta.query_fixed(col_pa, Rotation::cur());
            let pb = meta.query_fixed(col_pb, Rotation::cur());
            let pc = meta.query_fixed(col_pc, Rotation::cur());

            // a + b == c for this selector
            vec![s * (a + b - c)]
        });
        ///////////////////////// End implement /////////////////////////

        FibonacciConfig {
            col_a,
            col_b,
            col_c,
            col_pa,
            col_pb,
            col_pc,
            selector,
            instance,
        }
    }

    #[allow(clippy::type_complexity)]
    pub fn assign_first_row(
        &self,
        mut layouter: impl Layouter<F>,
    ) -> Result<(AssignedCell<F, F>, AssignedCell<F, F>, AssignedCell<F, F>), Error> {
        layouter.assign_region(
            || "first row",
            |mut region| {
                self.config.selector.enable(&mut region, 0)?;

                let a_cell = region.assign_advice_from_instance(
                    || "f(0)",
                    self.config.instance,
                    0,
                    self.config.col_a,
                    0,
                )?;

                let b_cell = region.assign_advice_from_instance(
                    || "f(1)",
                    self.config.instance,
                    1,
                    self.config.col_b,
                    0,
                )?;

                let c_cell = region.assign_advice(
                    || "a + b",
                    self.config.col_c,
                    0,
                    || a_cell.value().copied() + b_cell.value(),
                )?;

                // Assign pa here!
                ///////////////////////// Please implement code here /////////////////////////
                region.assign_fixed(|| "pa", self.config.col_pa, 0, || Value::known(F::from(1)))?;
                ///////////////////////// End implement /////////////////////////
                // Assign pb here!
                ///////////////////////// Please implement code here /////////////////////////
                region.assign_fixed(|| "pb", self.config.col_pb, 0, || Value::known(F::from(2)))?;
                ///////////////////////// End implement /////////////////////////
                // Assign pc here!
                ///////////////////////// Please implement code here /////////////////////////
                region.assign_fixed(|| "pc", self.config.col_pc, 0, || Value::known(F::from(3)))?;
                ///////////////////////// End implement /////////////////////////
                Ok((a_cell, b_cell, c_cell))
            },
        )
    }

    pub fn assign_row(
        &self,
        mut layouter: impl Layouter<F>,
        prev_b: &AssignedCell<F, F>,
        prev_c: &AssignedCell<F, F>,
    ) -> Result<AssignedCell<F, F>, Error> {
        layouter.assign_region(
            || "next row",
            |mut region| {
                self.config.selector.enable(&mut region, 0)?;

                prev_b.copy_advice(|| "a", &mut region, self.config.col_a, 0)?;
                prev_c.copy_advice(|| "b", &mut region, self.config.col_b, 0)?;

                let c_value = prev_b.value().copied() + prev_c.value();
                let c_cell = region.assign_advice(|| "c", self.config.col_c, 0, || c_value)?;

                region.assign_fixed(
                    || "pa",
                    self.config.col_pa,
                    0,
                    || Value::known(F::from(125)),
                )?;

                // Assign pb here!
                ///////////////////////// Please implement code here /////////////////////////
                region.assign_fixed(
                    || "pb",
                    self.config.col_pb,
                    0,
                    || Value::known(F::from(125)),
                )?;

                ///////////////////////// End implement /////////////////////////
                // Assign pc here!
                ///////////////////////// Please implement code here /////////////////////////
                region.assign_fixed(
                    || "pc",
                    self.config.col_pc,
                    0,
                    || Value::known(F::from(125)),
                )?;
                ///////////////////////// End implement /////////////////////////

                Ok(c_cell)
            },
        )
    }

    pub fn expose_public(
        &self,
        mut layouter: impl Layouter<F>,
        cell: &AssignedCell<F, F>,
        row: usize,
    ) -> Result<(), Error> {
        layouter.constrain_instance(cell.cell(), self.config.instance, row)
    }
}

#[derive(Default, Serialize, Deserialize)]
pub struct FibonacciCircuit<F>(pub PhantomData<F>);

impl<F: FieldExt> Circuit<F> for FibonacciCircuit<F> {
    type Config = FibonacciConfig;
    type FloorPlanner = SimpleFloorPlanner;

    fn without_witnesses(&self) -> Self {
        Self::default()
    }

    fn configure(meta: &mut ConstraintSystem<F>) -> Self::Config {
        FibonacciChip::configure(meta)
    }

    fn synthesize(
        &self,
        config: Self::Config,
        mut layouter: impl Layouter<F>,
    ) -> Result<(), Error> {
        let chip = FibonacciChip::construct(config);

        let (_, mut prev_b, mut prev_c) =
            chip.assign_first_row(layouter.namespace(|| "first row"))?;

        for _i in 3..5 {
            let c_cell = chip.assign_row(layouter.namespace(|| "next row"), &prev_b, &prev_c)?;
            prev_b = prev_c;
            prev_c = c_cell;
        }

        chip.expose_public(layouter.namespace(|| "out"), &prev_c, 2)?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::FibonacciCircuit;
    use halo2_proofs::{dev::MockProver, pasta::Fp};
    use std::marker::PhantomData;

    #[test]
    fn fibonacci_example1() {
        let k = 4;
        // 1,2,3,5,?
        let quiz = 8;
        let a = Fp::from(1); // F[0]
        let b = Fp::from(2); // F[1]
        let out = Fp::from(quiz); // F[5]

        let circuit = FibonacciCircuit(PhantomData);

        let mut public_input = vec![a, b, out];

        let prover = MockProver::run(k, &circuit, vec![public_input.clone()]).unwrap();
        prover.assert_satisfied();
    }
}
