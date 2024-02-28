# combine-interception

[![SwiftPM 5.9](https://img.shields.io/badge/swiftpm-5.9-ED523F.svg?style=flat)](https://swift.org/download/) ![Platforms](https://img.shields.io/badge/Platforms-iOS_13_|_macOS_10.15_|_Catalyst_13_|_tvOS_14_|_watchOS_7-ED523F.svg?style=flat) [![@capturecontext](https://img.shields.io/badge/contact-@capturecontext-1DA1F2.svg?style=flat&logo=twitter)](https://twitter.com/capture_context) 

Combine API for interception of objc selectors in Swift.

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
  .upToNextMinor(from: "0.3.0")
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

This library is released under the MIT license. See [LICENCE](LICENCE) for details.

See [ACKNOWLEDGMENTS](ACKNOWLEDGMENTS) for inspiration references and their licences.
