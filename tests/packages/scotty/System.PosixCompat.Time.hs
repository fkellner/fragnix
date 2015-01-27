{-# LINE 1 "src/System/PosixCompat/Time.hs" #-}
# 1 "src/System/PosixCompat/Time.hs"
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
# 1 "src/System/PosixCompat/Time.hs"
{-# LANGUAGE CPP #-}

{-|
This module makes the operations exported by @System.Posix.Time@
available on all platforms. On POSIX systems it re-exports operations from
@System.Posix.Time@, on other platforms it emulates the operations as far
as possible.
-}
module System.PosixCompat.Time (
      epochTime
    ) where



import System.Posix.Time

# 33 "src/System/PosixCompat/Time.hs"

