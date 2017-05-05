
module.exports = class GraphInput
  constructor: (@opts={})->
    @container = @opts.container
    if @container?
      @container.html require('../pug/graph-input')()
      @button = @container.find('.apply-button')
      @button.on 'click', @apply

      @chkbox = @container.find('.force-atlas')
      @chkbox.on 'change', @checkForceAtlas2

      @rbutton = @container.find('.random-button')
      @rbutton.on 'click', @setRandom
    @graph = @opts.graph

    @setRandom()

  generateRandom: ->
    # パラメータの決定
    n = 2 + Math.floor(48 * Math.random())
    m = 1 + Math.floor((n*(n-1)/2-1) * Math.random())

    # 全ての辺を作る
    array = []
    for i in [1..n] by 1
      for j in [i+1..n] by 1
        array.push [i, j]

    # Fisher-Yates Shuffle
    for i in [array.length-1..1] by -1
      j = Math.floor(Math.random() * (i-1))
      tmp = array[i]; array[i] = array[j]; array[j] = tmp

    text = ["#{n} #{m}"]
    # m個取り出す
    for i in [0...m] by 1
      [p, q] = array[i]
      text.push "#{p} #{q}"

    return text.join('\n')

  parseGraph: (input)->
    return null unless input?

    lines = input.split('\n')
    [n, m] = lines[0].split(' ').map(Number)
    return null if lines.length < m+1

    edges = lines.slice(1, m+1).map (line)-> [p, q] = line.split(' ').map(Number)

    return {
      n: n
      m: m
      edges: edges
    }

  setRandom: =>
    rndText = @generateRandom()
    @container.find("textarea.graph-input").val rndText
    @apply()

  apply: =>
    input = @container.find("textarea.graph-input").val()

    graph = @parseGraph(input)

    @graph.setGraph graph

  checkForceAtlas2: (event)=>
    $el = $(event.currentTarget)
    @graph.doForceAtlas2 $el.prop("checked")


