{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE RecordWildCards #-}
{-# OPTIONS_GHC -fno-cse #-}

module ConfigV.Settings.Options where

import System.Console.CmdArgs

import ConfigV.Types.IR
import Control.Monad
import System.Exit

import ConfigV.Types.SMTRules

data Options
  = Learning {
    learnTarget :: FilePath
  , language :: Language
  , enableOrder :: Bool
  , enableCoarseGrain :: Bool
  , enableFineGrain :: Bool 
  , enableTypeRules :: Bool
  , enableSMT :: Bool
  , enableProbTypeInference :: Bool
  , cacheLocation :: FilePath
  , thresholdsPath :: FilePath
  , learnFileLimit :: Int
  , verbose :: Bool
  --, smtFilterCriteria :: SMTFormula -> Bool -- ^ TODO should this be something i can specify with a string on the command line?
  }

  | Verification {
    verifyTarget :: FilePath
  , cacheLocation :: String
  , sortWithRuleGraph :: Bool
  , language :: Language
  , verbose :: Bool
  } deriving (Show, Data, Typeable)

mode = cmdArgsMode $ modes [learnConfig, verifyConfig] &= program "ConfigV" &= summary "ConfigV v0.0.1"

cachedRulesDefaultLoc = "cachedRules.json"

checkSettings Learning{..} = do
  when (learnTarget == "") $ die "ConfigV: No learning target provided. See help."

learnConfig = Learning {
    learnTarget = "" &= help "The files to learn from" &= typDir
  , language = CSV &= help ("The language of the verification files, select from "++(show allLanguages))
  , enableOrder = False
  , enableCoarseGrain = False
  , enableFineGrain = False
  , enableTypeRules = False
  , enableSMT = False
  , enableProbTypeInference = False
  , cacheLocation = cachedRulesDefaultLoc &= 
      help ("The location where the cache of learned rules wll be written. Default: "++ cachedRulesDefaultLoc) &= typFile
  , thresholdsPath = def &= help "The location from which to read threshold values (unsupported)" &= typFile
  , learnFileLimit = 9999 &= help "the limit for files to be used in learning. useful for benchmarking learning times" &= typ "INT"
  , verbose = False
  --, smtFilterCriteria = containsIsSetTo
  } &=
    help "Use Predicate Rule Learning to learn rules"

defaultCheckConfig = learnConfig {
    enableOrder = True
  , enableCoarseGrain = True
  , enableFineGrain = True
  , enableTypeRules = True
  , enableSMT = True
  , enableProbTypeInference = True
  , cacheLocation = cachedRulesDefaultLoc 
  } 

verifyConfig = Verification {
    verifyTarget = def &= help "The files to verify." &= typDir
  , cacheLocation = cachedRulesDefaultLoc &= 
      help ("The location where the cache of learned rules wll be read from. Default: "++ cachedRulesDefaultLoc) &= typFile
  , sortWithRuleGraph = def &= help "Turn on rule graph sorting, rerun the rule graph builder for each training set for best results (see graphAnalysis/README)"
  , language = CSV &= help ("The language of the verification files, select from "++(show allLanguages))
  , verbose = False
  } &=
    help "Verify Configuration files from a set of learned rules"

