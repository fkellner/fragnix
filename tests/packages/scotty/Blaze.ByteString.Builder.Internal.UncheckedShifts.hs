{-# LINE 1 "Blaze/ByteString/Builder/Internal/UncheckedShifts.hs" #-}
# 1 "Blaze/ByteString/Builder/Internal/UncheckedShifts.hs"
# 1 "<command-line>"
# 9 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4

# 17 "/usr/include/stdc-predef.h" 3 4














# 1 "/usr/include/x86_64-linux-gnu/bits/predefs.h" 1 3 4

# 18 "/usr/include/x86_64-linux-gnu/bits/predefs.h" 3 4












# 31 "/usr/include/stdc-predef.h" 2 3 4








# 9 "<command-line>" 2
# 1 "./dist/dist-sandbox-d76e0d17/build/autogen/cabal_macros.h" 1





























































































# 9 "<command-line>" 2
# 1 "Blaze/ByteString/Builder/Internal/UncheckedShifts.hs"
{-# LANGUAGE CPP, MagicHash #-}





-- |
-- Module      : Blaze.ByteString.Builder.Internal.UncheckedShifts
-- Copyright   : (c) 2010 Simon Meier
--
--               Original serialization code from 'Data.Binary.Builder':
--               (c) Lennart Kolmodin, Ross Patterson
--
-- License     : BSD3-style (see LICENSE)
--
-- Maintainer  : Simon Meier <iridcode@gmail.com>
-- Stability   : experimental
-- Portability : tested on GHC only
--
-- Utilty module defining unchecked shifts.
--


# 1 "/usr/local/lib/ghc-7.8.3/include/MachDeps.h" 1

# 15 "/usr/local/lib/ghc-7.8.3/include/MachDeps.h"






# 1 "/usr/local/lib/ghc-7.8.3/include/ghcautoconf.h" 1





































































































































































































































































































































































































































# 21 "/usr/local/lib/ghc-7.8.3/include/MachDeps.h" 2

































































# 99 "/usr/local/lib/ghc-7.8.3/include/MachDeps.h"

# 109 "/usr/local/lib/ghc-7.8.3/include/MachDeps.h"











# 24 "Blaze/ByteString/Builder/Internal/UncheckedShifts.hs" 2


module Blaze.ByteString.Builder.Internal.UncheckedShifts (
    shiftr_w16
  , shiftr_w32
  , shiftr_w64
  ) where

-- TODO: Check validity of this implementation


import GHC.Base
import GHC.Word (Word32(..),Word16(..),Word64(..))









------------------------------------------------------------------------
-- Unchecked shifts

{-# INLINE shiftr_w16 #-}
shiftr_w16 :: Word16 -> Int -> Word16
{-# INLINE shiftr_w32 #-}
shiftr_w32 :: Word32 -> Int -> Word32
{-# INLINE shiftr_w64 #-}
shiftr_w64 :: Word64 -> Int -> Word64


shiftr_w16 (W16# w) (I# i) = W16# (w `uncheckedShiftRL#`   i)
shiftr_w32 (W32# w) (I# i) = W32# (w `uncheckedShiftRL#`   i)

# 70 "Blaze/ByteString/Builder/Internal/UncheckedShifts.hs"
shiftr_w64 (W64# w) (I# i) = W64# (w `uncheckedShiftRL#` i)







