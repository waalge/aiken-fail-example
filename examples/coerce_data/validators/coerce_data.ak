use aiken/transaction.{
    ScriptContext,
    InlineDatum
}

type Redeemer {
}

type Datum {
  Datum(Int) 
}

fn spend(_dat: Datum, _red: Redeemer, ctx: ScriptContext) {
  let outputs = ctx.transaction.outputs
  assert [output, ..] = outputs
  let _ = when output.datum is {
    InlineDatum(datum) -> { 
      when datum is { 
        Datum(_x) -> True 
        _ -> False 
      }
    }
    _ -> error("bad datum")
  }
  True
}
