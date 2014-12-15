{-# LINE 1 "./Data/Text/Internal/Read.hs" #-}
{-# LINE 1 "dist/dist-sandbox-235ea54e/build/autogen/cabal_macros.h" #-}
                                                                

                           






                          






                                 






                             






                              






                                    






                     






                       






                  






                    






                        






                         






                       






                   






                      






                          







{-# LINE 2 "./Data/Text/Internal/Read.hs" #-}
{-# LINE 1 "./Data/Text/Internal/Read.hs" #-}
-- |
-- Module      : Data.Text.Internal.Read
-- Copyright   : (c) 2014 Bryan O'Sullivan
--
-- License     : BSD-style
-- Maintainer  : bos@serpentine.com
-- Stability   : experimental
-- Portability : GHC
--
-- Common internal functiopns for reading textual data.
module Data.Text.Internal.Read
    (
      IReader
    , IParser(..)
    , T(..)
    , digitToInt
    , hexDigitToInt
    , perhaps
    ) where

import Control.Applicative (Applicative(..))
import Control.Arrow (first)
import Control.Monad (ap)
import Data.Char (ord)

type IReader t a = t -> Either String (a,t)

newtype IParser t a = P {
      runP :: IReader t a
    }

instance Functor (IParser t) where
    fmap f m = P $ fmap (first f) . runP m

instance Applicative (IParser t) where
    pure a = P $ \t -> Right (a,t)
    {-# INLINE pure #-}
    (<*>) = ap

instance Monad (IParser t) where
    return = pure
    m >>= k  = P $ \t -> case runP m t of
                           Left err     -> Left err
                           Right (a,t') -> runP (k a) t'
    {-# INLINE (>>=) #-}
    fail msg = P $ \_ -> Left msg

data T = T !Integer !Int

perhaps :: a -> IParser t a -> IParser t a
perhaps def m = P $ \t -> case runP m t of
                            Left _      -> Right (def,t)
                            r@(Right _) -> r

hexDigitToInt :: Char -> Int
hexDigitToInt c
    | c >= '0' && c <= '9' = ord c - ord '0'
    | c >= 'a' && c <= 'f' = ord c - (ord 'a' - 10)
    | otherwise            = ord c - (ord 'A' - 10)

digitToInt :: Char -> Int
digitToInt c = ord c - ord '0'
