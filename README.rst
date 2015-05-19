Summary information
-------------------

This is the README for the github repository
https://github.com/dib-lab/2015-khmer-wok2-vc.

This repository contains the pipeline underlying the blog
post/micropub entitled `Graph alignment and variant calling
<http://ivory.idyll.org/blog/2015-wok-variant-calling.html>`__.

Contact: C. Titus Brown, titus@idyll.org, or @ctitusbrown (on Twitter).

Running the pipeline
--------------------

We provide two ways to reproduce the results in the blog post -- first,
instructions for a blank Ubuntu virtual machine, and second, 
instructions for running inside a Docker container.

You will need less than 2 GB of RAM and about 10 GB of free disk space to
run all of this.  It should take about an hour to run.

Using an Ubuntu 14.04 virtual machine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Boot up an empty Ubuntu image (an Amazon m3.large should be enough),
and run::

   sudo apt-get update && \
       sudo apt-get -y install python-virtualenv python-dev git bowtie2 \
            samtools libboost-dev zlib1g-dev && \
       shutdown -r now

Log back in, and set yourself up with a virtualenv::

   python -m virtualenv work
   . work/bin/activate
   pip install -U setuptools
   git clone https://github.com/dib-lab/nullgraph.git

Now install the `2015-wok
<https://github.com/dib-lab/khmer/tree/2015-wok>`__ branch of khmer::

   git clone https://github.com/dib-lab/khmer.git -b 2015-wok
   cd khmer && make install; cd ..

Go to a sizeable working directory that you have permissions to write
to; on AWS, this is /mnt. ::

   sudo chmod a+rwxt /mnt
   cd /mnt

Then, clone the pipeline::

   git clone https://github.com/dib-lab/2015-khmer-wok1-vc.git wok2

and grab the data::

   cd wok2
   curl -O https://s3.amazonaws.com/public.ged.msu.edu/2015-wok/ecoli-mapped.fq.gz
   curl -O https://s3.amazonaws.com/public.ged.msu.edu/ecoliMG1655.fa.gz
   gunzip ecoliMG1655.fa

And, finally, run the pipeline::

   make

To interpret the results, please see the blog post above, or look through
the Makefile.

Running inside Docker
~~~~~~~~~~~~~~~~~~~~~

**First,** if you need to install Docker, perhaps on your empty Ubuntu
machine from above, do the following::

   wget -qO- https://get.docker.com/ | sudo sh

If you are doing the above on a blank Ubuntu machine on e.g. AWS, make
sure to give the ubuntu user permissions to run docker::

   sudo usermod -aG docker ubuntu

and then log out & back in to enable those permissions.

Go to a sizeable working directory that you have permissions to write
to; on AWS, this is /mnt. ::

   sudo chmod a+rwxt /mnt
   cd /mnt

Then, clone the pipeline::

   git clone https://github.com/dib-lab/2015-khmer-wok2-vc.git wok2

and grab the data::

   cd wok2
   curl -O https://s3.amazonaws.com/public.ged.msu.edu/2015-wok/ecoli-mapped.fq.gz
   curl -O https://s3.amazonaws.com/public.ged.msu.edu/ecoliMG1655.fa.gz
   gunzip ecoliMG1655.fa

And, finally, run the pipeline::

   docker run -v /mnt/wok2:/pipeline titus/2015-wok

To interpret the results, please see the blog post above, or look through
the Makefile.
