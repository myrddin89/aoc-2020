module Parsing where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Data.List (List(..), (:))

main :: Effect Unit
main = do
  log $ show $ parse "ciao"

parse :: String -> List String
parse _ = "ciao" : Nil
