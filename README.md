# combine-interception

[![CI](https://github.com/capturecontext/combine-interception/actions/workflows/ci.yml/badge.svg)](https://github.com/capturecontext/combine-interception/actions/workflows/ci.yml) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fcombine-interception%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/capturecontext/combine-interception) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcapturecontext%2Fcombine-interception%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/capturecontext/combine-interception)

Combine API for intercepting Objective-C selector invocations in Swift.

## Table of contents

- [Motivation](#motivation)
- [Usage](#usage)
  - [Basic](#basic)
  - [Library development](#library-development)
- [Installation](#installation)
- [License](#license)

## Motivation

Many Cocoa APIs rely on delegate callbacks and Objective-C selectors.

While Combine provides powerful tools for working with asynchronous streams, it does not offer built-in support for observing selector-based APIs. Integrating such APIs often requires writing custom delegate proxies or bridging imperative callbacks into publishers manually.

This package provides a Combine-friendly API for intercepting Objective-C selector invocations, allowing delegate-style APIs to be observed and transformed using publishers.

## Usage

### Basic

Observe selectors on NSObject instances

```swift
navigationController.intercept(_makeMethodSelector(
  selector: UINavigationController.popViewController,
  signature: navigationController.popViewController
))
.sink { result in
  print(result.args) // `animated` flag
  print(result.output) // popped `UIViewController?`
}
```

You can also simplify creating method selector with `CombineInterceptionMacros` if you are open for macros

```swift
navigationController.intercept(
  #methodSelector(UINavigationController.popViewController)
).sink { result in
  print(result.args) // `animated` flag
  print(result.output) // popped `UIViewController?`
}
```

>  Macros require `swift-syntax` compilation, so it will affect cold compilation time

### Library

If you use it to create a library it may be a good idea to export this one implicitly

```swift
// Exports.swift
@_exported import CombineInterception
```

It's a good idea to add a separate macros target to your library as well

```swift
// Exports.swift
@_exported import CombineInterceptionMacros
```

## Installation

### Basic

You can add CombineInterception to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
2. Enter [`"https://github.com/capturecontext/combine-interception.git"`](https://github.com/capturecontext/combine-interception.git) into the package repository URL text field
3. Choose products you need to link them to your project.

### Recommended

If you use SwiftPM for your project, you can add CombineInterception to your package file.

```swift
.package(
  url: "https://github.com/capturecontext/combine-interception.git", 
  .upToNextMinor(from: "0.4.0")
)
```

Do not forget about target dependencies:

```swift
.product(
  name: "CombineInterception", 
  package: "combine-interception"
)
```

```swift
.product(
  name: "CombineInterceptionMacros",
  package: "combine-interception"
)
```



## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.

See [ACKNOWLEDGMENTS](ACKNOWLEDGMENTS) for inspiration references and their licences.
