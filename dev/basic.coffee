require "./materialize.config.scss"
require "./basic.css"
window.customElements.define "ceri-side-nav", require "../src/side-nav.coffee"
createView = require "ceri-dev-server/lib/createView"
module.exports = createView
  mixins:[
    require "ce/#if"
  ]
  structure: template 1, """
  <ceri-side-nav :right="right" :fixed="fixed" :fixed-screen-size="fixedScreenSize" #ref="sideNav" target=#toggle :class=class>
    <li><a>First Text</a></li>
  </ceri-side-nav>
  <div class="container2" style="padding:20px;">
    <button :class=btnCls @click.toggle="fixed">{{@fixed?"unfix":"fix"}}</button>
    <button :class=btnCls @click.toggle="right">{{@right?"to the left":"to the right"}}</button>
    <br/>
    <button :class=btnCls id=toggle>Toggle</button><button :class=btnCls @click.toggle=materialize>Toggle Materialize Theme</button>
    <p :text=text :style=style></p>
    <a href="https://github.com/ceri-comps/ceri-side-nav/blob/master/dev/basic.coffee" style="position:relative;top:40px;left:200px;">source</a></div>
  """
  computed:
    text: ->
      if @fixed
        if @sideNav.isFixed
          "Side-nav is fixed for this window-size. Make the window smaller for it to collapse."
        else
          if @right
            s = "drag >>"
          else
            s = "<< drag"
          return s+"\r\nMake window larger for the nav to stay opened"
      else
        if @right
          "drag >>"
        else
          "<< drag"
    style: ->
      if @right
        "text-align:right"
      else
        null
    class: -> if @materialize then "materialize" else null
    btnCls: -> if @materialize then "btn" else null
  data: ->
    right: false
    fixed: false
    materialize: false
    fixedScreenSize: 992
  tests: (env) ->
    describe "side-nav", ->
      it "should work", ->