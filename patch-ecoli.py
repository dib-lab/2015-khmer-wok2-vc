#! /usr/bin/env python
import sys
import screed
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('genome')
args = parser.parse_args()

genome = list([ r for r in screed.open(args.genome) ])[0]

# replace an 'a' with a 'c' at position 500k
pos = 500000
patchseq = genome.sequence
ch = patchseq[pos]
replace_with = 'c'
assert ch != replace_with
patchseq = patchseq[:pos] + replace_with + patchseq[pos + 1:]
print >>sys.stderr, '>a1000000 %s %s\n%s' % (ch, replace_with,
                                             patchseq[pos-100:pos+100],)

# remove two bases at 2m
patchseq = patchseq[:2000000] + patchseq[2000002:]
print >>sys.stderr, '>b2000000\n%s' % (patchseq[1999900:2000100],)

# add two bases at 3m
patchseq = patchseq[:3000000] + 'gg' + patchseq[3000000:]
print >>sys.stderr, '>c3000000\n%s' % (patchseq[2999900:3000100],)

print '>%s\n%s' % (genome.name, patchseq)
