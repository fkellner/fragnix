{-# LINE 1 "Network/Wai/Middleware/RequestLogger/Internal.hs" #-}
# 1 "Network/Wai/Middleware/RequestLogger/Internal.hs"
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
# 1 "Network/Wai/Middleware/RequestLogger/Internal.hs"
{-# LANGUAGE CPP #-}
-- | A module for containing some CPPed code, due to:
--
-- https://github.com/yesodweb/wai/issues/192
module Network.Wai.Middleware.RequestLogger.Internal
    ( module Network.Wai.Middleware.RequestLogger.Internal
    ) where

import Data.ByteString (ByteString)
import Network.Wai.Logger (clockDateCacher)
import Control.Concurrent (forkIO, threadDelay)
import Control.Monad (forever)

import System.Log.FastLogger (LogStr, fromLogStr)

logToByteString :: LogStr -> ByteString
logToByteString = fromLogStr

getDateGetter :: IO () -- ^ flusher
              -> IO (IO ByteString)
getDateGetter flusher = do
    (getter, updater) <- clockDateCacher






    return getter
