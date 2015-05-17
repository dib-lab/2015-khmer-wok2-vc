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

----

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


----

@@mention diginorm.

@@ what's with the = in variant-sim.txt??

@@ can do targeted, unlike mapping

@@ stuff with 
