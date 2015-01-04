module Fragnix.ModuleSlices where

import Fragnix.Environment (Environment)
import Fragnix.Slice (Slice)

import qualified Language.Haskell.Exts as UnAnn (
    QName(Qual,UnQual),ModuleName(ModuleName))
import Language.Haskell.Exts.Annotated.Simplify (sModuleName)
import Language.Haskell.Exts.Annotated (
    Module,Decl(..),parseFile,ParseResult(ParseOk,ParseFailed),
    SrcSpan,srcInfoSpan,ModuleName,
    prettyPrint,Language(Haskell2010),Extension)
import Language.Haskell.Names (
    Symbol(NewType,Constructor),Error,Scoped(Scoped),
    computeInterfaces,annotateModule,
    NameInfo(GlobalSymbol,RecPatWildcard),ppError)
import Language.Haskell.Names.SyntaxUtils (
    getModuleDecls,getModuleName,getModuleExtensions)
import Language.Haskell.Names.ModuleSymbols (
    getTopDeclSymbols)
import qualified Language.Haskell.Names.GlobalSymbolTable as GlobalTable (
    empty)
import Distribution.HaskellSuite.Modules (
    MonadModule(..),ModuleInfo,modToString)

moduleSlices :: [Module (Scoped SrcSpan)] -> Environment -> ([Slice],Environment)
moduleSlices modules environment = (slices,environment') where
    slices = undefined
    environment' = undefined

type DeclarationID = Int

