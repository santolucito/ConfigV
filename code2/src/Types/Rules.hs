{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass#-}

module Types.Rules where

import Types.Common
import Types.IR

import Prelude hiding (Ordering)
import           Data.Aeson
import           GHC.Generics     (Generic)

--TODO Strict or Lazy maps?
import qualified Data.Map.Strict as M
import qualified Data.Set        as S

-- | every instance of Learnable is a template of rules we can learn
--   instance provided in the Learners dir
class (Eq a, Show a) => Learnable a where
  -- | build a set of rules from a single IR
  -- these rules will have TotalTimes=1
  -- this used to be learn
  buildRelations :: IRConfigFile -> RuleDataMap a
  -- | once you have all the evidence, decide which rules are valid
  --   i.e. set the enabled flag on some
  --   this used to be merge
  resolve :: RuleDataMap a -> RuleDataMap a
  -- | is a rule relevant to the file we want to verify
  --   this used to be check
  isRelevant :: IRConfigFile -> a -> Bool

-- | A rule is the structure for tracking and merging evidence relations
--   We need to track how much evidence we have for the rule, against the rule, and how often we have seen the rule
data RuleData = RuleData NumEvidenceTrue NumEvidenceFalse TotalTimes Enabled 
  deriving (Eq,Show,Generic,ToJSON,FromJSON)
type RuleDataMap a = M.Map a RuleData

data RuleSet = RuleSet
  { missing  :: RuleDataMap KeywordCoor
  , order    :: RuleDataMap Ordering
  , intRel :: RuleDataMap IntRel
--  , typeErr  :: TypeMap ConfigQType
  } --deriving (Eq, Show, Generic)--, Typeable)

------------
-- The specific types of relations we want to learn
-- go below here
-----------

-- | these keywords should appear in the same file
-- TODO give explicit Eq instances to be used in merging
data KeywordCoor = KeywordCoor (Keyword,Keyword) 
  deriving (Eq, Show,Ord,Generic,ToJSON,FromJSON)

data Ordering = Ordering (Keyword,Keyword)
  deriving (Eq, Show,Ord,Generic,ToJSON,FromJSON)

data IntRel = IntRel (IRLine,IRLine,Formula)
  deriving (Eq, Show,Ord,Generic,ToJSON,FromJSON)

-- TODO actual formula here
type Formula = Int

type NumEvidenceTrue = Int
type NumEvidenceFalse= Int
type TotalTimes = Int
type Enabled = Bool
type AppearsThereshold = Int
type FrequencyThreshold = Double --between 0 and 1