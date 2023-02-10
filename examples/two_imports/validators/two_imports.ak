use aiken/transaction/value.{
  flatten
}
use two_imports/value.{unflatten} as my_value // Works! 
use aiken/transaction.{
  ScriptContext,
  Mint,
}

type Redeemer {
}

fn mint(_red: Redeemer, ctx: ScriptContext) {
  when ctx.purpose is {
    Mint(_) -> {
      ctx.transaction.mint == {
        ctx.transaction.mint 
          |> flatten() 
          |> unflatten()
      }
    }
    _ -> False
  }
}

