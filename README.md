# ceri-side-nav

a touch enabled, responsive side-nav.

### [Demo](https://ceri-comps.github.io/ceri-side-nav)


# Install

```sh
npm install --save-dev ceri-side-nav
```

## Usage
- [general ceri component usage instructions](https://github.com/cerijs/ceri#i-want-to-use-a-component-built-with-ceri)
- in your project
```coffee
window.customElements.define("ceri-side-nav", require("ceri-side-nav"))
```
```html
<ceri-side-nav target=#nav-toggle>
  <li>First Text<li>
</ceri-side-nav>
<!-- margin on sibling elements will be set to when side-nav gets fixed -->
<container>
  <!-- you can specify a target to toggle the nav -->
  <button id=nav-toggle>toggle</button>
</container>
```
For examples see [`dev/`](dev/).



#### Props
Name | type | default | description
---:| --- | ---| ---
target | String | null | Will attach toggling on given element, resolved by `querySelector`.
fixed-screen-size | Number | 992 | Used with `fixed`. Above this size, the menu will stay opened.
fixed | Boolean | false | should always show on large screens
open | Boolean | false | set to open / close
right | Boolean | false | attach to the right side instead of the left
opacity | Number | 0.5 | opacity of the overlay
z-index | Number | 1000 | minimum zIndex of the overlay.

To not close the nav on a click inside, call `e.preventDefault()` on click.

#### Events
Name |  description
---:| ---
fixed(isFixed:Boolean) | emitted when menu get fixed or unfixed on large screen.
toggled(isOpened:Boolean) | emitted when menu gets opened or closed.

#### Themes
- [ceri-materialize](https://github.com/ceri-comps/ceri-materialize)
```html
<ceri-side-nav class=materialize> 
</ceri-side-nav >
```

# Development
Clone repository.
```sh
npm install
npm run dev
```
Browse to `http://localhost:8080/`.

## Notable changes
#### 0.2.0
- use ceri-materialize@2

## License
Copyright (c) 2016 Paul Pflugradt
Licensed under the MIT license.
