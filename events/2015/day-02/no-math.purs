module NoMath where

import Prelude
import Effect (Effect)
import Effect.Console (logShow)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile)
import Text.Parsing.Parser.Combinators
import Text.Parsing.Parser.String
import Text.Parsing.Parser.Token
import Text.Parsing.Parser
import Data.Either

main :: Effect Unit
main = do
  input <- readTextFile UTF8 "../events/2015/day-02/input.txt"
  let result = hush $ runParser input $ many1 (sepBy digit (string "x"))
  logShow result
