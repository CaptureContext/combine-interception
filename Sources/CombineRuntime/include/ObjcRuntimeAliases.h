#import <objc/runtime.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

extern const IMP _combineRuntimeMsgForward;

/// A trampoline of `objc_setAssociatedObject` that is made to circumvent the
/// reference counting calls in the imported version in Swift.
void _combineRuntimeSetAssociatedObject(
  const void* object,
  const void* key,
  id _Nullable value,
  objc_AssociationPolicy policy
);

NS_ASSUME_NONNULL_END
