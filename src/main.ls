glob = require(\glob).sync
require! { path: { dirname, resolve } }
require! { rimraf: { sync: rimraf } }
require! { mkdirp: { sync: mkdirp }}
require! { fs:
  symlinkSync: symlink
  existsSync: exists
  readdirSync: readdir
  lstatSync: lstat
}

ROOT = resolve "#{__dirname}/../.."
LIVE = process.env.CULTNET_LIVE is \true
args = process.argv.slice (if LIVE then 3 else 2)

switch args.0
| \master => master ...args.slice 1
| \devlinks => devlinks ...args.slice 1
| otherwise => help!

function master botdir
  if not botdir then help!
  { Master } = require (if LIVE then "@cultnet/master/src/master" else "@cultnet/master")
  Master.start botdir

function devlinks
  dirs =
    readdir "#{ROOT}", { +with-file-types }
      .filter -> it.is-directory!
      .map -> it.name
  for dir in dirs
    cultdeps = "#{ROOT}/#{dir}/node_modules/@cultnet"
    if exists cultdeps
      if (lstat cultdeps).is-symbolic-link!
        console.log "#{dir} ITS ALL GOOD"
        continue
      console.log "removing dir #{cultdeps}"
      rimraf cultdeps
    console.log "creating symlink #{cultdeps} to #{ROOT}"
    symlink ROOT, cultdeps

function help
  console.log "cultnet: start a cult\n"
  console.log "Usage:"
  console.log "  cultnet master <dir>"
  process.exit!
