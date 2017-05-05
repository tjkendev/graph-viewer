global.sigma = sigma = require 'sigma'
sigma.plugins = {}
require 'sigma/plugins/sigma.plugins.dragNodes/sigma.plugins.dragNodes'
worker = require 'sigma/plugins/sigma.layout.forceAtlas2/worker'
supervisor = require 'sigma/plugins/sigma.layout.forceAtlas2/supervisor'

supervisor.postMessage = (message, targetOrigin)-> window.postMessage(message, targetOrigin)

module.exports = class Graph

  constructor: (@opts={})->
    @container = @opts.container
    if @container?
      @container.html require('../pug/graph.pug')()

    viewer = @container?.find("#graph-viewer")[0]

    @sigma = new sigma {
      renderer:
        container: viewer
        type: 'canvas'
      settings:
        edgeLabelSize: 'proportional'
    }
    @graph = @sigma.graph
    @dragListener = sigma.plugins.dragNodes(@sigma, @sigma.renderers[0])
    @dragListener.bind 'startdrag', @sigmaStartDrag
    @dragListener.bind 'drag', @sigmaDrag
    @dragListener.bind 'drop', @sigmaDrop
    @dragListener.bind 'dragend', @sigmaDragEnd

  setGraph: (graph)->
    return unless graph?

    nodes = []
    for i in [1..(graph.n)]
      nodes.push {
        id: 'n' + i
        label: String(i)
        x: Math.random()
        y: Math.random()
        size: 10 #Math.random()
        color: '#666'
      }
    edges = []
    for i in [1..(graph.m)]
      [p, q] = graph.edges[i-1]
      edges.push {
        id: 'e' + i
        label: 'Edge ' + i
        source: 'n' + p
        target: 'n' + q
        size: 5
        color: '#ccc'
        type: 'line'
      }

    @sigma.killForceAtlas2()

    @graph.clear().read {
      nodes: nodes,
      edges: edges
    }
    @sigma.refresh()


  doForceAtlas2: (active)=>
    if active
      console.log @sigma.supervisor
      @sigma.startForceAtlas2 {
          worker: true
          gravity: 1
          scalingRatio: 0.5
          slowDown: 5
          startingIterations: 100
        }
    else
      if @sigma.isForceAtlas2Running()
        @sigma.stopForceAtlas2()

  sigmaStartDrag: (event)->
    #console.log event
  sigmaDrag: (event)->
    #console.log event
  sigmaDrop: (event)->
    #console.log event
  sigmaDragEnd: (event)->
    #console.log event
