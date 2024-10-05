-- configuration file for platform independent love powered building tool https://github.com/ellraiser/love-build

return {
  -- basic settings:
  name = 'Panel Attack', -- name of the game for your executable
  developer = 'Panel Attack Devs', -- dev name used in metadata of the file
  output = 'dist', -- output location for your game, defaults to $SAVE_DIRECTORY
  version = '1.0', -- 'version' of your game, used to make a version folder in output
  love = '12.0', -- version of LÖVE to use, must match github releases
  ignore = { -- folders/files to ignore in your project
    '.DS_Store',
    '.gitignore',
    '.vscode',
    'loveExecutables',
    'dist'
  },
  icon = 'icon.png', -- 256x256px PNG icon for game, will be converted for you

  platforms = {'macos'}--, 'windows, macos'} -- set if you only want to build for a specific platform
}