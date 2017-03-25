Simple parser/compiler/runtime for a toy programming language.

For the syntax see `test/`.

## Building

Using [GCC](https://gcc.gnu.org/), [lemon](http://www.hwaci.com/sw/lemon/) and [flex](https://github.com/westes/flex)

```sh
make
```

## Usage

```sh
out/test -h # usage information
out/test path/to/file.tst # read from file
```

## Testing

You need [Bats](https://github.com/sstephenson/bats) for this.

```sh
make test
```
