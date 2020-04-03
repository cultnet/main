glob = require(\glob).sync
require! { path: { dirname, resolve } }
require! { rimraf: { sync: rimraf } }
require! { mkdirp: { sync: mkdirp }}
require! { fs:
  symlinkSync: symlink
  existsSync: exists
  readdirSync: readdir
}

MAIN = process.env.CULTNET_MAIN
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
  # TODO: doesnt link deps of deps
  for json in glob "#{MAIN}/../*/package.json"
    pkg = require json
    if not pkg.dependencies then continue
    deps = Object.keys(pkg.dependencies).filter -> it.starts-with "@cultnet/"
    if deps.length is 0 then continue
    for dep in deps
      dep-dir = "#{dirname json}/node_modules/#{dep}"
      target = resolve "#{MAIN}/../#{dep.slice dep.index-of "/"}"
      if exists dep-dir
        console.log "removing #{dep-dir}"
        rimraf dep-dir
      console.log "linking #{dep-dir} to #{target}"
      mkdirp (dirname dep-dir)
      symlink target, dep-dir

function help
  console.log "cultnet: start a cult\n"
  console.log "Usage:"
  console.log "  cultnet master <dir>"
  process.exit!
