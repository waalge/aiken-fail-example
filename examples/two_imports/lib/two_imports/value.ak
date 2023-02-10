use aiken/transaction/value.{
  Value,
  PolicyId,
  AssetName,
  zero,
  add, 
  from_asset,
}

use aiken/list.{
  foldl,
}

pub fn unflatten(xs : List<(PolicyId, AssetName, Int)>) -> Value {
  foldl(xs, fn(x, v) { from_asset(x.1st, x.2nd, x.3rd) |> add(v) }, zero()) 
}
