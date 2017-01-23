{-# LANGUAGE OverloadedStrings #-}

module Convert where

import Types.IR
import Types.Common


import qualified Data.Text as T
import qualified Data.Map as M
import Control.Monad

--import Data.List.Unique as L

import Debug.Trace

import Learners.Common
-- | why would i want to do this?
{-addConfigType :: TypeMap -> (Keyword,Val) -> IRLine
addConfigType tyMap (keyword,value) =
case M.lookup keyword tyMap of
Just configType -> IRLine{..}
Nothing -> IRLine{configType = emptyConfigQType,..}-}

-- | Main function of this file - translate configFile to intermediate rep

-- | If the user wants to give hints to how to parse a config file based on filetype they go here
convert :: ConfigFile Language -> [IRLine] --[(Keyword,Val)]
convert (f, t, l) =
  let
    noComments = (map (stripComment l) $ T.lines t)
    noEmpty = filter (not. T.null) noComments
    noEmptyAsKV = map seperateVals noEmpty
    noDups = makeUniq l noEmptyAsKV
  in
    --NB replace _ with - in keywords
    map (\(k,v)-> IRLine{keyword=(T.replace "_" "-" k),value=v}) noDups 
    

makeUniq :: Language -> [(Keyword,Val)] -> [(Keyword,Val)]
makeUniq lang ls = case lang of
  MySQL ->
    let
      f _ [] = []
      f header (x:xs) =
        --if (fst x==snd x) && T.isInfixOf "[" (fst x) then f x xs else (T.append (fst x) (fst header),snd x) : f header xs
        if T.isInfixOf "[" (fst x) then x:f x xs else (T.append (fst x) (fst header),snd x) : f header xs
    in
      f (head ls) ls

-- TODO strip "set-variable ="
stripComment :: Language -> T.Text -> T.Text
stripComment l t = case l of
  MySQL ->  if any ((flip T.isInfixOf) t) ["<%","%>i","{%","%}"] 
            then ""
            else T.takeWhile (\x-> x/='#' && x/=';') t
  HTTPD -> T.takeWhile  (/=';') t

-- | for now we are just using spaces and = to seperate keywords and values
--   if no delim, then leave value as ""
seperateVals :: T.Text -> (Keyword,Val)
seperateVals t =
  let
    hasDelim = any isDelimeter $ T.unpack t
    ts = T.split isDelimeter (T.strip t)
    isDelimeter c = (c=='=') -- || (c==' ')
    rmSetVar = (T.dropWhile (=='=')). T.strip. fst. T.breakOn "set-variable"
    clean = rmSetVar. T.toLower. T.strip
  in
    if hasDelim
    then (clean $ head ts, clean$ last ts)
    else (clean t,"")
