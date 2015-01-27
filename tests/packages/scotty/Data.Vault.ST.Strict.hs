{-# LINE 1 "src/Data/Vault/ST/Strict.hs" #-}
# 1 "src/Data/Vault/ST/Strict.hs"
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
# 1 "src/Data/Vault/ST/Strict.hs"



-- | A persistent store for values of arbitrary types.
-- Variant for the 'ST' monad.
--
-- The 'Vault' type in this module is strict in both keys and values.

# 1 "src/Data/Vault/ST/ST.hs" 1
module Data.Vault.ST.Strict (
    -- * Vault
    Vault, Key,
    empty, newKey, lookup, insert, adjust, delete, union,

    -- * Locker
    Locker,
    lock, unlock,
    ) where

import Data.Monoid (Monoid(..))
import Prelude hiding (lookup)
import Control.Applicative hiding (empty)
import Control.Monad.ST
import Control.Monad.ST.Unsafe as STUnsafe

import Data.Unique.Really

{-
    The GHC-specific implementation uses  unsafeCoerce
    for reasons of efficiency.

    See  http://apfelmus.nfshost.com/blog/2011/09/04-vault.html
    for the second implementation that doesn't need to
    bypass the type checker.
-}


# 1 "src/Data/Vault/ST/backends/GHC.hs" 1
-- This implementation is specific to GHC
-- und uses  unsafeCoerce  for reasons of efficiency.
import GHC.Exts (Any)
import Unsafe.Coerce (unsafeCoerce)

import qualified Data.HashMap.Strict as Map
type Map = Map.HashMap

toAny :: a -> Any
toAny = unsafeCoerce

fromAny :: Any -> a
fromAny = unsafeCoerce

{-----------------------------------------------------------------------------
    Vault
------------------------------------------------------------------------------}
newtype Vault s = Vault (Map Unique Any)
newtype Key s a = Key Unique

newKey = STUnsafe.unsafeIOToST $ Key <$> newUnique

lookup (Key k) (Vault m) = fromAny <$> Map.lookup k m

insert (Key k) x (Vault m) = Vault $ Map.insert k (toAny x) m

adjust f (Key k) (Vault m) = Vault $ Map.adjust f' k m
    where f' = toAny . f . fromAny

delete (Key k) (Vault m) = Vault $ Map.delete k m

{-----------------------------------------------------------------------------
    Locker
------------------------------------------------------------------------------}
data Locker s = Locker !Unique !Any

lock (Key k) = Locker k . toAny

unlock (Key k) (Locker k' a)
  | k == k' = Just $ fromAny a
  | otherwise = Nothing
# 29 "src/Data/Vault/ST/ST.hs" 2




{-----------------------------------------------------------------------------
    Vault
------------------------------------------------------------------------------}

instance Monoid (Vault s) where
    mempty = empty
    mappend = union

-- | The empty vault.
empty :: Vault s
empty = Vault Map.empty

-- | Create a new key for use with a vault.
newKey :: ST s (Key s a)

-- | Lookup the value of a key in the vault.
lookup :: Key s a -> Vault s -> Maybe a

-- | Insert a value for a given key. Overwrites any previous value.
insert :: Key s a -> a -> Vault s -> Vault s

-- | Adjust the value for a given key if it's present in the vault.
adjust :: (a -> a) -> Key s a -> Vault s -> Vault s

-- | Delete a key from the vault.
delete :: Key s a -> Vault s -> Vault s

-- | Merge two vaults (left-biased).
union :: Vault s -> Vault s -> Vault s
union (Vault m) (Vault m') = Vault $ Map.union m m'

{-----------------------------------------------------------------------------
    Locker
------------------------------------------------------------------------------}

-- | Put a single value into a 'Locker'.
lock :: Key s a -> a -> Locker s

-- | Retrieve the value from the 'Locker'.
unlock :: Key s a -> Locker s -> Maybe a
# 9 "src/Data/Vault/ST/Strict.hs" 2