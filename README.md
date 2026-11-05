# LLaMbda

A CSE301 natural-language interface using product-free Lambek calculus.
Haskell checks grammar and builds lambda expressions; Python evaluates their
meanings. It includes the supplied English animal example and a small Romanian
fragment with reflexive clitics (`mă culc`) and omitted subjects (`știu`).

## Run

Requires GHC with `process` and Python 3 on your path.

```sh
cd LLaMbda
ghc ChatLLaMbda.hs -o ChatLLaMbda
./ChatLLaMbda
```

Choose `romanian.elx` and `roworld.py`, then try:

```text
eu știu
știu
eu mă culc
ma culc
te culci
ne spălăm
se trezesc
```

Enter sentences without punctuation; listed ASCII aliases also work.
Exit with `:quit` or `:q`. To run the prepared demo:

```sh
./ChatLLaMbda < romanian_demo.txt
```

For English, choose `animals.elx` and `aniworld.py` instead.
Try `every cat fears a dog` for two scope readings.

## Implementation

| File in `LLaMbda/` | Purpose |
| --- | --- |
| `Lambek.hs` | Focused proof search, lambda derivations, token normalization |
| `ChatLLaMbda.hs` | Interactive loop and Python evaluation of each reading |
| `LTypes.hs`, `Parser.hs` | Grammatical types and lexicon parsing |
| `LExp.hs`, `PySupport.hs` | Lambda operations and Python bridge |
| `romanian.elx`, `roworld.py` | Romanian grammar, meanings, and toy facts |
| `ROMANIAN.md`, `romanian_demo.txt` | Extension guide and demo input |

Proof search enumerates lexical choices and context splits. Each derivation keeps
its chosen lexical meanings for evaluation. The Romanian extension uses lexicon
and world entries without changing the inference rules; see
[ROMANIAN.md](LLaMbda/ROMANIAN.md).

The supplied parser, types, Python bridge, and English examples are unchanged.
`LExp.hs` drops a compiler flag unsupported by GHC 9.4.7.

## Assistance acknowledgement

OpenAI ChatGPT generated and revised the documentation and tests, assisted with the interface, and ran validation.

