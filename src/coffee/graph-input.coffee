
module.exports = class GraphInput
  constructor: (@opts = {}) ->
    @container = @opts.container
    @graph = @opts.graph
    @graphType = "graph"

    if @container?
      @container.html require('../pug/graph-input')()

      @textarea = @container.find('textarea.graph-input')
      @setPlaceHolder()

      @button = @container.find('.apply-button')
      @button.on 'click', @apply

      @chkbox = @container.find('.force-atlas')
      @chkbox.on 'change', @checkForceAtlas2

      @chkboxDirectedGraph = @container.find('.is-directed')
      @chkboxDirectedGraph.on 'change', @checkIsDirected

      @rbutton = @container.find('.random-button')
      @rbutton.on 'click', @setRandom

      @cbutton = @container.find('.clear-button')
      @cbutton.on 'click', @clearInput

      @optionTabs = @container.find('.tab-option')
      @optionTabs.on 'click', @changeTab

    @setRandom()

  generateRandomGraph: ->
    # パラメータの決定
    n = 2 + Math.floor(48 * Math.random())
    m = 1 + Math.floor((n * (n - 1) / 2 - 1) * Math.random())

    # 全ての辺を作る
    array = []
    for i in [1..n] by 1
      for j in [(i + 1)..n] by 1
        array.push [i, j]

    # Fisher-Yates Shuffle
    for i in [(array.length - 1)..1] by -1
      j = Math.floor(Math.random() * (i - 1))
      tmp = array[i]; array[i] = array[j]; array[j] = tmp

    return [n, m, array]

  generateRandomGraphString: ->
    [n, m, array] = @generateRandomGraph()

    text = ["#{n} #{m}"]
    # m個取り出す
    for i in [0...m] by 1
      [p, q] = array[i]
      text.push "#{p} #{q}"
    return text.join('\n')

  generateRandomTreeString: ->
    # パラメータの決定
    n = 2 + Math.floor(48 * Math.random())
    text = ["#{n}"]
    for i in [2..n] by 1
      j = 1 + Math.floor(Math.random() * (i - 2))
      text.push "#{j}"
    return text.join('\n')

  generateRandomEdgesString: ->
    [n, m, array] = @generateRandomGraph()

    text = []
    for i in [0...m] by 1
      [p, q] = array[i]
      text.push "#{p} #{q}"
    return text.join('\n')

  parseGraph: (input) ->
    return null unless input?

    lines = input.split('\n')
    [n, m] = lines[0].trim().split(' ').map(Number)
    m = lines.length - 1 if lines.length < m + 1

    edges = lines.slice(1, m + 1).map (line) ->
      [p, q, r] = line.trim().split(' ')
      v1 = Number(p)
      v2 = Number(q)
      return null if v1 == NaN || v2 == NaN
      return [v1, v2, r ? ""]

    vlabel = [1..n].map String

    return {
      n: n
      m: m
      vlabel: vlabel
      edges: edges
    }

  parseTree: (input) ->
    return null unless input?

    lines = input.split('\n')
    n = Number(lines[0])
    m = n - 1

    ln = Math.min(n, lines.length)

    edges = lines.slice(1, ln).map (line, idx) ->
      [p, r] = line.trim().split(' ')
      v1 = idx + 2
      v2 = Number(p)
      return null if v2 == NaN
      return [v1, v2, r ? ""]

    vlabel = [1..n].map String

    return {
      n: n
      m: m
      vlabel: vlabel
      edges: edges
    }

  parseEdges: (input) ->
    return null unless input?

    lines = input.split('\n')

    ln = lines.length
    edges = lines.map (line, idx) ->
      [v1, v2, r] = line.trim().split(' ')
      return null if v1 == NaN || v2 == NaN
      return [v1, v2, r ? ""]

    vMap = {}
    n = 0
    edges.forEach (edge) ->
      return unless edge?
      [v1, v2, r] = edge
      vMap[v1] = (n++) if !vMap.hasOwnProperty(v1)
      vMap[v2] = (n++) if !vMap.hasOwnProperty(v2)

    vlabel = new Array(n)
    vlabel[i] = v for v, i of vMap

    replacedEdges = edges.map (edge) ->
      return null unless edge?
      [v1, v2, r] = edge
      return [vMap[v1]+1, vMap[v2]+1, r]

    return {
      n: n
      m: edges.length
      vlabel: vlabel
      edges: replacedEdges
    }

  setRandom: =>
    rndText = (switch @graphType
      when 'graph'
        @generateRandomGraphString()
      when 'tree'
        @generateRandomTreeString()
      when 'edges'
        @generateRandomEdgesString()
    )
    @container.find("textarea.graph-input").val rndText
    @apply()

  apply: =>
    input = @textarea.val()

    graph = (switch @graphType
      when 'graph'
        @parseGraph(input)
      when 'tree'
        @parseTree(input)
      when 'edges'
        @parseEdges(input)
    )

    graph = { n: 0, m: 0, edges: [] } unless graph?

    @graph.setGraph graph
    @clearForceAtlas2()

  # force atlas 2で移動させるかを切り替え
  checkForceAtlas2: (event) =>
    $el = $(event.currentTarget)
    @graph.doForceAtlas2 $el.prop("checked")

  clearForceAtlas2: (event) =>
    @chkbox.prop("checked", false)

  # 有向・無向の切り替え
  checkIsDirected: (event) =>
    $el = $(event.currentTarget)
    @graph.SetDirected $el.prop("checked")

  # 入力のクリア
  clearInput: (event) =>
    @textarea.val ""
    @apply()

  # タブ切り替え
  changeTab: (event) =>
    $el = $(event.currentTarget)
    return if $el.hasClass("active")

    @graphType = $el.attr('type')

    @setPlaceHolder()
    @setRandom()

    @optionTabs.removeClass "active"
    $el.addClass "active"

  # placeholderの変更
  setPlaceHolder: ->
    @textarea.attr 'placeholder', (switch @graphType
      when 'graph'
        "Input:\nn m\np₁ q₁\n...\npₘ qₘ\n-----\nConstraints:\n1 ≤ pᵢ, qᵢ ≤ n"
      when 'tree'
        "Input:\nn\np₂\n...\npₙ\n-----\nConstraints:\n1 ≤ pᵢ ≤ i-1"
      when 'edges'
        "Input:\np₁ q₁\n...\npₘ qₘ"
    )
