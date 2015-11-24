{-
                        Copyright © 2007, 2008 Dave Bayer.
                            All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer. Redistributions in binary
    form must reproduce the above copyright notice, this list of conditions and
    the following disclaimer in the documentation and/or other materials
    provided with the distribution. Neither the name of Dave Bayer nor
    the names of other contributors may be used to endorse or promote products
    derived from this software without specific prior written permission.

    This software is provided by the copyright holders and contributors "as is"
    and any express or implied warranties, including, but not limited to, the
    implied warranties of merchantability and fitness for a particular purpose
    are disclaimed. In no event shall the copyright owner or contributors be
    liable for any direct, indirect, incidental, special, exemplary, or
    consequential damages (including, but not limited to, procurement of
    substitute goods or services; loss of use, data, or profits; or business
    interruption) however caused and on any theory of liability, whether in
    contract, strict liability, or tort (including negligence or otherwise)
    arising in any way out of the use of this software, even if advised of the
    possibility of such damage.

-}

module GetOpt
    (OptionList,OptionSpecs,noArg,reqArg,optArg,makeOptions,parseOptions,
    isOption,getOption,getOptionOr)
where

import System.Console.GetOpt
    (getOpt,usageInfo,ArgOrder(Permute),OptDescr(..),ArgDescr(..))

import System.IO (stdout,stderr,hPutStr,hPutStrLn)

import System.Exit (ExitCode(..),exitWith)

type OptVal a = (a,String)
type ArgType a = a -> String -> ArgDescr (OptVal a)
type OptionList a = [OptVal a]
type OptionSpecs a = [OptDescr (OptVal a)]

noArg, reqArg, optArg :: ArgType a

noArg x _ = NoArg (x,"")

reqArg x s = ReqArg f s
    where f y = (x,y)

optArg x s = OptArg f s
    where f (Just y) = (x,y)
          f Nothing  = (x,"")

makeOptions :: [(a,Char,String,ArgType a,String,String)] -> OptionSpecs a
makeOptions xs = map f xs
    where f (g,c,s,h,t,m) = Option [c] [s] (h g t) m

parseOptions ::
    Eq a => [String] -> OptionList a -> String -> OptionSpecs a
    -> a -> String -> a
    -> IO (OptionList a,[String])

parseOptions argv defaults usage flags version versionStr help =
    case getOpt Permute flags argv of
        (args,files,[]) -> do
            if isOption version args
                then do hPutStr stdout versionStr
                        exitWith ExitSuccess -- Added by Emil Gedda 11-11-2015
                 else return ()
            if isOption help args
                then do hPutStr stdout (usageInfo usage flags)
                        exitWith ExitSuccess -- Added by Emil Gedda 11-11-2015
                else return ()
            return (args ++ defaults, files)
        (_,_,errs) -> do
            hPutStrLn stderr (concat errs ++ usageInfo usage flags)
            exitWith (ExitFailure 1)

isOption :: Eq a => a -> OptionList a -> Bool
isOption options assoc =  case lookup options assoc of
    Nothing -> False
    Just _  -> True

getOption :: Eq a => a -> OptionList a -> String
getOption options assoc = case lookup options assoc of
    Nothing -> ""
    Just s  -> s

getOptionOr :: Eq a => a -> OptionList a -> String -> String
getOptionOr options assoc def = case lookup options assoc of
    Nothing -> def
    Just "" -> def
    Just s  -> s