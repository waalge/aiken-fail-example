use aiken/option.{
  or_else
}
use aiken/list.{
  head
}
use aiken/transaction.{
  ScriptContext,
  Mint,
}

type Redeemer {
  MintR(ByteArray)
  BurnR
}

fn mint(_red: Redeemer, ctx: ScriptContext) {
  when ctx.purpose is {
    Mint(_pid) -> {
      let _broken = ctx.transaction.inputs |> head() |> or_else(error("impossible")) 
      let works = ctx.transaction.inputs |> head()
      when works is {
        Some(_) -> True
        None -> False
      }
    }
    _ -> False
  }
}

