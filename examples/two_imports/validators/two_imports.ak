use aiken/transaction/value.{
  flatten
}
// use two_imports/value.{ unflatten } // Doesn't work
// use two_imports/value as my_value.{ unflatten }  // Doesn't work.
use two_imports/value as x 
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
          // |> unflatten()
          |> x.unflatten()
      }
    }
    _ -> False
  }
}

