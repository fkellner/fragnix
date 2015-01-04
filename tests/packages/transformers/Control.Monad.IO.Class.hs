{-# LINE 1 "./Control/Monad/IO/Class.hs" #-}
{-# LINE 1 "dist/dist-sandbox-235ea54e/build/autogen/cabal_macros.h" #-}
                                                                

                          






                     






                       






                  






                    






                        






                         






                       






                   






                      






                          







{-# LINE 2 "./Control/Monad/IO/Class.hs" #-}
{-# LINE 1 "./Control/Monad/IO/Class.hs" #-}
{-# LANGUAGE CPP #-}



-----------------------------------------------------------------------------
-- |
-- Module      :  Control.Monad.IO.Class
-- Copyright   :  (c) Andy Gill 2001,
--                (c) Oregon Graduate Institute of Science and Technology, 2001
-- License     :  BSD-style (see the file LICENSE)
--
-- Maintainer  :  ross@soi.city.ac.uk
-- Stability   :  experimental
-- Portability :  portable
--
-- Class of monads based on @IO@.
-----------------------------------------------------------------------------

module Control.Monad.IO.Class (
    MonadIO(..)
  ) where

-- | Monads in which 'IO' computations may be embedded.
-- Any monad built by applying a sequence of monad transformers to the
-- 'IO' monad will be an instance of this class.
--
-- Instances should satisfy the following laws, which state that 'liftIO'
-- is a transformer of monads:
--
-- * @'liftIO' . 'return' = 'return'@
--
-- * @'liftIO' (m >>= f) = 'liftIO' m >>= ('liftIO' . f)@

class (Monad m) => MonadIO m where
    -- | Lift a computation from the 'IO' monad.
    liftIO :: IO a -> m a

instance MonadIO IO where
    liftIO = id