{-# LINE 1 "Data/IORef/Lifted.hs" #-}
# 1 "Data/IORef/Lifted.hs"
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
# 1 "Data/IORef/Lifted.hs"
{-# LANGUAGE CPP #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE FlexibleContexts #-}


{-# LANGUAGE Trustworthy #-}


{- |
Module      :  Data.IORef
Copyright   :  Liyang HU, Bas van Dijk
License     :  BSD-style

Maintainer  :  Bas van Dijk <v.dijk.bas@gmail.com>
Stability   :  experimental

This is a wrapped version of "Data.IORef" with types
generalised from 'IO' to all monads in 'MonadBase'.
-}

module Data.IORef.Lifted
    ( IORef
    , newIORef
    , readIORef
    , writeIORef
    , modifyIORef

    , modifyIORef'

    , atomicModifyIORef

    , atomicModifyIORef'
    , atomicWriteIORef

    , mkWeakIORef
    ) where

--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

-- from base:
import Data.IORef ( IORef )
import qualified Data.IORef as R
import System.IO ( IO )
import System.Mem.Weak ( Weak )
import Prelude ( (.) )

-- from transformers-base:
import Control.Monad.Base ( MonadBase, liftBase )

-- from monad-control:
import Control.Monad.Trans.Control ( MonadBaseControl, liftBaseDiscard )


# 1 "include/inlinable.h" 1
# 56 "Data/IORef/Lifted.hs" 2

--------------------------------------------------------------------------------
-- * IORefs
--------------------------------------------------------------------------------

-- | Generalized version of 'R.newIORef'.
newIORef :: MonadBase IO m => a -> m (IORef a)
newIORef = liftBase . R.newIORef
{-# INLINE newIORef #-}

-- | Generalized version of 'R.readIORef'.
readIORef :: MonadBase IO m => IORef a -> m a
readIORef = liftBase . R.readIORef
{-# INLINE readIORef #-}

-- | Generalized version of 'R.writeIORef'.
writeIORef :: MonadBase IO m => IORef a -> a -> m ()
writeIORef r = liftBase . R.writeIORef r
{-# INLINE writeIORef #-}

-- | Generalized version of 'R.modifyIORef'.
modifyIORef :: MonadBase IO m => IORef a -> (a -> a) -> m ()
modifyIORef r = liftBase . R.modifyIORef r
{-# INLINE modifyIORef #-}

-- | Generalized version of 'R.atomicModifyIORef'.
atomicModifyIORef :: MonadBase IO m => IORef a -> (a -> (a, b)) -> m b
atomicModifyIORef r = liftBase . R.atomicModifyIORef r
{-# INLINE atomicModifyIORef #-}


-- | Generalized version of 'R.modifyIORef''.
modifyIORef' :: MonadBase IO m => IORef a -> (a -> a) -> m ()
modifyIORef' r = liftBase . R.modifyIORef' r
{-# INLINE modifyIORef' #-}

-- | Generalized version of 'R.atomicModifyIORef''.
atomicModifyIORef' :: MonadBase IO m => IORef a -> (a -> (a, b)) -> m b
atomicModifyIORef' r = liftBase . R.atomicModifyIORef' r
{-# INLINE atomicModifyIORef' #-}

-- | Generalized version of 'R.atomicWriteIORef'.
atomicWriteIORef :: MonadBase IO m => IORef a -> a -> m ()
atomicWriteIORef r = liftBase . R.atomicWriteIORef r


-- | Generalized version of 'R.mkWeakIORef'.
--
-- Note any monadic side effects in @m@ of the \"finalizer\" computation
-- are discarded.
mkWeakIORef :: MonadBaseControl IO m => IORef a -> m () -> m (Weak (IORef a))
mkWeakIORef = liftBaseDiscard . R.mkWeakIORef
{-# INLINE mkWeakIORef #-}
