Read-to-graph alignment and error correction
============================================

Authors: CTB, MRC, Jordan Fish, Jason Pell.

There's an interesting and intuitive connection between `error
correction <@@>`__ and variant calling - if you can do one well, it
lets you do (parts of) the other well.  In our previous blog post on
some new features in khmer, we introduced our new "graphalign"
functionality, that lets us align short sequences to De Bruijn graphs,
and we discussed how we use it for error correction.  Now, let's
try it out for some simple variant calling!

Graphalign can potentially be used for variant calling in a few
different ways - by mapping reads to the reference graph and then
using a pileup approach, or by error correcting reads against the
graph with a tunable threshold for errors and then looking to see
where all the reads disagree - but I've become enamored of an approach
based on the concept of reference-guided assembly.

The essential idea is to build a graph that contains the information
in the reads, and then "assemble" a path through the graph using a
reference sequence as a guide.  This has the advantage of looking at
the reads only once (to build a DBG, which can be done in a single
pass), and also potentially being amenable to a variety of heuristics.
(Like almost all variant calling, it *is* limited by the quality of
the reference, although I think there are probably some ways around
that.)

Basic graph-based variant calling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Implementing this took a little bit of extra effort beyond the basic
short-sequence aligner, because we have to align around gaps in the
graph.  The way we did this was to break the reference up into a bunch
of local alignments, each aligned independently, then stitched
together.

Again, I tried to keep the API simple. After creating a ReadAligner object, ::

    aligner = khmer.ReadAligner(graph, trusted_cutoff, bits_theta)

there's a single function that takes in the graph and the sequence (potentially
genome/chr sized) to align::

    score, alignment = align_long(graph, aligner, sequence)

What is returned is a score and an alignment object that gives you access
to the raw alignment, some basic stats, and "variant calling" functionality -
essentially, reporting of where the alignments are not identical.  This is
pretty simple to implement::

     for n, (a, b) in enumerate(zip(graph_alignment, read_alignment)):
         if a != b:
            yield n, a, b

The current implementation of the variant caller does nothing beyond
reporting where an aligned sequence differs from the graph; this is
kind of like guided assembly. In the future, the plan is to extend it
with reference-free assembly such as @@.

To see this in action for a simulated data set, look at the target
``variants-sim.txt`` -- you get alignments like this, highlighting
mismatches::

   ATTTTGTAAGTGCTCTATCCGTTGTAGGAAGTGAAAGATGACGTTGCGGCCGTCGCTGTT
   |||||||||||||||||||| |||||||||||||||||||||||||||||||||||||||
   ATTTTGTAAGTGCTCTATCCCTTGTAGGAAGTGAAAGATGACGTTGCGGCCGTCGCTGTT

It works OK for whole-genome bacterial stuff, too.  If you take an
E. coli data set (the same one we used for diginorm@@ and the
semi-streaming paper@@) and just run the reads against the known
reference genome, you'll get 75 differences between the graph and the
reference genome, out of 4639680 positions -- an identity of 99.998%.
On the one hand, this is not that great (consider that for something
the size of the human genome, with this error rate we'd be seeing
50,000 false positives!); on the other hand, as with error correction,
the whole stack of code is surprisingly simple, and we haven't spent
much time tuning it yet.

Simulated variants, and targeted variant calling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On simulated variants in the E. coli genome, it does pretty well.
Here, rather than changing up the genome and generating synthetic
reads, I went with the same real reads as before, and instead changed
the reference genome which I was aligning to the reads.  This was done
with the patch-ecoli.py@@ script, which changes an A to a C at
position 500,000, removes two bases at position 2m, and adds two bases
at position 3m.

When we align the "patched" E. coli genome against the read graph, we
indeed recover all three alignments (see variants-patched.txt@@) in
the background of the same false positives we saw in the unaltered
genome.  So that's kind of nice.

What's even neater is that we can do *targeted* variant calling
directly against the graph -- suppose, for example, that we're
interested in just a few regions of the reference.  With the normal
mapping-based variant calling, you need to map all the reads first
before querying for variants by location, because mapping requires the
use of the entire reference.  Here, you are already looking at all the
reads in the graph form, so you can query just the regions you're
interested in.

So, for example, here you can align just the patched regions (in
ecoli-patched-segments.fa) against the read graph and get the same
answer you got when aligning the entire reference (target
ecoli-patched-segments.align.out, see file
ecoli-patched-segments.align.out).  This works in part because we're
stitching together local alignments, so there are some caveats in
cases where different overlapping query sequences might lead to
different optimal alignments - further research needed.

----

@@mention diginorm.

@@ what's with the = in variant-sim.txt??

@@ can do targeted, unlike mapping

@@ stuff with  ??

actauly graph based variant calling.

metagneome etc.

timing/speed.
