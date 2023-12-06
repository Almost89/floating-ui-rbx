# floating-ui-rbx

> 🎈 A port of [`floating-ui`](https://github.com/floating-ui/floating-ui) for Roblox.

## Install

```toml
# wally.toml

[dependencies]
FloatingUI = "alomost89/floating-ui-rbx-dom@0.1.0"
```

## Usage

Currently there is no direct documentation for the Roblox version. Please refer to [`floating-ui`'s original docs](https://floating-ui.com/docs/getting-started).

## Progress

> Status: Usable... probably

- [ ] [`core`](/modules/core/)
  - [x] `computePosition`, `computeCoordsFromPlacement`, and `detectOverflow`
  - [ ] middleware
    - [x] `hide`
    - [x] `size`
    - [x] `offset`
    - [ ] `shift`
    - [x] `flip`
    - [x] `arrow`
    - [ ] `autoPlacement`
    - [ ] `inline`
- [x] [`utils`](/modules/rbx-dom/)
- [ ] [`rbx-dom`](/modules/rbx-dom/)
  - [x] platform
    - [x] `getElementRects` and `getDimensions`
    - [ ] figure out what `getClippingRect` is meant to do lol

## License

Everything is under the [MIT License](https://opensource.org/license/mit/). Please see each package's LICENSE file for details.
