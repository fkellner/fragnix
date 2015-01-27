{-# LINE 1 "Control/Concurrent/Chan/Lifted.hs" #-}
# 1 "Control/Concurrent/Chan/Lifted.hs"
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
# 1 "Control/Concurrent/Chan/Lifted.hs"
{-# LANGUAGE CPP #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE FlexibleContexts #-}


{-# LANGUAGE Trustworthy #-}


{- |
Module      :  Control.Concurrent.Chan.Lifted
Copyright   :  Liyang HU, Bas van Dijk
License     :  BSD-style

Maintainer  :  Bas van Dijk <v.dijk.bas@gmail.com>
Stability   :  experimental

This is a wrapped version of "Control.Concurrent.Chan" with types
generalised from 'IO' to all monads in 'MonadBase'.

'Chan.unGetChan' and 'Chan.isEmptyChan' are deprecated in @base@, therefore
they are not included here. Use 'Control.Concurrent.STM.TVar' instead.
-}

module Control.Concurrent.Chan.Lifted
    ( Chan
    , newChan
    , writeChan
    , readChan
    , dupChan
    , getChanContents
    , writeList2Chan
    ) where

--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

-- from base:
import Control.Concurrent.Chan ( Chan )
import qualified Control.Concurrent.Chan as Chan
import System.IO ( IO )
import Prelude ( (.) )

-- from transformers-base:
import Control.Monad.Base ( MonadBase, liftBase )


# 1 "include/inlinable.h" 1
# 48 "Control/Concurrent/Chan/Lifted.hs" 2

--------------------------------------------------------------------------------
-- * Chans
--------------------------------------------------------------------------------

-- | Generalized version of 'Chan.newChan'.
newChan :: MonadBase IO m => m (Chan a)
newChan = liftBase Chan.newChan
{-# INLINE newChan #-}

-- | Generalized version of 'Chan.writeChan'.
writeChan :: MonadBase IO m => Chan a -> a -> m ()
writeChan chan = liftBase . Chan.writeChan chan
{-# INLINE writeChan #-}

-- | Generalized version of 'Chan.readChan'.
readChan :: MonadBase IO m => Chan a -> m a
readChan = liftBase . Chan.readChan
{-# INLINE readChan #-}

-- | Generalized version of 'Chan.dupChan'.
dupChan :: MonadBase IO m => Chan a -> m (Chan a)
dupChan = liftBase . Chan.dupChan
{-# INLINE dupChan #-}

-- | Generalized version of 'Chan.getChanContents'.
getChanContents :: MonadBase IO m => Chan a -> m [a]
getChanContents = liftBase . Chan.getChanContents
{-# INLINE getChanContents #-}

-- | Generalized version of 'Chan.writeList2Chan'.
writeList2Chan :: MonadBase IO m => Chan a -> [a] -> m ()
writeList2Chan chan = liftBase . Chan.writeList2Chan chan
{-# INLINE writeList2Chan #-}
