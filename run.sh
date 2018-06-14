#!/bin/bash
python -m timeit -n 10 -s "from pyprimes import prime_count" "prime_count(1500000)"
