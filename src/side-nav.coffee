
# div
#   drag-handle(
#     @move="move"
#     @max="open(false)"
#     @aborted="hide"
#     v-bind:disabled="opened || isFixed"
#     v-bind:max-right="right ? null : width"
#     v-bind:max-left="right ? width : null"
#     v-bind:z-index="overlayZIndex"
#     v-bind:style="{width: '20px',left:right ? null : '0',right:right ? '0' : null}"
#   )
#   drag-handle(
#     @move="move"
#     @max="close(false)"
#     @aborted="show"
#     v-bind:disabled="!opened || isFixed"
#     v-bind:max-right="right ? width : null"
#     v-bind:max-left="right ? null : width"
#     v-bind:offset="right ? -width : width"
#     v-bind:z-index="overlayZIndex"
#     v-bind:style="{left:'0',right:'0'}"
#     @clean-click="dismiss"
#   )

#   ul(
#     v-bind:id="id"
#     ref="nav"
#     @click="onClick"
#     @keyup.esc="dismiss"
#     v-bind:style="computedStyle"
#     v-bind:class="computedClass"
#     )
#     slot
ceri = require "ceri/lib/wrapper"
module.exports = ceri

  mixins: [
    require "ceri/lib/props"
    require "ceri/lib/style"
    require "ceri/lib/animate"
    require "ceri/lib/directives"
    require "ceri/lib/open"
    require "ceri/lib/overlay"
    require "ceri/lib/#if"
    require "ceri/lib/draghandle"
  ]

  props:
    opacity:
      type: Number
      default: 0.5
    right:
      type: Boolean
      cbs: ["setParentMargin",((val) ->
        if val
          @style.right = 0
          @style.left = null
        else
          @style.right = null
          @style.left = null
      )]
    target:
      type: String
    fixed:
      type: Boolean
      cbs: "processFixed"
    fixedScreenSize:
      type: Number
      default: 992
      cbs: "processFixed"
    zIndex:
      type:Number
      default: 1000
      cbs: (val,old) ->
        s = @style
        return if s.zIndex and s.zIndex != old
        s.zIndex = val

  data: -> isFixed: null, keepOpen: true, dhZIndex: null

  overlay:
    zIndex: "zIndex"
    active: "dismissable"
    animate: "toggleAnimate"
    delay: true
    onClose: -> @style.zIndex = @zIndex; @dhZIndex = @zIndex-1; @hide.call(@)
    onOpen: (zIndex) -> @style.zIndex = zIndex+2; @dhZIndex = zIndex+1

  draghandle:
    __parentElement:
      active: -> !@isFixed
      initStyle:
        position: "absolute"
        top: 0
        bottom: 0
      style: ->
        zIndex: @dhZIndex
        width: if @open then null else "20px"
        left: if !@right or @open then 0 else null
        right: if @right or @open then 0 else null
      onClick: -> @hide() if @open
      onFirstMove: (o) ->
        unless @open
          @style.transform = "translateX(#{@fac*100}%)"
          @_attach()
        o.wasOpened = @open
        w = @offsetWidth * @fac
        if @right
          o.shouldShow = (move) -> move < 0
          o.shouldHide = (move) -> move > w
        else
          o.shouldShow = (move) -> move > 0
          o.shouldHide = (move) -> move < w
      onMove: (delta, o) ->
        move = 2 * delta.x  + @offsetWidth * @fac * !o.wasOpened
        if o.shouldShow(move)
          @_setOpen()
          @style.transform = null
          o.move = 0
        else if o.shouldHide(move)
          @_setClose()
          @style.transform = "translateX(#{@fac*100}%)"
          o.move = -@offsetWidth
        else
          @style.transform = "translateX(#{move}px)"
          o.move = move
      onEnd: (delta, o) ->
        if @open and o.move < 0
          @animation = @enter _percent: 1 - o.move/@offsetWidth * @fac
        else if not @open and o.move > -@offsetWidth
          @animation = @leave _percent: o.move/@offsetWidth * @fac, done: @_detach

  events:
    click:
      this:
        active: "dismissable"
        notPrevented: true
        prevent: true
        cbs: ["toggle"]
      _target:
        active: ->@_target? and not @isFixed
        notPrevented: true
        prevent: true
        cbs: ["toggle"]
        destroy: true
    resize:
      window:
        el: window
        active: "fixed"
        throttled: true
        destroy: true
        cbs: "processFixed"
  directives:
    _target:
      type: "#"
      name: "if"
      activate: "_target"
      value: ->
        return false if @isFixed
        return true
  initStyle:
    position: "fixed"
    height: "100%"
    willChange: "transform"

  computed:
    _target: -> 
      return null unless @target
      return document.querySelector(@target)
    fac: -> @right*2-1
    dismissable: -> 
      @openingOrOpen and not @isFixed

  methods:
    makeFixed: (fixed) ->
      if fixed != @isFixed
        @isFixed = fixed
        @$emit name:"fixed", detail:fixed
    setParentMargin: ->
      if @parentElement
        if @isFixed
          width = @offsetWidth + "px"
        else
          width = null
        for el in @parentElement.children
          if el != @
            @$style.set el, 
              marginLeft: if @right then null else width
              marginRight: if @right then width else null
    processFixed: ->
      if @fixed
        old = @isFixed
        @makeFixed(window.innerWidth > @fixedScreenSize)
        if old != @isFixed
          @wasOpened = @open
          if @isFixed
            @show(false)
            @setParentMargin()
          else
            @setParentMargin()
            @hide(false)
      else
        @makeFixed(false)
        @setParentMargin()
        if not @openingOrOpen or not @wasOpened 
          @hide(false)
    enter: (o) ->
      o.style = translateX: [@fac*100,0,"%"]
      return @$animate(o)

    leave: (o) ->
      o.style = translateX: [0,@fac*100,"%"]
      return @$animate(o)

    beforeToggle: -> not @isFixed

    onHide: -> @wasOpened = false
