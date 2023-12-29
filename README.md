# floating-ui-rbx

> 🎈 A port of [`floating-ui`](https://github.com/floating-ui/floating-ui) for Roblox.

## Install

```toml
# wally.toml

[dependencies]
FloatingUI = "alomost89/floating-ui-rbx-dom@0.2.0"
```

## Usage

Currently there is no direct documentation for the Roblox version. Please refer to [`floating-ui`'s original docs](https://floating-ui.com/docs/getting-started).

## Progress

> Status: Most of the middleware is completely untested. I wouldn't suggest using this in production yet.

- [ ] [`core`](/modules/core/)
  - [x] `computePosition`, `computeCoordsFromPlacement`, and `detectOverflow`
  - [ ] middleware
    - [x] `hide`
    - [x] `size`
    - [x] `offset`
    - [x] `shift`
    - [x] `flip`
    - [x] `arrow`
    - [x] `autoPlacement`
    - [ ] `inline`
- [x] [`utils`](/modules/rbx-dom/)
- [x] [`rbx-dom`](/modules/rbx-dom/)
  - [x] platform
    - [x] `getElementRects`,`getDimensions`, and `getClippingRect`

## License

Everything is under the [MIT License](https://opensource.org/license/mit/). Please see each package's LICENSE file for details.
