module ReportRepair where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile)
import Text.Parsing.CSV (makeParsers)
import Text.Parsing.Parser (runParser)

input_file :: Effect String
input_file = readTextFile UTF8 "../events/2020/day-01/input.txt"

parser = makeParsers '\x0' " " "\n"

main :: Effect Unit
main = do
  text <- input_file
  log $ show $ runParser text parser.file
