# grains.sh

A single shell script to gather basic information on Linux host.

# Usage

1) Run `./grains.sh` directly will print all grains.

2) `source /path/to/grains.sh` will injects `GRAIN_` prefixed variables in your shell environment, you can use these variables in your shell script.

## Try to supported OSes

 - MacOS  (>= 10.11.1)
 - Ubuntu (>= 14.04)
 - CentOS (>= 7)
 - Alpine (>= 3.5)

## TODO

- more tests

# References

- salt/grains
- puppet/facter
- pt-summary
