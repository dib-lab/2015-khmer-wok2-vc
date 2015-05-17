NULLGRAPH=../nullgraph
KHMER=../khmer
GRAPHALIGN=../2015-experimental-graphalign

all: ecoli.align.out variants-sim.txt ecoli.align.out \
	ecoli-patched.align.out ecoli-patched-segments.align.out

clean:
	-rm simple-genome-reads.fa variants*.txt *.align.out

2015-wok-variant-calling.html: 2015-wok-variant-calling.rst
	rst2html.py 2015-wok-variant-calling.rst 2015-wok-variant-calling.html

simple-genome.fa:
	$(NULLGRAPH)/make-random-genome.py -l 1000 -s 1 > simple-genome.fa

simple-genome-reads.fa: simple-genome.fa
	$(NULLGRAPH)/make-reads.py -S 1 -e .01 -r 100 -C 100 simple-genome.fa --mutation-details simple-genome-reads.mut > simple-genome-reads.fa

simple-genome-reads.graph: simple-genome-reads.fa
	normalize-by-median.py -C 20 -k 20 -x 1e7 -N 4 simple-genome-reads.fa -s simple-genome-reads.ct
	filter-abund.py -C 3 simple-genome-reads.ct simple-genome-reads.fa.keep
	normalize-by-median.py -C 5 -k 20 -x 1e7 -N 4 simple-genome-reads.fa.keep.abundfilt -s simple-genome-reads.graph

variants-sim.txt: simple-genome-reads.graph
	 $(GRAPHALIGN)/find-variant-by-align-long.py simple-genome-reads.graph simple-genome-orig.fa --trusted 2 --variants-out variants-sim.txt > sim.align.out

ecoli-mapped.fq.gz.keep.gz: ecoli-mapped.fq.gz
	normalize-by-median.py -k 21 -x 1e8 -N 4 ecoli-mapped.fq.gz
	gzip ecoli-mapped.fq.gz.keep

ecoli.dn.k21.kh: ecoli-mapped.fq.gz.keep.gz
	load-into-counting.py -k 21 -x 8e7 ecoli.dn.k21.kh ecoli-mapped.fq.gz.keep.gz

ecoli.align.out: ecoli.dn.k21.kh
	$(GRAPHALIGN)/find-variant-by-align-long.py ecoli.dn.k21.kh ecoliMG1655.fa --variants-out variants-ecoli.txt > ecoli.align.out

ecoli-patched.fa: ecoliMG1655.fa patch-ecoli.py
	python patch-ecoli.py ecoliMG1655.fa > ecoli-patched.fa 2> ecoli-patched-segments.fa

ecoli-patched.align.out: ecoli.dn.k21.kh ecoli-patched.fa
	$(GRAPHALIGN)/find-variant-by-align-long.py ecoli.dn.k21.kh ecoli-patched.fa --variants-out variants-patched.txt > ecoli-patched.align.out

ecoli-patched-segments.align.out: ecoli-patched.fa ecoli-patched-segments.fa
	$(GRAPHALIGN)/find-variant-by-align-long.py ecoli.dn.k21.kh ecoli-patched-segments.fa --variants-out variants-segments.txt > ecoli-patched-segments.align.out
