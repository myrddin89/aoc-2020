module NoMath where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile)

main :: Effect Unit
main = do
  log =<< readTextFile UTF8 "../events/2015/day-02/input.txt"
