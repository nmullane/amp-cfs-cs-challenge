The executable `core-cpu1`  is the prebuilt binary of cFS containing the patched/correct checksum application.
The executable relies on the objects and startup script contained in the `cf/` directory.

You should be able to run the binary `core-cpu1` on native ubuntu linux. Tested on ubuntu 16.04, 18.04, and 20.04.

You can also build from source by running the following commands in the **`cFS`** subdirectory.

```bash
make
make install
cd build/exe/cpu1
./core-cpu1
```
