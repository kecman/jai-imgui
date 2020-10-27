# jai-imgui

An alternate IMGUI wrapper for Jai. Alpha state.

Windows only at the moment. If you want to add mac or linux support, you need to implement a function like `get_windows_symbols` which demangles C++ function names from the DLL for your platform. The Windows code uses `dumpbin.exe` for this purpose.

The meat of this project is in `generate_jai_wrapper.py`.

## Building demos

`jai build.jai`

Then run

`example_null.exe` to see a command-line (non-graphical) test of the bindings, or

`imgui_opengl_test.exe`

to see the ImGui demo window. You can do `Examples->Dockspace` to test out docking.

One gotcha here: there's an ImGui module included in Jai. The demos expect THIS imgui library to be `#import`ed. So your build script in your own project must modify the modules path. See `build.jai`.

## Regenerating bindings from scratch

Note: This project utilizes the metadata generated by the `cimgui` but generates `.jai` module files that directly link to the C++ ImGui DLL, so no `cimgui.dll` required in your actual project.
```
Make sure we have the `cimgui/` folder, IT has its own `imgui/` folder.

git submodule update --init --recursive
```

Build `imgui.lib` and `imgui.dll`.

```
build_windows_libs.bat
```

Generate cimgui's description JSON files.

```
generate_cimgui_json.bat
```

And finally generate the jai bindings.

```
generate_bindings.bat
```

