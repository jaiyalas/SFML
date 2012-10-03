{-# LANGUAGE CPP, ForeignFunctionInterface #-}
module SFML.System.Sleep
(
    sfSleep
)
where


import SFML.System.Time

import Foreign.Marshal.Utils (with)
import Foreign.Ptr (Ptr)


-- | Make the current thread sleep for a given duration.
--
-- sfSleep is the best way to block a program or one of its
-- threads, as it doesn't consume any CPU power.

sfSleep :: SFTime -> IO ()
sfSleep t = with t sfSleep_helper

foreign import ccall "sfSleep_helper"
    sfSleep_helper :: Ptr SFTime -> IO ()

--CSFML_SYSTEM_API void sfSleep(sfTime duration);
