$ = do require "gulp-load-plugins"
gulp = require 'gulp'
coffee = require 'gulp-coffee'
pug = require 'gulp-pug'
less = require 'gulp-less'
cssimport = require 'gulp-cssimport'
concat = require 'gulp-concat'
minify_css = require 'gulp-minify-css'
uglify = require('gulp-uglify-es').default
plumber = require 'gulp-plumber'

# browserify用
browserify = require 'browserify'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'

# 設定
app_name = 'main.js'
lib_name = 'lib.js'

# CoffeeScriptコンパイル
compile_coffee = (cb) ->
  gulp.src 'src/coffee/**/*.coffee'
      .pipe plumber()
      .pipe coffee()
      .pipe gulp.dest('tmp/coffee')
  cb()

# pugコンパイル
compile_pug = (cb) ->
  gulp.src 'src/pug/**/*.pug'
      .pipe plumber()
      .pipe pug {
        pretty: true
        client: true
      }
      .pipe gulp.dest('tmp/pug')
  cb()

# 外部ライブラリをbrowserifyで導入
compile_main = (cb) ->
  browserify {
        entries: ["src/coffee/main.coffee"]
        extensions: ['.coffee', '.pug', '.js']
        paths: ['./node_modules']
  }
      .transform 'coffeeify'
      .transform 'pugify'
      .bundle()
      .pipe source(app_name)
      .pipe buffer()
      .pipe uglify()
      .pipe gulp.dest('javascript')
  cb()

# cssコンパイル
compile_css = (cb) ->
  gulp.src 'src/less/**/*.less'
    .pipe plumber()
    .pipe less()
    .pipe cssimport()
    .pipe minify_css({ keepSpecialComments: 0 })
    .pipe gulp.dest('css')
  cb()

# 必要なライブラリをまとめる
compile_lib = (cb) ->
  gulp.src [
    './node_modules/sigma/build/sigma.min.js'
    './node_modules/sigma/build/plugins/sigma.layout.forceAtlas2.min.js'
    './node_modules/sigma/build/plugins/sigma.plugins.dragNodes.min.js'
  ]
    .pipe concat(lib_name)
    .pipe uglify()
    .pipe gulp.dest('javascript')
  cb()

# コンパイル処理
compile_all = gulp.series(compile_main, compile_css, compile_lib)

# watch処理
watch_files = (cb) ->
  gulp.series compile_all
  gulp.watch ['./src/coffee/*', './src/pug/*'], compile_main
  gulp.watch ['./src/less/*'], compile_css
  cb()


# 各処理コマンド
exports["convert-coffee"] = compile_coffee
exports["convert-pug"] = compile_pug

exports.compile = compile_all
exports["compile-main"] = compile_main
exports["compile-css"] = compile_css
exports["compile-lib"] = compile_lib
exports.watch = watch_files

# デフォルト処理
exports.default = compile_all