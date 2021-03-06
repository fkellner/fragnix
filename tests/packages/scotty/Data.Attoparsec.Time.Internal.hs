{-# LANGUAGE Haskell2010 #-}
{-# LINE 1 "attoparsec-iso8601/Data/Attoparsec/Time/Internal.hs" #-}

































































































{-# LANGUAGE CPP #-}

-- |
-- Module:      Data.Aeson.Internal.Time
-- Copyright:   (c) 2015-2016 Bryan O'Sullivan
-- License:     BSD3
-- Maintainer:  Bryan O'Sullivan <bos@serpentine.com>
-- Stability:   experimental
-- Portability: portable

module Data.Attoparsec.Time.Internal
    (
      TimeOfDay64(..)
    , fromPico
    , toPico
    , diffTimeOfDay64
    , toTimeOfDay64
    ) where

import Prelude ()
import Prelude.Compat

import Data.Int (Int64)
import Data.Time
import Unsafe.Coerce (unsafeCoerce)


import Data.Fixed (Pico, Fixed(MkFixed))

toPico :: Integer -> Pico
toPico = MkFixed

fromPico :: Pico -> Integer
fromPico (MkFixed i) = i


-- | Like TimeOfDay, but using a fixed-width integer for seconds.
data TimeOfDay64 = TOD {-# UNPACK #-} !Int
                       {-# UNPACK #-} !Int
                       {-# UNPACK #-} !Int64

diffTimeOfDay64 :: DiffTime -> TimeOfDay64
diffTimeOfDay64 t = TOD (fromIntegral h) (fromIntegral m) s
  where (h,mp) = fromIntegral pico `quotRem` 3600000000000000
        (m,s)  = mp `quotRem` 60000000000000
        pico   = unsafeCoerce t :: Integer

toTimeOfDay64 :: TimeOfDay -> TimeOfDay64
toTimeOfDay64 (TimeOfDay h m s) = TOD h m (fromIntegral (fromPico s))
