#! /usr/bin/env python
import sys
import argparse
import screed
import khmer
from graphAlignment import align_long, AlignmentIndex


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('table')
    parser.add_argument('ref')
    parser.add_argument('--trusted', type=int, default=5)
    parser.add_argument('--variants-out', type=str, default='variants.txt',
                        dest='variants_out')
    args = parser.parse_args()

    ct = khmer.load_counting_hash(args.table)
    aligner = khmer.ReadAligner(ct, args.trusted, 1.0)

    for record in screed.open(args.ref):
        seq = record.sequence
        seq = seq.replace('N', 'A')

        score, alignment = align_long(ct, aligner, seq)

        g = alignment.g
        r = alignment.r

        m, n = alignment.compare()
        print record.name, m, n, n - m, "%.3f%%" % (float(m)/ n * 100)
        for start in range(0, len(alignment), 60):
            print start
            print alignment[start:start+60]

        gidx = AlignmentIndex(alignment)
        fp = open(args.variants_out, 'w')

        for gi, a, b in alignment.variants():
            kmer = ''
            pos = gi
            while len(kmer) < ct.ksize() and pos < len(alignment.g):
                ch = alignment.g[pos]
                pos += 1
                if ch in '=-':
                    continue
                kmer += ch

            if alignment.covs[gi]:
                print >>fp, gi, a, b, gidx.get_ri(gi), kmer, alignment.covs[gi]

        if 0:
            print len(seq), alignment.refseqlen()
            gidx._sanityCheck(seq)

if __name__ == '__main__':
    main()
