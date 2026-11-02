import Control.Monad (unless)
import LExp
import System.IO
import System.Process (waitForProcess)
import Control.Exception

import LTypes
import qualified Lambek

import Parser
import PySupport

toPython :: LExp -> String
toPython (V x) = x
toPython (A f arg) = "(" ++ toPython f ++ ")(" ++ toPython arg ++ ")"
toPython (L x body) = "(lambda " ++ x ++ ": " ++ toPython body ++ ")"

showMeaning :: PythonHandle -> (LExp, [(Var, PythonCode)]) -> IO ()
showMeaning phandle (expr, meanings) = do
  let code = unlines $
        ["try:"] ++
        ["    " ++ v ++ " = (" ++ text meaning ++ ")" | (v, meaning) <- meanings] ++
        [ "    print(" ++ toPython expr ++ ")"
        , "except Exception as error:"
        , "    print('Evaluation error:', error)"
        , ""
        ]
  result <- runPythonCode phandle (PCode code)
  putStrLn ("Sense [" ++ prettyLExp expr ++ "]: " ++ result)

closePython :: PythonHandle -> IO ()
closePython (hin, hout, herr, process) = do
  hClose hin
  _ <- waitForProcess process
  hClose hout
  hClose herr

repl :: Lexicon PythonCode -> PythonHandle -> IO ()
repl elx phandle = do
  putStr "> "
  eof <- isEOF
  unless eof $ do
    line <- getLine
    let ws = map Lambek.standardize (words line)
    if words line == [":quit"] || words line == [":q"]
      then putStrLn "Goodbye!"
      else do
        if null ws then return () else do
          case Lambek.deriveSentence elx ws of
            [] -> putStrLn "That is not a well-formed sentence"
            [reading] -> showMeaning phandle reading
            readings -> do
              putStrLn "That sentence is ambiguous"
              mapM_ (showMeaning phandle) readings
        repl elx phandle

main :: IO ()
main = do
  hSetBuffering stdout NoBuffering
  elx <- getLex
  db <- getDB
  result <- try (bracket (launchPython db) closePython $ \phandle -> do
    putStrLn "Starting chat... (type :quit to exit)"
    repl elx phandle) :: IO (Either IOError ())
  case result of
    Left err -> putStrLn ("Python session error: " ++ show err)
    Right () -> return ()
  where
    getDB :: IO PythonCode
    getDB = do
      putStr "Facts about the world: "
      dname <- getLine
      mdb <- try (readFile dname) :: IO (Either IOError String)
      case mdb of
        Left err -> putStrLn ("Error loading file " ++ show err) >> getDB
        Right db -> return (PCode db)
      
    getLex :: IO (Lexicon PythonCode)
    getLex = do
      putStr "Lexicon file: "
      lname <- getLine
      res <- parseFile lexicon lname
      case res of
        Left err -> putStrLn ("Error loading file " ++ show err) >> getLex
        Right (Left err) -> putStrLn ("parse error at " ++ lname ++ ":" ++ show err) >> getLex
        Right (Right lex) -> return lex
