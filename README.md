# floating-ui-rbx

> 🎈 A port of [`floating-ui`](https://github.com/floating-ui/floating-ui) for Roblox.

## Install

```toml
# wally.toml

[dependencies]
FloatingUI = "almost89/floating-ui-rbx-dom@0.2.0"
```

## Usage

Currently there is no documentation for the Roblox version. Please refer to [`floating-ui`'s original docs](https://floating-ui.com/docs/getting-started).

## Progress

> [!WARNING]
> I wouldn't suggest using this in production as it hasn't been tested.

- [x] [`core`](/modules/core/)
  - [x] `computePosition`, `computeCoordsFromPlacement`, and `detectOverflow`
  - [x] middleware
    - [x] `hide`
    - [x] `size`
    - [x] `offset`
    - [x] `shift`
    - [x] `flip`
    - [x] `arrow`
    - [x] `autoPlacement`
    - [x] `inline`
- [x] [`utils`](/modules/rbx-dom/)
- [x] [`rbx-dom`](/modules/rbx-dom/)
  - [x] platform
    - [x] `getElementRects`, `getDimensions`, and `getClippingRect`

## License

[MIT](https://opensource.org/license/mit/). Please see each package's LICENSE file for details.
