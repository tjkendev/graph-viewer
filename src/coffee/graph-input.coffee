
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

    text = ["#{n} #{m}"]
    # m個取り出す
    for i in [0...m] by 1
      [p, q] = array[i]
      text.push "#{p} #{q}"
    return text.join('\n')

  generateRandomTree: ->
    # パラメータの決定
    n = 2 + Math.floor(48 * Math.random())
    text = ["#{n}"]
    for i in [2..n] by 1
      j = 1 + Math.floor(Math.random() * (i - 2))
      text.push "#{j}"
    return text.join('\n')

  parseGraph: (input) ->
    return null unless input?

    lines = input.split('\n')
    [n, m] = lines[0].split(' ').map(Number)
    m = lines.length - 1 if lines.length < m + 1

    edges = lines.slice(1, m + 1).map (line) ->
        [p, q, r] = line.split(' ')
        v1 = Number(p)
        v2 = Number(q)
        return null if v1 == NaN || v2 == NaN
        return [v1, v2, r ? ""]

    return {
      n: n
      m: m
      edges: edges
    }

  parseTree: (input) ->
    return null unless input?

    lines = input.split('\n')
    n = Number(lines[0])
    m = n - 1

    ln = Math.min(n, lines.length)

    edges = lines.slice(1, ln).map (line, idx) ->
        [p, r] = line.split(' ')
        v1 = idx + 2
        v2 = Number(p)
        return null if v2 == NaN
        return [v1, v2, r ? ""]

    return {
      n: n
      m: m
      edges: edges
    }

  setRandom: =>
    if @graphType == 'graph'
      rndText = @generateRandomGraph()
    else
      rndText = @generateRandomTree()
    @container.find("textarea.graph-input").val rndText
    @apply()

  apply: =>
    input = @textarea.val()

    if @graphType == 'graph'
      graph = @parseGraph(input)
    else
      graph = @parseTree(input)

    if graph == null
      graph = { n: 0, m: 0, edges: [] }

    @graph.setGraph graph
    @clearForceAtlas2()

  # force atlas 2で移動させるかを切り替え
  checkForceAtlas2: (event) =>
    $el = $(event.currentTarget)
    @graph.doForceAtlas2 $el.prop("checked")

  clearForceAtlas2: (event) =>
    @chkbox.prop("checked", false)

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
    if @graphType == 'graph'
      @textarea.attr 'placeholder', "Input:\n-----\nn m\np₁ q₁\n...\npₘ qₘ\n-----\nConstraints:\n1≤pᵢ,qᵢ≤n"
    else
      @textarea.attr 'placeholder', "Input:\n-----\nn\np₂\n...\npₙ\n-----\nConstraints:\n1≤pᵢ≤i-1"
