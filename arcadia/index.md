---
---
# Arcadia Fast Boot
Trying to bring down Arcadia's boot time

---

### Sat Dec 24 2016 11:39
[Nostrand](https://github.com/nasser/nostrand) is able to boot very fast by AOTing all of its assemblies to `.dylib` files on OSX. This skips initial JIT time, which is significant.

To reproduce this in Arcadia, we need to AOT compile 64bit `dylib`s for all our assemblies, too, but we need to do it from Unity's Mono 2.6. The Mono that ships with Unity flatly refuses to AOT.

```
$ /Applications/Unity/Unity.app/Contents/Mono/bin/mono --aot
AOT compilation is not supported on this platform.
```

So I am trying to build [Unity's Mono](https://github.com/Unity-Technologies/mono) from source to enable AOTing myself.

Build script:

```
$ ./configure CFLAGS=-g PKG_CONFIG=pkg-config --with-macversion=10.11 --with-tls=pthread --target=x86_64-apple-darwin15.6.0  --prefix=/usr/local/
$ make
```

Works, but fails with

```
if test -w ../mcs; then :; else chmod -R +w ../mcs; fi
cd ../mcs && /Applications/Xcode.app/Contents/Developer/usr/bin/make NO_DIR_CHECK=1 PROFILES='net_1_1 net_2_0 net_3_5    unity' CC='gcc' all-profiles
/Applications/Xcode.app/Contents/Developer/usr/bin/make profile-do--net_1_1--all profile-do--net_2_0--all profile-do--net_3_5--all profile-do--unity--all
/Applications/Xcode.app/Contents/Developer/usr/bin/make PROFILE=basic all
make[6]: *** [build/deps/basic-profile-check.out] Error 1
*** The compiler 'mcs' doesn't appear to be usable.
*** You need a C# 1.0 compiler installed to build MCS (make sure mcs works from the command line)
*** mcs/gmcs from mono > 2.6 will not work, since they target NET 2.0.
*** Read INSTALL.txt for information on how to bootstrap a Mono installation.
make[5]: *** [do-profile-check] Error 1
make[4]: *** [profile-do--basic--all] Error 2
make[3]: *** [profiles-do--all] Error 2
make[2]: *** [all-local] Error 2
make[1]: *** [all-recursive] Error 1
make: *** [all] Error 2
```

which might be a problem. Executable is in `mono/mini/mono`. AOTing starts but fails.

```
$ MONO_PATH=/Applications/Unity/Unity.app/Contents/Mono/lib/mono/2.0/ mono/mini/mono --aot Example.dll
Mono Ahead of Time compiler - compiling assembly Example.dll
Code: 380 Info: 10 Ex Info: 18 Unwind Info: 73 Class Info: 30 PLT: 7 GOT Info: 160 GOT Info Offsets: 36 GOT: 80 Offsets: 120
section .data aligned to 64 from 60
Stacktrace:


Native stacktrace:

	0   libsystem_platform.dylib            0x00007fff97a30f6d _platform_memmove$VARIANT$Haswell + 77
	1   libsystem_c.dylib                   0x00007fff8b996f13 __memcpy_chk + 22
	2   mono                                0x0000000106c23846 append_subsection + 198
	3   mono                                0x0000000106c229b3 collect_sections + 371
  ...
```

Maybe the warning about `You need a C# 1.0 compiler installed to build MCS` is to be heeded.
