{-# OPTIONS_GHC -fwarn-incomplete-patterns #-}

module Lambek where

import LExp
import LTypes

dec_rinv :: [LTp] -> LTp -> Bool
dec_rinv gamma (DivL a b) = dec_rinv (a : gamma) b 
dec_rinv gamma (DivR a b) = dec_rinv (gamma ++ [b]) a 
dec_rinv gamma (Atm p) =
    or [dec_lfoc (take i gamma) (gamma !! i) (drop (i + 1) gamma) p
       | i <- [0 .. length gamma - 1]]

dec_lfoc :: [LTp] -> LTp -> [LTp] -> Atm -> Bool
dec_lfoc gammaL (Atm q) gammaR p = null gammaL && null gammaR && q == p
dec_lfoc gammaL (DivL a b) gammaR p =
    or [firstCheck i && secondCheck i | i <- [0 .. length gammaL]]
  where
    firstCheck i = dec_rinv (drop i gammaL) a
    secondCheck i = dec_lfoc (take i gammaL) b gammaR p
dec_lfoc gammaL (DivR a b) gammaR p = 
    or [firstCheck i && secondCheck i | i <- [0 .. length gammaR]]
  where
    firstCheck i = dec_rinv (take i gammaR) b
    secondCheck i = dec_lfoc gammaL a (drop i gammaR) p

isGrammatical :: Lexicon sem -> [String] -> Bool
isGrammatical lex ws =
    or [dec_rinv ts (stp lex)
       | ts <- sequence [[t | (word, t, _) <- items lex, word == w]
                        | w <- ws]]

der_rinv :: [(Var, LTp)] -> LTp -> [LExp]
der_rinv gamma (DivL a b) =
    [L x body | body <- der_rinv ((x, a) : gamma) b]
  where
    x = fresh [V v | (v, _) <- gamma]
der_rinv gamma (DivR a b) =
    [L x body | body <- der_rinv (gamma ++ [(x, b)]) a]
  where
    x = fresh [V v | (v, _) <- gamma]
der_rinv gamma (Atm p) =
    [applyArgs (V v) args
    | i <- [0 .. length gamma - 1]
    , let (v, t) = gamma !! i
    , args <- der_lfoc (take i gamma) t (drop (i + 1) gamma) p
    ]

applyArgs :: LExp -> [LExp] -> LExp
applyArgs expr [] = expr
applyArgs expr (arg : rest) =
    applyArgs (A expr arg) rest