{-# LINE 1 "Data.Proxy.hs" #-}
{-# LANGUAGE Trustworthy #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE PolyKinds #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Proxy
-- License     :  BSD-style (see the LICENSE file in the distribution)
--
-- Maintainer  :  libraries@haskell.org
-- Stability   :  experimental
-- Portability :  portable
--
-- Definition of a Proxy type (poly-kinded in GHC)
--
-- @since 4.7.0.0
-----------------------------------------------------------------------------

module Data.Proxy
  (
        Proxy(..), asProxyTypeOf
      , KProxy(..)
  ) where

import GHC.Base
import GHC.Show
import GHC.Read
import GHC.Enum
import GHC.Arr

-- | A concrete, poly-kinded proxy type
data Proxy t = Proxy

-- | A concrete, promotable proxy type, for use at the kind level
-- There are no instances for this because it is intended at the kind level only
data KProxy (t :: *) = KProxy

-- It's common to use (undefined :: Proxy t) and (Proxy :: Proxy t)
-- interchangeably, so all of these instances are hand-written to be
-- lazy in Proxy arguments.

instance Eq (Proxy s) where
  _ == _ = True

instance Ord (Proxy s) where
  compare _ _ = EQ

instance Show (Proxy s) where
  showsPrec _ _ = showString "Proxy"

instance Read (Proxy s) where
  readsPrec d = readParen (d > 10) (\r -> [(Proxy, s) | ("Proxy",s) <- lex r ])

instance Enum (Proxy s) where
    succ _               = errorWithoutStackTrace "Proxy.succ"
    pred _               = errorWithoutStackTrace "Proxy.pred"
    fromEnum _           = 0
    toEnum 0             = Proxy
    toEnum _             = errorWithoutStackTrace "Proxy.toEnum: 0 expected"
    enumFrom _           = [Proxy]
    enumFromThen _ _     = [Proxy]
    enumFromThenTo _ _ _ = [Proxy]
    enumFromTo _ _       = [Proxy]

instance Ix (Proxy s) where
    range _           = [Proxy]
    index _ _         = 0
    inRange _ _       = True
    rangeSize _       = 1
    unsafeIndex _ _   = 0
    unsafeRangeSize _ = 1

instance Bounded (Proxy s) where
    minBound = Proxy
    maxBound = Proxy

instance Monoid (Proxy s) where
    mempty = Proxy
    mappend _ _ = Proxy
    mconcat _ = Proxy

instance Functor Proxy where
    fmap _ _ = Proxy
    {-# INLINE fmap #-}

instance Applicative Proxy where
    pure _ = Proxy
    {-# INLINE pure #-}
    _ <*> _ = Proxy
    {-# INLINE (<*>) #-}

instance Alternative Proxy where
    empty = Proxy
    {-# INLINE empty #-}
    _ <|> _ = Proxy
    {-# INLINE (<|>) #-}

instance Monad Proxy where
    _ >>= _ = Proxy
    {-# INLINE (>>=) #-}

instance MonadPlus Proxy

-- | 'asProxyTypeOf' is a type-restricted version of 'const'.
-- It is usually used as an infix operator, and its typing forces its first
-- argument (which is usually overloaded) to have the same type as the tag
-- of the second.
asProxyTypeOf :: a -> Proxy a -> a
asProxyTypeOf = const
{-# INLINE asProxyTypeOf #-}
