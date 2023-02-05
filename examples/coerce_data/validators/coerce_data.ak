use aiken/transaction.{
    ScriptContext,
    InlineDatum,
    Datum, 
}

type Redeemer {
}

type MyDatum {
  MyDatum(Int) 
}

fn spend(_dat: Datum, _red: Redeemer, ctx: ScriptContext) {
  let outputs = ctx.transaction.outputs
  assert [output, ..] = outputs
  assert InlineDatum(datum) = output.datum
  assert Datum(_x) : Datum = datum 
  True
}
