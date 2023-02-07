use aiken/transaction. {TransactionId, ScriptContext, Input}

fn try_assert (input : Input) {
  assert TransactionId(tid) = input.output_reference.transaction_id
  tid
}

fn try_let (input : Input) {
  let TransactionId(tid) = input.output_reference.transaction_id
  tid
}

fn try_when (input : Input) {
  when input.output_reference.transaction_id is {
    TransactionId(tid) -> tid
  }
}

fn mint (_red: Int, ctx : ScriptContext) {
  let inputs = ctx.transaction.inputs 
  assert [input, ..] = inputs
  // let tid = try_assert(input)
  // let tid = try_let(input)
  let tid = try_when(input)
  tid == #[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
}
