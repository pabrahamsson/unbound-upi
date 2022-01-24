FROM registry.access.redhat.com/ubi8/ubi-minimal:8.5 AS builder
ARG VERSION=1.14.0
WORKDIR /src
RUN microdnf install gcc openssl-devel expat-devel tar gzip make
RUN curl -L https://nlnetlabs.nl/downloads/unbound/unbound-${VERSION}.tar.gz \
    | tar zxf - --strip-components=1 && \
    ./configure --enable-static-exe --disable-flto && \
    sed -i 's/^\(LDFLAGS=\)/\1-all-static/' Makefile && \
    make

FROM registry.access.redhat.com/ubi8/ubi-minimal:8.5
COPY --from=builder /src/unbound /usr/local/bin/
COPY --from=builder /src/unbound-anchor /usr/local/bin/
COPY --from=builder /src/unbound-checkconf /usr/local/bin/
COPY --from=builder /src/unbound-control /usr/local/bin/
COPY --from=builder /src/unbound-control-setup /usr/local/bin/
COPY --from=builder /src/unbound-host /usr/local/bin/
USER 1001
ENTRYPOINT ["unbound"]
CMD ["-V"]
