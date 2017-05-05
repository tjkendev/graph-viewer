$ = do require "gulp-load-plugins"
gulp = require 'gulp'
coffee = require 'gulp-coffee'
pug = require 'gulp-pug'
less = require 'gulp-less'
cssimport = require 'gulp-cssimport'
minify_css = require 'gulp-minify-css'
uglify = require 'gulp-uglify'
plumber = require 'gulp-plumber'
run_sequence = require 'run-sequence'

# browserify用
browserify = require 'browserify'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'

# 設定
app_name = 'main.js'

# CoffeeScriptコンパイル
gulp.task 'compile-coffee', ->
  gulp.src 'src/coffee/**/*.coffee'
      .pipe plumber()
      .pipe coffee()
      .pipe gulp.dest('tmp/coffee')

# pugコンパイル
gulp.task 'compile-pug', ->
  gulp.src 'src/pug/**/*.pug'
      .pipe plumber()
      .pipe pug
        pretty: true
        client: true
      .pipe gulp.dest('tmp/pug')

# 外部ライブラリをbrowserifyで導入
gulp.task 'browserify', ->
  browserify
        entries: ["src/coffee/main.coffee"]
        extensions: ['.coffee', '.pug', '.js']
        paths: ['./node_modules']
      .transform 'coffeeify'
      .transform 'pugify'
      .bundle()
      .pipe source(app_name)
      .pipe buffer()
      .pipe uglify()
      .pipe gulp.dest('javascript')

# cssコンパイル
gulp.task 'compile-css', ->
  gulp.src 'src/less/**/*.less'
    .pipe plumber()
    .pipe less()
    .pipe cssimport()
    .pipe minify_css(keepSpecialComments: 0)
    .pipe gulp.dest('css')

# コンパイル処理
gulp.task 'compile-all', ->
  # 直列実行するためにrun-sequenceを利用
  run_sequence 'compile-coffee', 'compile-pug', 'browserify', 'compile-css'

# watch処理
gulp.task 'watch', ['compile-all'], ->
  gulp.watch './src/**/*', ['compile-all']

# デフォルト処理
gulp.task 'default', ['compile-all']
