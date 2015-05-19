FROM titus/2014-streaming
MAINTAINER Titus Brown <titus@idyll.org>
WORKDIR /home

RUN cd /home/khmer && git fetch && git checkout 2015-wok
RUN cd /home/khmer && make install

# the basic command runs 'make' with appropriate paths set to installed sw.
CMD /pipeline/docker-entrypoint.sh
