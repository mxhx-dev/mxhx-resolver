# mxhx-component tests

Automated tests created with [utest](https://lib.haxe.org/p/utest).

## Run interpreter tests

To run tests with the Haxe interpreter, run the following command:

```sh
haxe test.hxml --interp
```

## Run Neko tests

To run tests with Neko, run the following command:

```sh
haxe test.hxml --neko bin/test.n
neko bin/test.n
```

## Run HashLink tests

To run tests with HashLink, run the following command:

```sh
haxe test.hxml --hl bin/test.hl
hl bin/test.hl
```

## Run Node.js tests

To run tests with Node.js, run the following command:

```sh
haxe test.hxml --js bin/test.js
node bin/test.js
```

## Run C++ tests

To run tests with a native C++ executable, run the following command:

```sh
haxe test.hxml --cpp bin/test
bin/test/Main
```
