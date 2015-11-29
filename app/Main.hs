import System.IO
import System.Exit
import GetOpt
import System.Environment
import Control.Applicative
import Settings

main :: IO ()
main = do argv <- getArgs
          (flags, (id:files)) <- parseOptions argv defaults usage flags Version versionstr Help
          auth <- loginAuth =<< settingsExist =<< getOptionOr Config flags <$> settingsLocation
          putStrLn $ show files

          --the flags list contains all flags set, strs is a list of all non flag arguments
        --  return ()


versionstr = "0.0.0"
usage = "Usage: kattis [-fvh] [-c KATTISRC] [-m FILE] [-l LANG] PROBLEMID FILES ...\n"

data Flag
    = Force
    | Version
    | Verbose
    | Help
    | MainClass
    | Language
    | Config
    deriving (Eq, Enum, Show)

defaults :: OptionList Flag
defaults = []

flags :: OptionSpecs Flag
flags = makeOptions
    [ (Force,       'f', "force",   noArg, [], "Force submission without confirmation")
    , (Version,     'V', "version", noArg, [], "Displays version information")
    , (Verbose,     'v', "verbose", noArg, [], "Enables verbose output, useful for debugging")
    , (Help,        'h', "help",    noArg, [], "Displays this help message")
    , (MainClass,   'm', "main",    reqArg, "FILE", "Includes and selects FILE as the mainclass")
    , (Language,    'l', "lang",    reqArg, "LANG", "Overrides the default language detection with LANG")
    , (Config,      'c', "conf",    reqArg, "FILE", "Location of kattisrc, with token, username and submissionurl")
    ]
