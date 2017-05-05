
module.exports = class GraphInput
  constructor: (@opts={})->
    @container = @opts.container
    if @container?
      @container.html require('../pug/graph-input')()
      @button = @container.find('.apply-button')
      @button.on 'click', @apply

      @chkbox = @container.find('.force-atlas')
      @chkbox.on 'change', @checkForceAtlas2
    @graph = @opts.graph

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

  apply: =>
    input = @container.find("textarea.graph-input").val()

    graph = @parseGraph(input)

    @graph.setGraph graph

  checkForceAtlas2: (event)=>
    $el = $(event.currentTarget)
    @graph.doForceAtlas2 $el.prop("checked")


