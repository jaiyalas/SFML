{-# LANGUAGE CPP, ForeignFunctionInterface #-}
module SFML.Graphics.RenderWindow
(
    createRenderWindow
,   renderWindowFromHandle
,   destroyRenderWindow
,   closeRenderWindow
,   isRenderWindowOpen
,   getRenderWindowSettings
,   pollRenderWindowEvent
,   waitRenderWindowEvent
,   getRenderWindowPosition
,   setRenderWindowPosition
,   getRenderWindowSize
,   setRenderWindowSize
,   setRenderWindowTitle
,   setRenderWindowIcon
,   setRenderWindowVisible
,   setRenderWindowMouseVisible
,   setRenderWindowVsync
,   setRenderWindowKeyRepeat
,   setRenderWindowActive
,   displayRenderWindow
,   setRenderWindowFramerateLimit
,   setRenderWindowJoystickThreshold
,   getRenderWindowSystemHandle
,   clearRenderWindow
,   setRenderWindowView
,   getRenderWindowView
,   getRenderWindowDefaultView
,   getRenderWindowViewport
,   convertCoords
,   drawSprite
,   drawText
,   drawShape
,   drawCircle
,   drawConvexShape
,   drawRectangle
,   drawVertexArray
,   drawPrimitives
,   drawPrimitives'
,   pushGLStates
,   popGLStates
,   resetGLStates
,   captureRenderWindow
)
where


import SFML.Graphics.Color
import SFML.Graphics.Rect
import SFML.Graphics.Types
import SFML.Graphics.PrimitiveType
import SFML.Graphics.RenderStates
import SFML.Graphics.Vertex
import SFML.Window.Event
import SFML.Window.VideoMode
import SFML.Window.WindowHandle
import SFML.Window.Window
import SFML.System.Vector2

import Foreign.C.String
import Foreign.C.Types
import Foreign.Marshal.Alloc (alloca)
import Foreign.Marshal.Array (withArray)
import Foreign.Marshal.Utils (with)
import Foreign.Ptr
import Foreign.Storable


-- | Construct a new render window.
createRenderWindow
    :: VideoMode   -- ^ Video mode to use
    -> String      -- ^ Window title
    -> WindowStyle -- ^ Window style
    -> Maybe ContextSettings -- ^ Creation settings ('Nothing' to use default values)
    -> IO RenderWindow

createRenderWindow vm title style ctx =
    withCAString title $ \ctitle ->
    with vm $ \ptrVM ->
    case ctx of
        Nothing -> sfRenderWindow_create_helper ptrVM ctitle (fromIntegral . fromEnum $ style) nullPtr
        Just c  -> with c $ sfRenderWindow_create_helper ptrVM ctitle (fromIntegral . fromEnum $ style)

foreign import ccall unsafe "sfRenderWindow_create_helper"
    sfRenderWindow_create_helper :: Ptr VideoMode -> CString -> CUInt -> Ptr ContextSettings -> IO RenderWindow

--CSFML_GRAPHICS_API sfRenderWindow* sfRenderWindow_create(sfVideoMode mode, const char* title, sfUint32 style, const sfContextSettings* settings);


-- | Construct a render window from an existing control.
renderWindowFromHandle
    :: WindowHandle -- ^ Platform-specific handle of the control
    -> Maybe ContextSettings -- ^ Creation settings ('Nothing' to use default values)
    -> IO RenderWindow

renderWindowFromHandle wm Nothing  = sfRenderWindow_createFromHandle wm nullPtr
renderWindowHandleFrom wm (Just c) = with c $ sfRenderWindow_createFromHandle wm

foreign import ccall unsafe "sfRenderWindow_createFromHandle"
    sfRenderWindow_createFromHandle :: WindowHandle -> Ptr ContextSettings -> IO RenderWindow

--CSFML_GRAPHICS_API sfRenderWindow* sfRenderWindow_createFromHandle(sfWindowHandle handle, const sfContextSettings* settings);


-- | Destroy an existing render window.
destroyRenderWindow :: RenderWindow -> IO ()
destroyRenderWindow = sfRenderWindow_destroy

foreign import ccall unsafe "sfRenderWindow_destroy"
    sfRenderWindow_destroy :: RenderWindow -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_destroy(sfRenderWindow* renderWindow);


-- | Close a render window.
--
-- This function does not destroy the window's internal data.
closeRenderWindow :: RenderWindow -> IO ()
closeRenderWindow = sfRenderWindow_close

foreign import ccall unsafe "sfRenderWindow_close"
    sfRenderWindow_close :: RenderWindow -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_close(sfRenderWindow* renderWindow);


-- | Tell whether or not a render window is opened.
isRenderWindowOpen :: RenderWindow -> IO Bool
isRenderWindowOpen = fmap (/=0) . sfRenderWindow_isOpen

foreign import ccall unsafe "sfRenderWindow_isOpen"
    sfRenderWindow_isOpen :: RenderWindow -> IO CInt

--CSFML_GRAPHICS_API sfBool sfRenderWindow_isOpen(const sfRenderWindow* renderWindow);


-- | Get the creation settings of a render window.
getRenderWindowSettings :: RenderWindow -> IO ContextSettings
getRenderWindowSettings wnd = alloca $ \ptr -> sfRenderWindow_getSettings_helper wnd ptr >> peek ptr

foreign import ccall unsafe "sfRenderWindow_getSettings_helper"
    sfRenderWindow_getSettings_helper :: RenderWindow -> Ptr ContextSettings -> IO ()

--CSFML_GRAPHICS_API sfContextSettings sfRenderWindow_getSettings(const sfRenderWindow* renderWindow);


-- | Get the event on top of event queue of a render window, if any, and pop it.
pollRenderWindowEvent :: RenderWindow -> IO (Maybe SFEvent)
pollRenderWindowEvent wnd =
    alloca $ \ptr -> do
    result <- sfRenderWindow_pollEvent wnd ptr
    case result of
        0 -> return Nothing
        _ -> peek ptr >>= return . Just

foreign import ccall unsafe "sfRenderWindow_pollEvent"
    sfRenderWindow_pollEvent :: RenderWindow -> Ptr SFEvent -> IO CInt

-- \return sfTrue if an event was returned, sfFalse if event queue was empty

--CSFML_GRAPHICS_API sfBool sfRenderWindow_pollEvent(sfRenderWindow* renderWindow, sfEvent* event);


-- | Wait for an event and return it.
--
-- Return 'Nothing' if an error occurs.
waitRenderWindowEvent :: RenderWindow -> IO (Maybe SFEvent)
waitRenderWindowEvent wnd =
    alloca $ \ptr -> do
    result <- sfRenderWindow_waitEvent wnd ptr
    case result of
        0 -> return Nothing
        _ -> peek ptr >>= return . Just

foreign import ccall unsafe "sfRenderWindow_waitEvent"
    sfRenderWindow_waitEvent :: RenderWindow -> Ptr SFEvent -> IO CInt

-- \return sfFalse if an error occured

--CSFML_GRAPHICS_API sfBool sfRenderWindow_waitEvent(sfRenderWindow* renderWindow, sfEvent* event);


-- | Get the position of a render window in pixels.
getRenderWindowPosition :: RenderWindow -> IO Vec2i
getRenderWindowPosition wnd = alloca $ \ptr -> sfRenderWindow_getPosition_helper wnd ptr >> peek ptr

foreign import ccall unsafe "sfRenderWindow_getPosition_helper"
    sfRenderWindow_getPosition_helper :: RenderWindow -> Ptr Vec2i -> IO ()

--CSFML_GRAPHICS_API sfVector2i sfRenderWindow_getPosition(const sfRenderWindow* renderWindow);


-- | Change the position of a render window on screen.
--
-- Only works for top-level windows
setRenderWindowPosition
    :: RenderWindow -- ^ Render window object
    -> Vec2i -- ^ New position in pixels
    -> IO ()

setRenderWindowPosition wnd pos = with pos $ sfRenderWindow_setPosition_helper wnd

foreign import ccall unsafe "sfRenderWindow_setPosition_helper"
    sfRenderWindow_setPosition_helper :: RenderWindow -> Ptr Vec2i -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_setPosition(sfRenderWindow* renderWindow, sfVector2i position);


-- | Get the size in pixels of the rendering region of a render window.
getRenderWindowSize :: RenderWindow -> IO Vec2u
getRenderWindowSize wnd = alloca $ \ptr -> sfRenderWindow_getSize_helper wnd ptr >> peek ptr

foreign import ccall unsafe "sfRenderWindow_getSize_helper"
    sfRenderWindow_getSize_helper :: RenderWindow -> Ptr Vec2u -> IO ()

--CSFML_GRAPHICS_API sfVector2u sfRenderWindow_getSize(const sfRenderWindow* renderWindow);


-- | Change the size of the rendering region of a render window.
setRenderWindowSize
    :: RenderWindow -- ^ Render window object
    -> Vec2u -- ^ New size, in pixels
    -> IO ()

setRenderWindowSize wnd size = with size $ sfRenderWindow_setSize_helper wnd

foreign import ccall unsafe "sfRenderWindow_setSize_helper"
    sfRenderWindow_setSize_helper :: RenderWindow -> Ptr Vec2u -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_setSize(sfRenderWindow* renderWindow, sfVector2u size);


-- | Change the title of a render window.
setRenderWindowTitle :: RenderWindow -> String -> IO ()
setRenderWindowTitle wnd title = withCAString title $ sfRenderWindow_setTitle wnd

foreign import ccall unsafe "sfRenderWindow_setTitle"
    sfRenderWindow_setTitle :: RenderWindow -> CString -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_setTitle(sfRenderWindow* renderWindow, const char* title);


-- | Change a render window's icon.
setRenderWindowIcon
    :: RenderWindow -- ^ Render window object
    -> Int -- ^ Icon width, in pixels
    -> Int -- ^ Icon height, in pixels
    -> Ptr a -- ^ Pointer to the pixels in memory. Format must be RGBA 32 bits
    -> IO ()

setRenderWindowIcon wnd w h pixels =
    sfRenderWindow_setIcon wnd (fromIntegral w) (fromIntegral h) pixels

foreign import ccall unsafe "sfRenderWindow_setIcon"
    sfRenderWindow_setIcon :: RenderWindow -> CUInt -> CUInt -> Ptr a -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_setIcon(sfRenderWindow* renderWindow, unsigned int width, unsigned int height, const sfUint8* pixels);


-- | Show or hide a render window.
setRenderWindowVisible :: RenderWindow -> Bool -> IO ()
setRenderWindowVisible wnd val = sfRenderWindow_setVisible wnd (fromIntegral . fromEnum $ val)

foreign import ccall unsafe "sfRenderWindow_setVisible"
    sfRenderWindow_setVisible :: RenderWindow -> CInt -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_setVisible(sfRenderWindow* renderWindow, sfBool visible);


-- | Show or hide the mouse cursor on a render window.
setRenderWindowMouseVisible :: RenderWindow -> Bool -> IO ()
setRenderWindowMouseVisible wnd val = sfRenderWindow_setMouseCursorVisible wnd (fromIntegral . fromEnum $ val)

foreign import ccall unsafe "sfRenderWindow_setMouseCursorVisible"
    sfRenderWindow_setMouseCursorVisible :: RenderWindow -> CInt -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_setMouseCursorVisible(sfRenderWindow* renderWindow, sfBool show);


-- | Enable or disable vertical synchronization on a render window.
setRenderWindowVsync :: RenderWindow -> Bool -> IO ()
setRenderWindowVsync wnd val = sfRenderWindow_setVerticalSyncEnabled wnd (fromIntegral . fromEnum $ val)

foreign import ccall unsafe "sfRenderWindow_setVerticalSyncEnabled"
    sfRenderWindow_setVerticalSyncEnabled :: RenderWindow -> CInt -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_setVerticalSyncEnabled(sfRenderWindow* renderWindow, sfBool enabled);


-- | Enable or disable automatic key-repeat for keydown events.
--
-- Automatic key-repeat is enabled by default
setRenderWindowKeyRepeat :: RenderWindow -> Bool -> IO ()
setRenderWindowKeyRepeat wnd val = sfRenderWindow_setKeyRepeatEnabled wnd (fromIntegral . fromEnum $ val)

foreign import ccall unsafe "sfRenderWindow_setKeyRepeatEnabled"
    sfRenderWindow_setKeyRepeatEnabled :: RenderWindow -> CInt -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_setKeyRepeatEnabled(sfRenderWindow* renderWindow, sfBool enabled);


-- | Activate or deactivate a render window as the current target for rendering.
--
-- Return 'True' if the operation was successful, 'False' otherwise.
setRenderWindowActive :: RenderWindow -> Bool -> IO Bool
setRenderWindowActive wnd val =
    fmap (toEnum . fromIntegral) $ sfRenderWindow_setActive wnd (fromIntegral . fromEnum $ val)

foreign import ccall unsafe "sfRenderWindow_setActive"
    sfRenderWindow_setActive :: RenderWindow -> CInt -> IO CInt

-- \return True if operation was successful, false otherwise

--CSFML_GRAPHICS_API sfBool sfRenderWindow_setActive(sfRenderWindow* renderWindow, sfBool active);


-- | Display a render window on screen.
displayRenderWindow :: RenderWindow -> IO ()
displayRenderWindow = sfRenderWindow_display

foreign import ccall unsafe "sfRenderWindow_display"
    sfRenderWindow_display :: RenderWindow -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_display(sfRenderWindow* renderWindow);


-- | Limit the framerate to a maximum fixed frequency for a render window.
setRenderWindowFramerateLimit
    :: RenderWindow -- ^ Render window object
    -> Int -- ^ Framerate limit, in frames per seconds (use 0 to disable limit)
    -> IO ()

setRenderWindowFramerateLimit wnd fps = sfRenderWindow_setFramerateLimit wnd (fromIntegral fps)

foreign import ccall unsafe "sfRenderWindow_setFramerateLimit"
    sfRenderWindow_setFramerateLimit :: RenderWindow -> CInt -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_setFramerateLimit(sfRenderWindow* renderWindow, unsigned int limit);


-- | Change the joystick threshold, ie. the value below which no move event will be generated.
setRenderWindowJoystickThreshold
    :: RenderWindow -- ^ Render window object
    -> Float -- ^ New threshold, in range [0, 100]
    -> IO ()

setRenderWindowJoystickThreshold = sfRenderWindow_setJoystickThreshold

foreign import ccall unsafe "sfRenderWindow_setJoystickThreshold"
    sfRenderWindow_setJoystickThreshold :: RenderWindow -> Float -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_setJoystickThreshold(sfRenderWindow* renderWindow, float threshold);


-- | Retrieve the OS-specific handle of a render window.
getRenderWindowSystemHandle :: RenderWindow -> IO WindowHandle
getRenderWindowSystemHandle = sfRenderWindow_getSystemHandle

foreign import ccall unsafe "sfRenderWindow_getSystemHandle"
    sfRenderWindow_getSystemHandle :: RenderWindow -> IO WindowHandle

--CSFML_GRAPHICS_API sfWindowHandle sfRenderWindow_getSystemHandle(const sfRenderWindow* renderWindow);


-- | Clear a render window with the given color.
clearRenderWindow
    :: RenderWindow -- ^ Render window object
    -> Color -- ^ Fill color
    -> IO ()

clearRenderWindow wnd color = with color $ sfRenderWindow_clear_helper wnd

foreign import ccall unsafe "sfRenderWindow_clear_helper"
    sfRenderWindow_clear_helper :: RenderWindow -> Ptr Color -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_clear(sfRenderWindow* renderWindow, sfColor color);


-- | Change the current active view of a render window.
setRenderWindowView
    :: RenderWindow -- ^ Render window object
    -> View -- ^ Pointer to the new view
    -> IO ()

setRenderWindowView = sfRenderWindow_setView

foreign import ccall unsafe "sfRenderWindow_setView"
    sfRenderWindow_setView :: RenderWindow -> View -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_setView(sfRenderWindow* renderWindow, const sfView* view);


-- | Get the current active view of a render window.
getRenderWindowView :: RenderWindow -> IO View
getRenderWindowView = sfRenderWindow_getView

foreign import ccall unsafe "sfRenderWindow_getView"
    sfRenderWindow_getView :: RenderWindow -> IO View

--CSFML_GRAPHICS_API const sfView* sfRenderWindow_getView(const sfRenderWindow* renderWindow);


-- | Get the default view of a render window.
getRenderWindowDefaultView :: RenderWindow -> IO View
getRenderWindowDefaultView = sfRenderWindow_getDefaultView

foreign import ccall unsafe "sfRenderWindow_getDefaultView"
    sfRenderWindow_getDefaultView :: RenderWindow -> IO View

--CSFML_GRAPHICS_API const sfView* sfRenderWindow_getDefaultView(const sfRenderWindow* renderWindow);


-- | Get the viewport of a view applied to this target, expressed in pixels in the current target.
getRenderWindowViewport
    :: RenderWindow -- ^ Render window object
    -> View -- ^ Target view
    -> IO IntRect

getRenderWindowViewport wnd view = alloca $ \ptr -> sfRenderWindow_getViewport_helper wnd view ptr >> peek ptr

foreign import ccall unsafe "sfRenderWindow_getViewport_helper"
    sfRenderWindow_getViewport_helper :: RenderWindow -> View -> Ptr IntRect -> IO ()

--CSFML_GRAPHICS_API sfIntRect sfRenderWindow_getViewport(const sfRenderWindow* renderWindow, const sfView* view);


-- | Convert a point in window coordinates into view coordinates.
convertCoords
    :: RenderWindow -- ^ Render window object
    -> Vec2i -- ^ Point to convert, relative to the window
    -> View  -- ^ Target view to convert the point to (pass NULL to use the current view)
    -> IO Vec2f

convertCoords wnd p view =
    alloca $ \ptr ->
    with p $ \posPtr ->
    sfRenderWindow_convertCoords_helper wnd posPtr view ptr >> peek ptr

foreign import ccall unsafe "sfRenderWindow_convertCoords_helper"
    sfRenderWindow_convertCoords_helper :: RenderWindow -> Ptr Vec2i -> View -> Ptr Vec2f -> IO ()

-- \return The converted point, in "world" units

--CSFML_GRAPHICS_API sfVector2f sfRenderWindow_convertCoords(const sfRenderWindow* renderWindow, sfVector2i point, const sfView* targetView);


-- | Draw a sprite to the render-target.
drawSprite
    :: RenderWindow -- ^ Render window object
    -> Sprite -- ^ Sprite to draw
    -> Maybe RenderStates -- ^ Render states to use for drawing ('Nothing' to use the default states)
    -> IO ()

drawSprite wnd sprite Nothing   = sfRenderWindow_drawSprite wnd sprite nullPtr
drawSprite wnd sprite (Just rs) = with rs $ sfRenderWindow_drawSprite wnd sprite

foreign import ccall unsafe "sfRenderWindow_drawSprite"
    sfRenderWindow_drawSprite :: RenderWindow -> Sprite -> Ptr RenderStates -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_drawSprite(sfRenderWindow* renderWindow, const sfSprite* object, const sfRenderStates* states);


-- | Draw text to the render-target.
drawText
    :: RenderWindow -- ^ Render window object
    -> Text -- ^ Text to draw
    -> Maybe RenderStates -- ^ Render states to use for drawing ('Nothing' to use the default states)
    -> IO ()

drawText wnd text Nothing   = sfRenderWindow_drawText wnd text nullPtr
drawText wnd text (Just rs) = with rs $ sfRenderWindow_drawText wnd text

foreign import ccall unsafe "sfRenderWindow_drawText"
    sfRenderWindow_drawText :: RenderWindow -> Text -> Ptr RenderStates -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_drawText(sfRenderWindow* renderWindow, const sfText* object, const sfRenderStates* states);


-- | Draw a shape to the render-target.
drawShape
    :: RenderWindow -- ^ Render window object
    -> Shape -- ^ Shape to draw
    -> Maybe RenderStates -- ^ Render states to use for drawing ('Nothing' to use the default states)
    -> IO ()

drawShape wnd shape Nothing   = sfRenderWindow_drawShape wnd shape nullPtr
drawShape wnd shape (Just rs) = with rs $ sfRenderWindow_drawShape wnd shape

foreign import ccall unsafe "sfRenderWindow_drawShape"
    sfRenderWindow_drawShape :: RenderWindow -> Shape -> Ptr RenderStates -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_drawShape(sfRenderWindow* renderWindow, const sfShape* object, const sfRenderStates* states);


-- | Draw a circle to the render-target.
drawCircle
    :: RenderWindow -- ^ Render window object
    -> CircleShape -- ^ Circle to draw
    -> Maybe RenderStates -- ^ Render states to use for drawing ('Nothing' to use the default states)
    -> IO ()

drawCircle wnd circle Nothing   = sfRenderWindow_drawCircleShape wnd circle nullPtr
drawCircle wnd circle (Just rs) = with rs $ sfRenderWindow_drawCircleShape wnd circle

foreign import ccall unsafe "sfRenderWindow_drawCircleShape"
    sfRenderWindow_drawCircleShape :: RenderWindow -> CircleShape -> Ptr RenderStates -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_drawCircleShape(sfRenderWindow* renderWindow, const sfCircleShape* object, const sfRenderStates* states);


-- | Draw a convex shape to the render-target.
drawConvexShape
    :: RenderWindow -- ^ Render window object
    -> ConvexShape -- ^ Convex shape to draw
    -> Maybe RenderStates -- ^ Render states to use for drawing ('Nothing' to use the default states)
    -> IO ()

drawConvexShape wnd shape Nothing   = sfRenderWindow_drawConvexShape wnd shape nullPtr
drawConvexShape wnd shape (Just rs) = with rs $ sfRenderWindow_drawConvexShape wnd shape

foreign import ccall unsafe "sfRenderWindow_drawConvexShape"
    sfRenderWindow_drawConvexShape :: RenderWindow -> ConvexShape -> Ptr RenderStates -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_drawConvexShape(sfRenderWindow* renderWindow, const sfConvexShape* object, const sfRenderStates* states);


-- | Draw a rectangle to the render-target.
drawRectangle
    :: RenderWindow -- ^ Render window object
    -> RectangleShape -- ^ Rectangle to draw
    -> Maybe RenderStates -- ^ Render states to use for drawing ('Nothing' to use the default states)
    -> IO ()

drawRectangle wnd rect Nothing   = sfRenderWindow_drawRectangleShape wnd rect nullPtr
drawRectangle wnd rect (Just rs) = with rs $ sfRenderWindow_drawRectangleShape wnd rect

foreign import ccall unsafe "sfRenderWindow_drawRectangleShape"
    sfRenderWindow_drawRectangleShape :: RenderWindow -> RectangleShape -> Ptr RenderStates -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_drawRectangleShape(sfRenderWindow* renderWindow, const sfRectangleShape* object, const sfRenderStates* states);


-- | Draw a vertex array to the render-target.
drawVertexArray
    :: RenderWindow -- ^ Render window object
    -> VertexArray  -- ^ Vertex array to draw
    -> Maybe RenderStates -- ^ Render states to use for drawing ('Nothing' to use the default states)
    -> IO ()

drawVertexArray wnd va Nothing   = sfRenderWindow_drawVertexArray wnd va nullPtr
drawVertexArray wnd va (Just rs) = with rs $ sfRenderWindow_drawVertexArray wnd va

foreign import ccall unsafe "sfRenderWindow_drawVertexArray"
    sfRenderWindow_drawVertexArray :: RenderWindow -> VertexArray -> Ptr RenderStates -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_drawVertexArray(sfRenderWindow* renderWindow, const sfVertexArray* object, const sfRenderStates* states);


-- | Draw primitives defined by a list of vertices to a render window.
drawPrimitives
    :: RenderWindow  -- ^ Render window object
    -> [Vertex]      -- ^ Vertices
    -> PrimitiveType -- ^ Type of primitives to draw
    -> Maybe RenderStates -- ^ Render states to use for drawing ('Nothing' to use the default states)
    -> IO ()

drawPrimitives wnd verts prim Nothing =
    let n = length verts
    in withArray verts $ \ptr ->
        sfRenderWindow_drawPrimitives wnd ptr (fromIntegral n) (fromIntegral . fromEnum $ prim) nullPtr


drawPrimitives wnd verts prim (Just r) =
    let n = length verts
    in withArray verts $ \ptr ->
        with r $ sfRenderWindow_drawPrimitives wnd ptr (fromIntegral n) (fromIntegral . fromEnum $ prim)


-- | Draw primitives defined by an array of vertices to a render window.
drawPrimitives'
    :: RenderWindow  -- ^ Render window object
    -> Ptr Vertex    -- ^ Pointer to the vertices
    -> Int           -- ^ Number of vertices in the array
    -> PrimitiveType -- ^ Type of primitives to draw
    -> Maybe RenderStates -- ^ Render states to use for drawing ('Nothing' to use the default states)
    -> IO ()

drawPrimitives' wnd verts n prim Nothing =
    sfRenderWindow_drawPrimitives wnd verts (fromIntegral n) (fromIntegral . fromEnum $ prim) nullPtr

drawPrimitives' wnd verts n prim (Just r) =
    with r $ sfRenderWindow_drawPrimitives wnd verts (fromIntegral n) (fromIntegral . fromEnum $ prim)

foreign import ccall unsafe "sfRenderWindow_drawPrimitives"
    sfRenderWindow_drawPrimitives :: RenderWindow -> Ptr Vertex -> CUInt -> CInt -> Ptr RenderStates -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_drawPrimitives(sfRenderWindow* renderWindow, const sfVertex* vertices, unsigned int vertexCount, sfPrimitiveType type, const sfRenderStates* states);


-- | Save the current OpenGL render states and matrices.
--
-- This function can be used when you mix SFML drawing
-- and direct OpenGL rendering. Combined with popGLStates,
-- it ensures that:
--
-- * SFML's internal states are not messed up by your OpenGL code
--
-- * Your OpenGL states are not modified by a call to a SFML function
--
-- Note that this function is quite expensive: it saves all the
-- possible OpenGL states and matrices, even the ones you
-- don't care about. Therefore it should be used wisely.
-- It is provided for convenience, but the best results will
-- be achieved if you handle OpenGL states yourself (because
-- you know which states have really changed, and need to be
-- saved and restored). Take a look at the resetGLStates
-- function if you do so.
pushGLStates :: RenderWindow -> IO ()
pushGLStates = sfRenderWindow_pushGLStates

foreign import ccall unsafe "sfRenderWindow_pushGLStates"
    sfRenderWindow_pushGLStates :: RenderWindow -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_pushGLStates(sfRenderWindow* renderWindow);


-- | Restore the previously saved OpenGL render states and matrices.
--
-- See the description of pushGLStates to get a detailed
-- description of these functions.
popGLStates :: RenderWindow -> IO ()
popGLStates = sfRenderWindow_popGLStates

foreign import ccall unsafe "sfRenderWindow_popGLStates"
    sfRenderWindow_popGLStates :: RenderWindow -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_popGLStates(sfRenderWindow* renderWindow);


-- |  Reset the internal OpenGL states so that the target is ready for drawing.
--
-- This function can be used when you mix SFML drawing
-- and direct OpenGL rendering, if you choose not to use
-- pushGLStates/popGLStates. It makes sure that all OpenGL
-- states needed by SFML are set, so that subsequent sfRenderWindow_draw*()
-- calls will work as expected.
resetGLStates :: RenderWindow -> IO ()
resetGLStates = sfRenderWindow_resetGLStates

foreign import ccall unsafe "sfRenderWindow_resetGLStates"
    sfRenderWindow_resetGLStates :: RenderWindow -> IO ()

--CSFML_GRAPHICS_API void sfRenderWindow_resetGLStates(sfRenderWindow* renderWindow);


-- | Copy the current contents of a render window to an image.
--
-- This is a slow operation, whose main purpose is to make
-- screenshots of the application. If you want to update an
-- image with the contents of the window and then use it for
-- drawing, you should rather use a sfTexture and its
-- update(sfWindow*) function.
--
-- You can also draw things directly to a texture with the
-- sfRenderWindow class.
captureRenderWindow :: RenderWindow -> IO Image
captureRenderWindow = sfRenderWindow_capture

foreign import ccall unsafe "sfRenderWindow_capture"
    sfRenderWindow_capture :: RenderWindow -> IO Image

--CSFML_GRAPHICS_API sfImage* sfRenderWindow_capture(const sfRenderWindow* renderWindow);

