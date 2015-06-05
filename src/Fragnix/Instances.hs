module Fragnix.Instances where

import Fragnix.Slice (SliceID)

import Data.Aeson (encode,decode)
import qualified Data.ByteString.Lazy as ByteString (readFile,writeFile)
import System.Directory (createDirectoryIfMissing)
import System.FilePath (dropFileName,(</>))

import Data.Maybe (fromMaybe)

type Instances = [SliceID]

loadInstances :: FilePath -> IO Instances
loadInstances path = do
    instancesfile <- ByteString.readFile path
    return (fromMaybe (error "Failed to parse instances") (decode instancesfile))

persistInstances :: FilePath -> Instances -> IO ()
persistInstances path instances = do
    createDirectoryIfMissing True (dropFileName path)
    ByteString.writeFile path (encode instances)

instancesPath :: FilePath
instancesPath = "fragnix" </> "instances"
