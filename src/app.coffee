MainLoop = require('../lib/seldom').MainLoop
FlowController = require('../lib/seldom').FlowController
premade = require('../lib/premade')

h = require 'virtual-dom/h'

$ ()->
  ListTemplate = (data) ->
    children = [
      'Alphabetized List'
      h 'ul'
      h 'input', placeholder: 'Type Something Here'
      h 'button', type: 'button', [
        'Add +'
      ]
    ]

    if data.error
      children.push h 'div', class: 'error', data.error

    h 'div.text#fancy-list', children

  ListItemTemplate = (data)->
    h 'li', [
      h 'p', data.message
    ]

  class ListItemFlowController extends FlowController
    selector: 'ul'
    init: ->
      @flows.set.push @update(ListItemTemplate)

  class SortedListFlowController extends FlowController
    selector: 'body'
    root: true
    init: ->
      @flows['click button'] = (data, state)=>
        target = state.event.target
        data.messages.push $(@_dom).find('input').val()
        return data

      @flows.set = [
        premade.higherOrder.validate (data)->
          for message in data.messages
            if message == ''
              return "List Item cannot be empty"
          return null
        premade.set
        (data) ->
          data.messages = data.messages.sort()
          i = 0
          for child in @children
            child.data =
              message: data.messages[i]
            i++

          while i < data.messages.length
            @children.push new ListItemFlowController
              data:
                message: data.messages[i]
            i++
          return data
        @update(ListTemplate)
      ]

  new SortedListFlowController
    data:
      messages: [
        'This list is sorted'
        'Alphabetically ascending'
      ]

  # setInterval ()->
  #   data = li1.data
  #   li1.data = li2.data
  #   li2.data = data
  # , 1000

MainLoop.start()

