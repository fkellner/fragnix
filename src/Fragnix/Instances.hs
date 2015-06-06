module Fragnix.Instances where

import Fragnix.Slice (Slice(Slice),writeSlice,readSlice)

import System.Directory (createDirectoryIfMissing,getDirectoryContents,doesFileExist)
import System.FilePath ((</>))

import Control.Monad (forM,forM_,filterM)

type InstanceSlice = Slice

loadInstances :: FilePath -> IO [InstanceSlice]
loadInstances path = do
    createDirectoryIfMissing True path
    filenames <- getDirectoryContents path
    let slicePaths = map (\filename -> path </> filename) filenames
    existingSlicePaths <- filterM doesFileExist slicePaths
    forM existingSlicePaths readSlice

loadInstancesDefault :: IO [InstanceSlice]
loadInstancesDefault = loadInstances instancesDirectory

persistInstances :: FilePath -> [InstanceSlice] -> IO ()
persistInstances path instanceSlices = do
    createDirectoryIfMissing True instancesDirectory
    forM_ instanceSlices (\instanceSlice@(Slice sliceID _ _ _) ->
        writeSlice (path </> show sliceID) instanceSlice)

persistInstancesDefault :: [InstanceSlice] -> IO ()
persistInstancesDefault = persistInstances instancesDirectory

instancesDirectory :: FilePath
instancesDirectory = "fragnix" </> "instances"
