use aiken/transaction. {TransactionId, ScriptContext}

fn mint (_red: Int, ctx : ScriptContext) {
  let inputs = ctx.transaction.inputs 
  assert [input, ..] = inputs
  // assert TransactionId(tid) = input.output_reference.transaction_id
  let TransactionId(tid) = input.output_reference.transaction_id
  tid == #[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
}
