{-# LINE 1 "src/Data/Text/Lazy/Builder/Scientific.hs" #-}
# 1 "src/Data/Text/Lazy/Builder/Scientific.hs"
# 1 "<command-line>"
# 8 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4

# 17 "/usr/include/stdc-predef.h" 3 4














# 1 "/usr/include/x86_64-linux-gnu/bits/predefs.h" 1 3 4

# 18 "/usr/include/x86_64-linux-gnu/bits/predefs.h" 3 4












# 31 "/usr/include/stdc-predef.h" 2 3 4








# 8 "<command-line>" 2
# 1 "./dist/dist-sandbox-d76e0d17/build/autogen/cabal_macros.h" 1
































































































































# 8 "<command-line>" 2
# 1 "src/Data/Text/Lazy/Builder/Scientific.hs"
{-# LANGUAGE CPP, MagicHash, OverloadedStrings #-}

module Data.Text.Lazy.Builder.Scientific
    ( scientificBuilder
    , formatScientificBuilder
    , FPFormat(..)
    ) where

import           Data.Scientific   (Scientific)
import qualified Data.Scientific as Scientific

import Data.Text.Lazy.Builder.RealFloat (FPFormat(..))

import Data.Text.Lazy.Builder       (Builder, fromString, singleton, fromText)
import Data.Text.Lazy.Builder.Int   (decimal)
import qualified Data.Text as T     (replicate)
import GHC.Base                     (Int(I#), Char(C#), chr#, ord#, (+#))

import Data.Monoid                  ((<>))







-- | A @Text@ @Builder@ which renders a scientific number to full
-- precision, using standard decimal notation for arguments whose
-- absolute value lies between @0.1@ and @9,999,999@, and scientific
-- notation otherwise.
scientificBuilder :: Scientific -> Builder
scientificBuilder = formatScientificBuilder Generic Nothing

-- | Like 'scientificBuilder' but provides rendering options.
formatScientificBuilder :: FPFormat
                        -> Maybe Int  -- ^ Number of decimal places to render.
                        -> Scientific
                        -> Builder
formatScientificBuilder fmt decs scntfc
   | scntfc < 0 = singleton '-' <> doFmt fmt (Scientific.toDecimalDigits (-scntfc))
   | otherwise  =                  doFmt fmt (Scientific.toDecimalDigits   scntfc)
 where
  doFmt format (is, e) =
    let ds = map i2d is in
    case format of
     Generic ->
      doFmt (if e < 0 || e > 7 then Exponent else Fixed)
            (is,e)
     Exponent ->
      case decs of
       Nothing ->
        let show_e' = decimal (e-1) in
        case ds of
          "0"     -> "0.0e0"
          [d]     -> singleton d <> ".0e" <> show_e'
          (d:ds') -> singleton d <> singleton '.' <> fromString ds' <> singleton 'e' <> show_e'
          []      -> error $ "Data.Text.Lazy.Builder.Scientific.formatScientificBuilder" ++
                             "/doFmt/Exponent: []"
       Just dec ->
        let dec' = max dec 1 in
        case is of
         [0] -> "0." <> fromText (T.replicate dec' "0") <> "e0"
         _ ->
          let
           (ei,is') = roundTo (dec'+1) is
           (d:ds') = map i2d (if ei > 0 then init is' else is')
          in
          singleton d <> singleton '.' <> fromString ds' <> singleton 'e' <> decimal (e-1+ei)
     Fixed ->
      let
       mk0 ls = case ls of { "" -> "0" ; _ -> fromString ls}
      in
      case decs of
       Nothing
          | e <= 0    -> "0." <> fromText (T.replicate (-e) "0") <> fromString ds
          | otherwise ->
             let
                f 0 s    rs  = mk0 (reverse s) <> singleton '.' <> mk0 rs
                f n s    ""  = f (n-1) ('0':s) ""
                f n s (r:rs) = f (n-1) (r:s) rs
             in
                f e "" ds
       Just dec ->
        let dec' = max dec 0 in
        if e >= 0 then
         let
          (ei,is') = roundTo (dec' + e) is
          (ls,rs)  = splitAt (e+ei) (map i2d is')
         in
         mk0 ls <> (if null rs then "" else singleton '.' <> fromString rs)
        else
         let
          (ei,is') = roundTo dec' (replicate (-e) 0 ++ is)
          d:ds' = map i2d (if ei > 0 then is' else 0:is')
         in
         singleton d <> (if null ds' then "" else singleton '.' <> fromString ds')

-- | Unsafe conversion for decimal digits.
{-# INLINE i2d #-}
i2d :: Int -> Char
i2d (I# i#) = C# (chr# (ord# '0'# +# i#))

roundTo :: Int -> [Int] -> (Int,[Int])
roundTo d is =
  case f d True is of
    x@(0,_) -> x
    (1,xs)  -> (1, 1:xs)
    _       -> error "roundTo: bad Value"
 where
  base = 10

  b2 = base `quot` 2

  f n _ []     = (0, replicate n 0)
  f 0 e (x:xs) | x == b2 && e && all (== 0) xs = (0, [])   -- Round to even when at exactly half the base
               | otherwise = (if x >= b2 then 1 else 0, [])
  f n _ (i:xs)
     | i' == base = (1,0:ds)
     | otherwise  = (0,i':ds)
      where
       (c,ds) = f (n-1) (even i) xs
       i'     = c + i