Simple parser/compiler/runtime for a toy programming language.

For the syntax see `test/`.

## Building

Using [GCC](https://gcc.gnu.org/), [GNU Bison](https://www.gnu.org/software/bison/) and [flex](https://github.com/westes/flex)

```sh
make
```

## Usage

```sh
out/test # read from stdin
out/test path/to/file.tst # read from file
```

## Testing

You need [Bats](https://github.com/sstephenson/bats) for this.

```sh
make test
```
