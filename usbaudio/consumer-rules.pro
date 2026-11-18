# Keep classes and constructors looked up from jni_bridge.cpp.
-keep class neko.music.usbaudio.model.DacFormat { <init>(...); }
-keep class neko.music.usbaudio.model.DacCapabilities { <init>(...); }

# Keep names used by the exported JNI method symbols.
-keepclasseswithmembernames class neko.music.usbaudio.UsbAudioDriver { native <methods>; }
