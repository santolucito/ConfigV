module Main where

import           ConfigV
import qualified GHC.IO.Encoding       as G
import           System.IO
import           System.Exit

main = do
  G.setLocaleEncoding utf8
  G.setFileSystemEncoding utf8
  G.setForeignEncoding utf8  
 
  executeLearning settings csvThresholds
  actualResults   <- readFile cachedRulesDefaultLoc
 
  putStrLn actualResults

settings = learnConfig {
        learnTarget = "Datasets/antonDumpCSV/"
      , enableMissing = False
      , enableKeyvalkey = True
      , verbose = True
      , learnFileLimit = 40
      }

csvThresholds = Left $ defaultThresholds {
        keyValKeyCoorSupport = 4
      , keyValKeyCoorConfidence = 0
      }


