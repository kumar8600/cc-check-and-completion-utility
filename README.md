cc-check-and-completion-utility
========================

Emacs minor mode for auto configuration of C/C++ syntax checking and completion packages with [CMake][].

This mode get the compile options from build system [CMake][] and
configure syntax checking and completion packages. Not only that, you can
generate build tree and compile and run it. **So, you can use emacs like IDE
by only put source codes and build configuration file `CMakeFile.txt`.**

This mode can works with...
---------------------------------

#### Build systems (**Choose at least any one.**):

  - [CMake][] with
    - [Make][GNU Make] (default)
	- [Ninja][]
  - Under constructions...
    - [Bear][]
    - [JSON Compilation Database Format][clang-json]

#### Syntax check packages:

  - [Flycheck][]
    - >= 0.16

#### Completion (like Intellisense) packages:

  - [Company][]
    - >= 0.5
  - [emacs-clang-complete-async][]

Set up
------------

Basic setup:

```
(add-to-list 'load-path
                "~/path-to-cc-check-and-completion-utility")
(require 'cc-check-and-completion-utility)

(add-hook 'c-mode-hook 'cccc-mode)
(add-hook 'c++-mode-hook 'cccc-mode)
```

Basic Usage (with CMake)
-------------

1. Put source codes and `CMakeLists.txt` on your source tree.
2. Create build-tree named `build`. (If you don't do it, this package asks you where do I create build-tree.)
3. Just open your source code. Enjoy!

Advanced Usage
-------------

Compile option analysis can be controlled with `cccc/load-options` and
`cccc/reload-options`. But you probably don't need call them directly. While cccc-mode
is enabled, those commands automatically called when you open C/C++ sources and
someone modified build configuration file.

You can generate build tree with `cccc/generate-build-files`.
You can compile build tree with `cccc/compile`.
You can run executable file with `cccc/run`.

If you want to compile and run, I recommend `cccc/compile-and-run`.

##### CMake

If valid `CMakeLists.txt` is exists at source code's directory or upper, it will work.
If you don't have build tree, this plugin ask you where build tree create. Build tree's name must
be `build`. If you want to change this name, customize variable `cccc/cmake-build-tree-name`.

###### Acceptable trees

If `CMakeFiles.txt` and build-tree `build` are exists at upper or current directory where source is opened exists,
it is acceptable tree.

Example 1:

```
.
|-- build
`-- src
  |-- CMakeFiles.txt
  |-- blah.cpp
  |-- blah.h
  `-- blahblah
    |-- blahblah.cc
    .
    .
```

Example 2:

```
.
|-- build
|-- CMakeFiles.txt
|-- blah.cpp
.
.
```


Customization
-------------

There are customizable user options.

- `cccc/cmake-build-tree-name`
  - CMake's build tree name used when build-tree searching and creating.
  - Default value is `"build"`.

- `cccc/cmake-generator`
  - CMake's build system generator.
  - You can select `cmakefiles` or `ninja`.
    - When select `cmakefiles` in windows, automatically detect environment
	  and select `MinGW Makefiles` or `MSYS Makefiles` generators.

- `cccc/with-checker-flycheck`
  - Set non-nil if you want to use [Flycheck][] as checker.
  - Default value is `t`.

- `cccc/with-completer-company`
  - Set non-nil if you want to use [Company][] as checker.
  - Default value is `t`.

- `cccc/with-completer-ac-clang-async`
  - Set non-nil if you want to use [emacs-clang-complete-async][] as checker.
  - Default value is `t`.

License
-------

see `./LICENSE`

Similar packages
----------------

- [cpputils-cmake][]
- [emacs-cmake-project][]
- [irony-mode][]
- [rtags][]

[Flycheck]: https://github.com/flycheck/flycheck
[Company]: http://company-mode.github.io/
[CMake]: http://www.cmake.org/
[GNU Make]: http://www.gnu.org/software/make/
[Ninja]: http://martine.github.io/ninja/
[Bear]: https://github.com/rizsotto/Bear
[Clang]: http://clang.llvm.org/
[clang-json]: http://clang.llvm.org/docs/JSONCompilationDatabase.html
[emacs-clang-complete-async]: https://github.com/Golevka/emacs-clang-complete-async

[cpputils-cmake]: https://github.com/redguardtoo/cpputils-cmake
[emacs-cmake-project]: https://github.com/alamaison/emacs-cmake-project
[irony-mode]: https://github.com/Sarcasm/irony-mode
[rtags]: https://github.com/Andersbakken/rtags/
