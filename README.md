# Aiken fail example 

> Examples to point at when discussing aiken issues

## Setup 

This repo uses nix flakes.
Moreover it points at flakified aiken (https://github.com/waalge/aiken).

## Issue 

Introduced `waalge/aiken`: 
```sample
- From : 14f4ac735ea5509875ecb41a131901032bcba972 
- To   : 8b1673f6bead5bc7e67e976ad7f7f4cb375c183f
```

Error: 
```sample
  help: I am inferring the following type:

            Datum<a>

        but I found an expression with a different type:

            Data
  
```
