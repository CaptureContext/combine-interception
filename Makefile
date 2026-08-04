output ?= .agents/interfaces
platform ?= host
swift_sdk ?=

.PHONY: swiftinterface
swiftinterface:
	@./scripts/generate-swiftinterfaces.sh --package-path . --output "$(output)" --configuration debug --build-arg --build-system --build-arg native --platform "$(platform)" $(if $(swift_sdk),--swift-sdk "$(swift_sdk)")
