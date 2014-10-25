config =
  seed: 1414181350797

  fps: 20

  spriteSheetSource: 'images/spritesheet-textured.png'

  generators: # galaxy, world, dungeon, cave, home, etc
    galaxy:
      options:
        size: 10
    dungeon:
      location: 'generators/Dungeon'
      options:
        spritesheetOffset: 160
        size: 48
    world:
      location: 'generators/World'
      options:
        spritesheetOffset: 0
        maxHeight: 7
        # world size
        worldChunkWidth: 4
        worldChunkHeight: 4
        # zoom level
        chunkTileWidth: 12
        chunkTileHeight: 12

  tileWidth: 32
  tileHeight: 32

  viewportOptions:
    width: 20
    height: 15

  minimapOptions:
    tileWidth: 4
    tileHeight: 4

# viewport size
width = config.viewportOptions.width * config.tileWidth
height = config.viewportOptions.height * config.tileHeight

# right side area
extraWidth = config.generators.dungeon.options.size
# config.generators.world.options.worldChunkWidth * config.generators.world.options.chunkTileWidth
width += extraWidth * config.minimapOptions.tileWidth + 10

config.canvasAdapterOptions =
  #width: 640
  #height: 480
  width: width
  height: height
  selector: '#canvas-container'

console.log 'Seed ', config.seed

module.exports = config
