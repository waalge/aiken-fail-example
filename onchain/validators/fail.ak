use aiken/hash.{
  Blake2b_224, 
    Hash
}
use aiken/interval.{
  Finite,
    Interval,
    IntervalBound,
    PositiveInfinity
}
use aiken/list.{
  and,
    find,
    foldl,
    filter
}
use aiken/transaction.{
  Transaction,
    ScriptContext,
    Spend,
    ValidityRange,
    OutputReference,
    Output,
    Input,
    InlineDatum
}
use aiken/transaction/credential.{
  VerificationKey,
    Address
}
use aiken/transaction/value.{
  Value,
    PolicyId,
    AssetName,
    quantity_of,
    zero,
    add,
    from_asset,
    flatten,
    negate,
    from_lovelace
}

// Special function! aiken looks for.

fn spend(dat: Datum<State>, red: Redeemer, ctx: ScriptContext) {
  when ctx.purpose is {
    Spend(oref) -> v_spend(dat, red, ctx.transaction, oref)
    _ -> False
  }
}

// Base types

type VerificationKeyHash = Hash<Blake2b_224, VerificationKey>
 
type POSIXTime = Int

type Duration = Int // Milliseconds

// States 

type Initted { 
  owner : VerificationKeyHash,
  owner_address: Address,
  asset_pid: PolicyId,
  asset_name: AssetName,
  asset_quantity: Int,
  fee   : Int,
  duration : Duration, 
}

type Engaged {
  owner : VerificationKeyHash,
  owner_address : Address,
  engager : VerificationKeyHash,
  asset_pid: PolicyId,
  asset_quantity: Int,
  endAt : POSIXTime, 
}

type State {
  InittedS(Initted)
  EngagedS(Engaged)
}

// Actions

type Cancel = Void

type Engage {
  engager : VerificationKeyHash,
  now : POSIXTime, 
}

type Redeemer {
  CancelR(Cancel)
  EngageR(Engage) 
}

fn v_spend(dat: Datum<State>, action: Redeemer, tx: Transaction, oref: OutputReference) -> Bool {
  // let (curr, ctx) : Option<(State, Ctx<State>)> = setup_ctx(dat, tx, oref)
  let x = setup_ctx(dat, tx, oref)
  True 
  // let next = when curr is {
  //   InittedS(state) -> when action is {
  //     CancelR(act) -> cancel(ctx, act, state) 
  //     EngageR(act) -> engage(ctx, act, state) 
  //   }
  //   _ -> error("impossible")
  // }
  // next == ctx.next
}

// Verify cancel 

fn cancel(
  ctx : Ctx<State>,
  _act : Cancel, 
  state : Initted, 
  ) -> Option<StateValue<State>> {
  // Note that no correctness of current state necessary.
  let _ = avow(
    and([
      is_signed_by(ctx.tx, state.owner),
    ]), 
    "cancel constraints not met"
  )
  None
}

fn avow_init(ctx : Ctx<State>, state: Initted) {
  // An initial stage needs only be verified if a second party is engaging
  // avow the init state is legit.
  // 1. assets are non-negative
  // 2. assets are in utxo
  let _ = avow(state.asset_quantity > 0, "bad quantity") 
  let val = from_asset(state.asset_pid, state.asset_name, state.asset_quantity) 
  let bad_val = split(add(ctx.value, negate(val))).1st
  let _ = avow(bad_val == zero(), "bad value") 
  Void
}

fn mk_engaged(act: Engage, state: Initted) {
  Engaged {
    owner : state.owner, 
    owner_address : state.owner_address, 
    asset_pid : state.asset_pid,
    asset_quantity : state.asset_quantity,
    engager : act.engager,
    endAt : act.now + state.duration, 
  }
}

fn engage(
  ctx : Ctx<State>,
  act : Engage, 
  state : Initted
  ) -> Option<StateValue<State>> {
  let _ = avow_init(ctx, state) 
  let _ = avow(
    and([
      pays(state.owner_address, from_lovelace(state.fee), ctx.tx) 
      // TODO
    ]),
    "engage constraints not met"
  )
  Some(
    StateValue {
      state: EngagedS(mk_engaged(act, state)),
      value  : zero(), //TODO
    }
  )
}

