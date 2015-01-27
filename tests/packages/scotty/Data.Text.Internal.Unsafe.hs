{-# LINE 1 "Data/Text/Internal/Unsafe.hs" #-}
# 1 "Data/Text/Internal/Unsafe.hs"
# 1 "<command-line>"
# 10 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4

# 17 "/usr/include/stdc-predef.h" 3 4














# 1 "/usr/include/x86_64-linux-gnu/bits/predefs.h" 1 3 4

# 18 "/usr/include/x86_64-linux-gnu/bits/predefs.h" 3 4












# 31 "/usr/include/stdc-predef.h" 2 3 4








# 10 "<command-line>" 2
# 1 "./dist/dist-sandbox-d76e0d17/build/autogen/cabal_macros.h" 1


















































































































# 10 "<command-line>" 2
# 1 "Data/Text/Internal/Unsafe.hs"
{-# LANGUAGE CPP, MagicHash, UnboxedTuples #-}
{-# OPTIONS_HADDOCK not-home #-}

-- |
-- Module      : Data.Text.Internal.Unsafe
-- Copyright   : (c) 2009, 2010, 2011 Bryan O'Sullivan
-- License     : BSD-style
-- Maintainer  : bos@serpentine.com
-- Stability   : experimental
-- Portability : portable
--
-- /Warning/: this is an internal module, and does not have a stable
-- API or name. Functions in this module may not check or enforce
-- preconditions expected by public modules. Use at your own risk!
--
-- A module containing /unsafe/ operations, for /very very careful/ use
-- in /heavily tested/ code.
module Data.Text.Internal.Unsafe
    (
      inlineInterleaveST
    , inlinePerformIO
    ) where

import GHC.ST (ST(..))

import GHC.IO (IO(IO))
import GHC.Base (realWorld#)



-- | Just like unsafePerformIO, but we inline it. Big performance gains as
-- it exposes lots of things to further inlining. /Very unsafe/. In
-- particular, you should do no memory allocation inside an
-- 'inlinePerformIO' block. On Hugs this is just @unsafePerformIO@.
--
{-# INLINE inlinePerformIO #-}
inlinePerformIO :: IO a -> a

inlinePerformIO (IO m) = case m realWorld# of (# _, r #) -> r




-- | Allow an 'ST' computation to be deferred lazily. When passed an
-- action of type 'ST' @s@ @a@, the action will only be performed when
-- the value of @a@ is demanded.
--
-- This function is identical to the normal unsafeInterleaveST, but is
-- inlined and hence faster.
--
-- /Note/: This operation is highly unsafe, as it can introduce
-- externally visible non-determinism into an 'ST' action.
inlineInterleaveST :: ST s a -> ST s a
inlineInterleaveST (ST m) = ST $ \ s ->
    let r = case m s of (# _, res #) -> res in (# s, r #)
{-# INLINE inlineInterleaveST #-}