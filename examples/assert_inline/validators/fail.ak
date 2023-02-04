use aiken/transaction.{
    ScriptContext,
    InlineDatum
}

type Redeemer {
}

type Datum {
}

fn spend(_dat: Datum, _red: Redeemer, ctx: ScriptContext) {
  let outputs = ctx.transaction.outputs
  assert [output, ..] = outputs
  assert InlineDatum(_broke) = output.datum
  let _works = when output.datum is {
    InlineDatum(datum) -> datum
    _ -> error("bad datum")
  }
  True
}