fn pays (addr : Address, val : Value, tx : Transaction) -> Bool {
  // TODO
  True
}

// -- General statemachine code -- 
// 0. Types 

type Token {
  pid : PolicyId,
  tn : AssetName,
}

type Datum<s> {
  token : Token, 
  state : s, 
}

type StateValue<a> {
  state : a,
  value : Value,
}

type Ctx<a> {
  tx : Transaction,
  value : Value,
  next : Option<StateValue<a>>,
}

// 1. Setup context 

fn is_input(input : Input, inref: OutputReference, tk: Token) -> Bool {
  and([
    input.output_reference == inref,
    quantity_of(input.output.value, tk.pid, tk.tn) == 1,
  ])
}

fn get_input(tx: Transaction, inref: OutputReference, tk: Token) -> Input {
  let input = find( tx.inputs, fn(input) { is_input(input, inref, tk) }) 
  when input is {
    Some(i) -> i 
    None -> error("no input") 
  }
}

fn is_output(output : Output, addr : Address, tk: Token) -> Bool {
  and([
      quantity_of(output.value, tk.pid, tk.tn) == -1,
      output.address == addr,
  ])
}

fn get_output(tx: Transaction, addr: Address, tk: Token) -> Option<Output> {
  // avow token correctly handled
  let maybe_output = find(tx.outputs, fn(o) {is_output(o, addr, tk)})
  let _ = when maybe_output is {
    None -> avow(quantity_of(tx.mint, tk.pid, tk.tn) == -1, "must burn state token")
    Some(output) -> {
      avow(quantity_of(output.value, tk.pid, tk.tn) == 1, "state token must remain at contract")
    }
  }
  maybe_output
}

fn to_statevalue (maybe_output : Option<Output>, tk: Token) -> Option<StateValue<a>> {
  // 1. avow output datum is correctly handled 
  // 2. Remove state token from value 
  when maybe_output is {
    None -> None 
    Some(output) -> {
      assert InlineDatum(dat) = output.datum 
      assert Datum { state : curr, token : n_tk} : Datum<a> = dat 
      let _ = avow(tk == n_tk, "bad datum")
      let val = add(output.value, from_asset(tk.pid, tk.tn, -1))
      Some( StateValue {state: curr, value : val})
    }
  }
}

// fn setup_ctx (dat: Datum<a>, tx: Transaction, inref: OutputReference) -> Option<(a, Ctx<a>)> {
fn setup_ctx (dat: Datum<a>, tx: Transaction, inref: OutputReference) -> Int {
  let Datum{state: curr, token: tk} = dat
  let input = get_input(tx, inref, tk) 
  // let output = get_output(tx, input.output.address, tk)
  // let next = to_statevalue(output, tk)
  // let val = add( input.output.value, from_asset(tk.pid, tk.tn, -1))
  // let ctx : Ctx<a> = Ctx {
  //   tx: tx,
  //   value : val,
  //   next: next,
  // }
  // Some((curr, ctx))
  0
}

// Constraints 

fn is_signed_by(transaction: Transaction, vk: VerificationKeyHash) {
  list.has(transaction.extra_signatories, vk)
}
 
fn is_after(range: ValidityRange, lower_bound: POSIXTime) {
  when range.lower_bound.bound_type is {
    Finite(now) -> now >= lower_bound
    _ -> False
  }
}

// Assert condition  (keyword taken)

fn avow(is_true_else : Bool, err : String) -> Void {
  if !is_true_else { 
    error(err)
  } else {
    Void
  }
}


// Value helpers 

fn unflatten(xs : List<(PolicyId, AssetName, Int)>) -> Value {
  foldl(xs, fn(x, v) { add(from_asset(x.1st, x.2nd, x.3rd), v) }, zero()) 
}

fn split(v : Value) -> (Value, Value) {
  /// Return (value < 0, value > 0) 
  // TODO : check this is the best way to do this
  let flat = flatten(v)
  let neg = filter(flat, fn(x) {x.3rd < 0})
  let pos = filter(flat, fn(x) {x.3rd > 0})
  (unflatten(neg), unflatten(pos)) 
}
