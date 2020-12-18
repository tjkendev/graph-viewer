window.$ = $ = require 'jquery'

Graph = require './graph'
GraphInput = require './graph-input'

window.onload = ->
  $graph = $("div.graph")
  $graph_input = $("div.graph-input")
  window.graph = @graph = new Graph({ container: $graph })
  window.graph_input = @graph_input = new GraphInput({ container: $graph_input, graph: @graph })
