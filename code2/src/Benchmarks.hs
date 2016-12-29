{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}

module Benchmarks where

import           Settings
import           Types.Errors
import           Types.Rules
import           Types.IR

import qualified Data.Text        as T
import qualified Data.Text.IO     as T
import           System.Directory
import           System.IO.Unsafe


learnTarget = case Settings.pROBRULES of
    Settings.Test -> genSet "testLearn/"
    Settings.NonProb -> genSet "dataset/correctMySQL/"
    Settings.Prob -> genSet "dump/MySQL/"
  where
    genSet s =
      map (\x -> (u $ T.readFile (s++x), MySQL))
      (u (listDirectory s))

verificationTargets :: [FilePath]
verificationTargets = if Settings.bENCHMARKS
    then benchmarkFiles
    else userFiles
  where
    userFiles = map ("user/"++) $ u $ listDirectory "user"
    benchmarkFiles = map getFileName $ concat benchmarks

benchmarks :: [ErrorReport]
benchmarks = case Settings.pROBRULES of
  Test -> testBenchSet
  NonProb -> group2 ++ group3 ++ group4 ++ group5
  Prob -> newSet --learnSetBench -- newSet--group2 -- ++ group4 ++ group5 -- ++ group6

u = unsafePerformIO
getFileName = fst . errLoc1

makeError (errLoc1,errLoc2,errIdent) =
  Error {errMsg="Spec",..}

newSet :: [ErrorReport]
newSet = map (map makeError) [
    [(("../OSDI/inject/correlation/error1.cnf","long_query_time[mysqld]"),("../OSDI/inject/correlation/error1.cnf","interactive_timeout[mysqld]"),INTREL)]
  , [(("../OSDI/inject/correlation/error2.cnf","max_allowed_packet[mysqldump]"),("../OSDI/inject/correlation/error2.cnf","key_buffer_size[myisamchk]"),INTREL)]
  , [(("../OSDI/inject/correlation/error3.cnf","thread_cache_size[mysqld]"),("../OSDI/inject/correlation/error3.cnf","table_cache[mysqld]"),INTREL)]

  , [(("../OSDI/inject/missing/error1.cnf","read_buffer[isamchk]"),("../OSDI/inject/missing/error1.cnf","write_buffer[isamchk]"),MISSING)]
  , [(("../OSDI/inject/missing/error2.cnf","read_buffer[myisamchk]"),("../OSDI/inject/missing/error2.cnf","write_buffer[myisamchk]"),MISSING)]

  , [(("../OSDI/inject/ordering/error1.cnf","datadir[mysqld]"),("../OSDI/inject/ordering/error1.cnf","basedir[mysqld]"),ORDERING)]
  , [(("../OSDI/inject/ordering/error2.cnf","tmpdir[mysqld]"),("../OSDI/inject/ordering/error2.cnf","basedir[mysqld]"),ORDERING)]
  , [(("../OSDI/inject/ordering/error3.cnf","basedir[mysqld]"),("../OSDI/inject/ordering/error3.cnf","pid-file[mysqld]"),ORDERING)]

  ]

newSet2 :: [ErrorReport]
newSet2 = map (map makeError) [
    [(("../OSDI/data/missing/case1","set_timeout[mysqld]"),("../OSDI/data/missing/case1","wait_timeout[mysqld]"),MISSING)]
  , [(("../OSDI/data/missing/case2","innodb_force_recovery[mysqld]"),("../OSDI/data/missing/case2","innodb_strict_mode[mysqld]"),MISSING)]

  , [(("../OSDI/data/typeError/case1","max_connections[mysqld]"),("../OSDI/data/typeError/case1","max_connections[mysqld]"),TYPE)]
  , [(("../OSDI/data/typeError/case2","innodb_data_file_path[mysqld]"),("../OSDI/data/typeError/case2","innodb_data_file_path[mysqld]"),TYPE)]

  , [(("../OSDI/data/correlation/case1","key_buffer_size[mysqld]"),("../OSDI/data/correlation/case1","sort_buffer_size[mysqld]"),INTREL)]
  , [(("../OSDI/data/correlation/case2","key_buffer_size[mysqld]"),("../OSDI/data/correlation/case2","join_buffer_size[mysqld]"),INTREL)]
  ]


cavAE_benchmarks =
    group2 ++ group3 ++ group4 ++ group5

