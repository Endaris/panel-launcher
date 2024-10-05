A launcher for Panel Attack. Requires love 12 / the lua-https module.

Downloads a platform specific love app from the Panel Attack website as well as the Panel Attack updater.  
Uses `os.execute` to have the platform specific love app launch with the updater as its argument.  
Confirmed working for Linux, yet to be tested/fixed on Mac/Windows.

The launcher uses running numbers and saves the currently used version in a local `version.lua` file that is loaded back in on every launch.  
An example of the required folder structure on the server is available in the comments of `network.lua`.

For deployment, add an `embeds` directory structure to provide offline files:  
`embeds/love/` containing `love.zip` for Windows/Mac, `love.AppImage` for Linux.
`embeds/updater/updater.love`, this should have a valid Panel Attack within its own embed to guarantee offline functionality.

Many thanks to ellraiser for his love-zip module.
