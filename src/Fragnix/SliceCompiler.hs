module Fragnix.SliceCompiler where

import Fragnix.Slice (
    Slice(Slice),SliceID,Language(Language),Fragment(Fragment),Use(Use),
    Reference(OtherSlice,Builtin),
    UsedName(ValueName,TypeName,ConstructorName),Name(Identifier,Operator),
    readSliceDefault)
import Fragnix.Instances (
    loadInstances,instancesPath)

import Prelude hiding (writeFile)

import Language.Haskell.Exts.Syntax (
    Module(Module),ModuleName(ModuleName),ModulePragma(LanguagePragma),
    Decl(InstDecl,DataDecl,GDataDecl,PatBind,FunBind,ForImp,DerivDecl,TypeSig,DataInsDecl,GDataInsDecl),
    Name(Ident,Symbol),QName(UnQual),
    ExportSpec(EThingAll),
    ImportDecl(ImportDecl,importSrc,importModule),ImportSpec(IVar,IAbs,IThingWith),
    CName(ConName),Namespace(NoNamespace))
import Language.Haskell.Exts.SrcLoc (noLoc)
import Language.Haskell.Exts.Parser (
    parseModuleWithMode,ParseMode(parseFilename,extensions,fixities),defaultParseMode,
    fromParseResult)
import Language.Haskell.Exts.Fixity (baseFixities)
import Language.Haskell.Exts.Pretty (prettyPrint)
import Language.Haskell.Exts.Extension (parseExtension)

import Data.Text.IO (writeFile)
import Data.Text (Text,pack,unpack)

import System.FilePath ((</>),(<.>))
import System.Directory (createDirectoryIfMissing,doesFileExist)
import System.Process (rawSystem)
import System.Exit (ExitCode)
import Control.Exception (SomeException,catch,evaluate)

import Data.Map (Map)
import qualified Data.Map as Map (fromList,lookup)
import Control.Monad (forM,forM_,unless)
import Data.Maybe (mapMaybe)
import Data.List (union)
import Data.Char (isDigit)


-- | Compile the slice with the given slice ID to an executable program.
-- Assumes that the slice contains a declaration for some 'main :: IO ()'.
sliceCompilerMain :: SliceID -> IO ExitCode
sliceCompilerMain sliceID = do
    createDirectoryIfMissing True sliceModuleDirectory
    writeSliceModuleTransitive sliceID
    writeInstanceModule
    rawSystem "ghc" [
        "-o","main",
        "-ifragnix/temp/compilationunits",
        "-main-is",sliceModuleName sliceID,
        sliceModulePath sliceID]


-- | Compile the slice with the given slice ID. Set verbosity to zero and
-- turn all warnings off.
sliceCompiler :: SliceID -> IO ExitCode
sliceCompiler sliceID = do
    createDirectoryIfMissing True sliceModuleDirectory
    writeSliceModuleTransitive sliceID
    writeInstanceModule
    rawSystem "ghc" ["-v0","-w","-ifragnix/temp/compilationunits",sliceModulePath sliceID]


-- | Assemble a compilable module from a single slice.
assemble :: Slice -> Module
assemble slice@(Slice sliceID _ _ _) =
    let decls = sliceDecls slice
        moduleName = ModuleName (sliceModuleName sliceID)
        pragmas = slicePragmas slice
        imports = sliceImports slice
        -- We need an export list to export the data family even
        -- though a slice only contains the data family instance
        exports = dataFamilyInstanceExports decls imports
    in Module noLoc moduleName pragmas Nothing exports imports decls


-- | The language pragmas we need to compile a slice. We also add an
-- 'NoImplicitPrelude' to make sure we caught all necessary imports and
-- to avoid name clashes.
slicePragmas :: Slice -> [ModulePragma]
slicePragmas (Slice _ (Language ghcextensions) _ _) =
    [LanguagePragma noLoc languagepragmas] where
        languagepragmas =
            [Ident "NoImplicitPrelude"] ++
            (map (Ident . unpack) ghcextensions)


-- | The imports for a slice. Each use corresponds to an import.
sliceImports :: Slice -> [ImportDecl]
sliceImports (Slice _ _ _ uses) = map useImport uses


-- | The declarations in a slice. The slice contains a fragment.
-- A fragment is a list of declarations represented textually. In order
-- to reparse them we need to know the language extensions.
sliceDecls :: Slice -> [Decl]
sliceDecls (Slice sliceID language fragment _) = decls where
    Fragment declarations = fragment
    Language ghcextensions = language
    decls = map (parseDeclaration sliceID ghcextensions) declarations


-- | Parse a declaration. We also need the slice ID for error messages and
-- (a textual representation of) the list of language extensions.
parseDeclaration :: SliceID -> [Text] -> Text -> Decl
parseDeclaration sliceID ghcextensions declaration = decl where
    Module _ _ _ _ _ _ [decl] = fromParseResult (parseModuleWithMode parseMode (unpack declaration))
    parseMode = defaultParseMode {
        parseFilename = show sliceID,
        extensions = map (parseExtension . unpack) ghcextensions,
        fixities = Just baseFixities}

