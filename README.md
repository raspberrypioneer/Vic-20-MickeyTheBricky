# Mickey the Bricky for the Commodore Vic20
Mickey the Bricky game disassembly with build scripts for reassembly for the unexpanded and 8K+ expanded Vic20.

The 8K+ expanded version is the same as the unexpanded version except it works in the 8K+ expanded memory configuration.

Compile and build the original unexpanded version or the 8K+ expanded version as below:

Amend `main.asm`, switching to the desired memory configuration to build.
```
USE_8k_MEMORY_LAYOUT = 1  ;0 = unexpanded memory layout or 1 = 8K+ expanded memory layout
```

Amend the `mtb_build_all.bat` and `mtb_run.bat` by commenting / uncommenting the instructions as indicated there.