group2 :: [ErrorReport]
group2 = map (map makeError) [
    [(("dataset/group2-entry-missing/error","port[client]"),("dataset/group2-entry-missing/error","socket[client]"),MISSING)]
  , [(("dataset/group2-entry-missing/error2","port[client]"),("dataset/group2-entry-missing/error2","socket[mysqld]"),MISSING)]
  , [(("dataset/group2-entry-missing/error3","port[client]"),("dataset/group2-entry-missing/error3","socket[mysqld]"),MISSING)]
  , [(("dataset/group2-entry-missing/error4","port[client]"),("dataset/group2-entry-missing/error4","socket[mysqld]"),MISSING)]
  , [(("dataset/group2-entry-missing/error5","socket[mysqld]"),("dataset/group2-entry-missing/error5","socket[mysqld]"),MISSING)]
  ]

group3 :: [ErrorReport]
group3 = map (map makeError) [
    [(("dataset/group3-path-type/error","general_log[mysqld]"),("dataset/group3-path-type/error","general_log[mysqld]"),TYPE)]
  , [(("dataset/group3-path-type/error2","query_cache_type[mysqld]"),("dataset/group3-path-type/error2","query_cache_type[mysqld]"),TYPE)]
  , [(("dataset/group3-path-type/error3","innodb_flush_log_at_trx_commit[wampmysqld]"),("dataset/group3-path-type/error3","innodb_flush_log_at_trx_commit[wampmysqld]"),TYPE)]
  , [(("dataset/group3-path-type/error4","character-set-server[mysqld]"),("dataset/group3-path-type/error4","character-set-server[mysqld]"),TYPE)]
  , [(("dataset/group3-path-type/error5","innodb_strict_mode[mysqld]"),("dataset/group3-path-type/error5","innodb_strict_mode[mysqld]"),TYPE)]
  ]

group4 :: [ErrorReport]
group4 = map (map makeError) [
    [(("dataset/group4-ordering/error_mysql","portport"),("dataset/group4-ordering/error_mysql","[client]"),ORDERING)]
  , [(("dataset/group4-ordering/error2","datadir[wampmysqld]"),("dataset/group4-ordering/error2","log-error[wampmysqld]"),ORDERING)]
  , [(("dataset/group4-ordering/error3","innodb_file_format_check[mysqld]"),("dataset/group4-ordering/error3","innodb_strict_mode[mysqld]"),ORDERING)]
  , [(("dataset/group4-ordering/error4","innodb_flush_log_at_trx_commit[wampmysqld]"),("dataset/group4-ordering/error4","innodb_data_home_dir[wampmysqld]"),ORDERING)]
  , [(("dataset/group4-ordering/error5","innodb_file_format_check[mysqld]"),("dataset/group4-ordering/error5","innodb_data_home_dir[mysqld]"),ORDERING)]
  ]

group5 :: [ErrorReport]
group5 = map (map makeError) [
    [(("dataset/group5-value-correlation/error","max_allowed_packet[wampmysqld"),("dataset/group5-value-correlation/error","key_buffer[wampmysqld]"),INTREL)]
  , [(("dataset/group5-value-correlation/error2","max_allowed_packet[wampmysqld]"),("dataset/group5-value-correlation/error2","key_buffer[wampmysqld]"),INTREL)]
  , [(("dataset/group5-value-correlation/error3","max_connections[mysqld]"),("dataset/group5-value-correlation/error3","connection_buffer[mysqld]"),INTREL)]
  , [(("dataset/group5-value-correlation/error4","max_allowed_packet[mysqldump]"),("dataset/group5-value-correlation/error4","key_buffer[mysqldump]"),INTREL)]
  , [(("dataset/group5-value-correlation/error5","key_buffer[isamchk]"),("dataset/group5-value-correlation/error5","sort_buffer_size[isamchk]"),INTREL)]
  ]

group6 :: [ErrorReport]
group6 = map (map makeError) [
    [(("dataset/realWorld/error1.cnf","max_allowed_packet[wampmysqld]"),("dataset/realWorld/error1.cnf","key_buffer[wampmysqld]"),INTREL)]
  , [(("dataset/realWorld/error2.cnf","max_allowed_packet[wampmysqld]"),("dataset/realWorld/error2.cnf","key_buffer[wampmysqld]"),INTREL)]
  , [(("dataset/realWorld/error3.cnf","max_connections[mysqld]"),("dataset/realWorld/error3.cnf","connection_buffer[mysqld]"),INTREL)]
  , [(("dataset/realWorld/error4.cnf","max_allowed_packet[mysqldump]"),("dataset/realWorld/error4.cnf","key_buffer[mysqldump]"),INTREL)]
  , [(("dataset/realWorld/error5.cnf","key_buffer[isamchk]"),("dataset/realWorld/error5.cnf","sort_buffer_size[isamchk]"),INTREL)]
  ]

testBenchSet :: [ErrorReport]
testBenchSet = map (map makeError) [
    [(("dataset/group5-value-correlation/test","a[mysqld]"),("dataset/group5-value-correlation/test","b[mysqld]"),INTREL)]
  ]