useImport :: Use -> ImportDecl
useImport (Use maybeQualification usedName symbolSource) =
    let moduleName = case symbolSource of
            OtherSlice sliceID -> ModuleName (sliceModuleName sliceID)
            Builtin originalModule -> ModuleName (unpack originalModule)
        qualified = maybe False (const True) maybeQualification
        maybeAlias = fmap (ModuleName . unpack) maybeQualification
        importSpec = case usedName of
            ValueName name -> [IVar NoNamespace (toName name)]
            TypeName name -> [IAbs (toName name)]
            ConstructorName typeName name ->
                [IThingWith (toName typeName) [ConName (toName name)]]
        toName (Identifier name) = Ident (unpack name)
        toName (Operator name) = Symbol (unpack name)

    in ImportDecl noLoc moduleName qualified False False Nothing maybeAlias (Just (False,importSpec))


-- | We export every type that we import in a data family instance slice
dataFamilyInstanceExports :: [Decl] -> [ImportDecl] -> Maybe [ExportSpec]
dataFamilyInstanceExports [DataInsDecl _ _ _ _ _] imports = Just (do
    ImportDecl _ _ _ _ _ _ _ (Just (False,[IAbs typeName])) <- imports
    return (EThingAll (UnQual typeName)))
dataFamilyInstanceExports [GDataInsDecl _ _ _ _ _ _] imports = Just (do
    ImportDecl _ _ _ _ _ _ _ (Just (False,[IAbs typeName])) <- imports
    return (EThingAll (UnQual typeName)))
dataFamilyInstanceExports _ _ = Nothing

sliceHSBootModule :: Slice -> Module
sliceHSBootModule slice = bootModule (assemble slice)

-- | Create a boot module from an ordinary module
-- WORKAROUND: We can not put data family constructors into hs-boot files.
-- https://ghc.haskell.org/trac/ghc/ticket/8441
-- hs-boot files contain source imports for constructors.
-- We remove constructor imports from hs-boot files that contain only instances.
bootModule :: Module -> Module
bootModule (Module srcloc moduleName pragmas warnings exports imports (decls@[InstDecl _ _ _ _ _ _ _])) =
    Module srcloc moduleName pragmas warnings exports bootImports bootDecls where
        bootImports = mapMaybe bootInstanceImport imports
        bootDecls = concatMap bootDecl decls
bootModule (Module srcloc moduleName pragmas warnings exports imports decls) = 
    Module srcloc moduleName pragmas warnings exports bootImports bootDecls where
        bootImports = mapMaybe bootImport imports
        bootDecls = concatMap bootDecl decls

-- | Remove all source imports and make all other imports source except those
-- from builtin modules.
bootImport :: ImportDecl -> Maybe ImportDecl
bootImport importDecl
    | importSrc importDecl = Nothing
    | isSliceModule (importModule importDecl) = Just (importDecl {importSrc = True})
    | otherwise = Just importDecl

-- | Remove all source imports and make all other imports source except those
-- from builtin modules. Also remove constructor imports
bootInstanceImport :: ImportDecl -> Maybe ImportDecl
bootInstanceImport importDecl
    | importSrc importDecl = Nothing
    | isConstructorImport importDecl = Nothing
    | isSliceModule (importModule importDecl) = Just (importDecl {importSrc = True})
    | otherwise = Just importDecl

-- | Remove instance bodies, make derived instances into bodyless instance decls
bootDecl :: Decl -> [Decl]
bootDecl (InstDecl srcloc overlap typeVars context classname types _) =
    [InstDecl srcloc overlap typeVars context classname types []]
bootDecl (DataDecl srcloc dataOrNew context dataname typeVars constructors _) =
    [DataDecl srcloc dataOrNew context dataname typeVars constructors []]
bootDecl (GDataDecl srcloc dataOrNew context name typeVars kind constructors _) =
    [GDataDecl srcloc dataOrNew context name typeVars kind constructors []]
bootDecl (DerivDecl srcloc overlap typeVars context classname types) =
    [InstDecl srcloc overlap typeVars context classname types []]
bootDecl (PatBind _ _ _ _) =
    []
bootDecl (FunBind _) =
    []
bootDecl (ForImp srcloc _ _ _ name typ) =
    [TypeSig srcloc [name] typ]
bootDecl (DataInsDecl _ _ _ _ _) =
    []
bootDecl (GDataInsDecl _ _ _ _ _ _) =
    []
bootDecl decl = [decl]

-- | Directory for generated modules
sliceModuleDirectory :: FilePath
sliceModuleDirectory = "fragnix" </> "temp" </> "compilationunits"

-- | The path for the module generated for the slice with the given ID
sliceModulePath :: SliceID -> FilePath
sliceModulePath sliceID = sliceModuleDirectory </> sliceModuleFileName sliceID

sliceModuleFileName :: SliceID -> FilePath
sliceModuleFileName sliceID = sliceModuleName sliceID <.> "hs"

sliceHSBootPath :: SliceID -> FilePath
sliceHSBootPath sliceID = sliceModuleDirectory </> sliceHSBootFileName sliceID

sliceHSBootFileName :: SliceID -> FilePath
sliceHSBootFileName sliceID = sliceModuleName sliceID <.> "hs-boot"

sliceModuleName :: SliceID -> String
sliceModuleName sliceID = "F" ++ show sliceID

-- | Is the module name from a fragnix generated module
isSliceModule :: ModuleName -> Bool
isSliceModule (ModuleName ('F':rest)) = all isDigit rest
isSliceModule _ = False

-- | Does the import import a constructor
isConstructorImport :: ImportDecl -> Bool
isConstructorImport (ImportDecl _ _ _ _ _ _ _ (Just (False,[IThingWith _ _]))) = True
isConstructorImport _ = False

writeSliceModule :: Slice -> IO ()
writeSliceModule slice@(Slice sliceID _ _ _) = (do
    slicecontent <- evaluate (pack (prettyPrint (assemble slice)))
    writeFile (sliceModulePath sliceID) slicecontent)
        `catch` (print :: SomeException -> IO ())

-- | Write an hs-boot file that contains a stripped down version of the
-- slice's module. Used to break import cycles for instances. We need to
-- hackily add role annotations for GHC 7.8.3.
writeSliceHSBoot :: Slice -> IO ()
writeSliceHSBoot slice@(Slice sliceID _ _ _) = (do
    emptyslicecontent <- evaluate (pack (addRoleAnnotation (prettyPrint (sliceHSBootModule slice))))
    writeFile (sliceHSBootPath sliceID) emptyslicecontent)
        `catch` (print :: SomeException -> IO ())

-- | Write out the module file and an hs-boot file for the slice with the given ID
-- and all the slices it trasitively uses. The hs-boot file is unnecessary for
-- non-instance slices but generated anyway.
writeSliceModuleTransitive :: SliceID -> IO ()
writeSliceModuleTransitive sliceID = do
    exists <- doesSliceModuleExist sliceID
    unless exists (do
        slice <- readSliceDefault sliceID
        writeSliceModule slice
        forM_ (usedSlices slice) writeSliceModuleTransitive)

usedSlices :: Slice -> [SliceID]
usedSlices (Slice _ _ _ uses) = [sliceID | Use _ _ (OtherSlice sliceID) <- uses]

doesSliceModuleExist :: SliceID -> IO Bool
doesSliceModuleExist sliceID = doesFileExist (sliceModulePath sliceID)


-- | Take a list of slices that all contain at least one instance (and
-- should contain exactly one instance) and generate a module with all
-- these instance declarations.
assembleInstances :: [Slice] -> Module
assembleInstances instanceSlices =
    Module noLoc (ModuleName instancesModuleName) pragmas Nothing Nothing imports decls where
        pragmas = unions (map slicePragmas instanceSlices)
        imports = unions (map sliceImports instanceSlices)
        decls = concatMap sliceDecls instanceSlices


-- | Take the union of a list of lists as if they were sets.
unions :: (Eq a) => [[a]] -> [a]
unions = foldr union []


-- | Write out the module that contains all instance declarations to
-- its special location. Load the slice IDs of instances first.
writeInstanceModule :: IO ()
writeInstanceModule = (do
    instanceIDs <- loadInstances instancesPath
    instances <- forM instanceIDs readSliceDefault
    instancesModuleFile <- evaluate (pack (prettyPrint (assembleInstances instances)))
    writeFile instancesModulePath instancesModuleFile)
        `catch` (print :: SomeException -> IO ())

-- | The path for the module generated for the slice with the given ID
instancesModulePath :: FilePath
instancesModulePath = sliceModuleDirectory </> instancesModuleName <.> "hs"

instancesModuleName :: String
instancesModuleName = "FINSTANCES"

addRoleAnnotation :: String -> String
addRoleAnnotation code = case Map.lookup (last (lines code)) roleAnnotations of
    Nothing -> code
    Just roleAnnotation -> unlines [
        "{-# LANGUAGE RoleAnnotations #-}",
        code,
        roleAnnotation]

roleAnnotations :: Map String String
roleAnnotations = Map.fromList [
    ("data UArray i e = UArray !i !i !Int ByteArray#",
        "type role UArray representational phantom"),
    ("data StorableArray i e = StorableArray !i !i Int !(ForeignPtr e)",
        "type role StorableArray representational phantom"),
    ("data STUArray s i e = STUArray !i !i !Int (MutableByteArray# s)",
        "type role STUArray nominal representational phantom"),
    ("newtype IOUArray i e = IOUArray (STUArray RealWorld i e)",
        "type role IOUArray representational phantom"),
    ("newtype Constant a b = Constant{getConstant :: a}",
        "type role Constant representational phantom"),
    ("                           {-# UNPACK #-} !(ForeignPtr a)",
        "type role MVector phantom phantom"),
    ("                           {-# UNPACK #-} !(MutableByteArray s)",
        "type role MVector nominal phantom"),
    ("                       {-# UNPACK #-} !(ForeignPtr a)",
        "type role Vector phantom"),
    ("                       {-# UNPACK #-} !ByteArray",
        "type role Vector phantom")]

